import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/cart_item.dart';
import '../../../product/domain/entities/product.dart';
import '../../../product/domain/usecases/product_usecases.dart';
import '../../../sales/domain/entities/sale.dart' as sales;
import '../../../sales/domain/usecases/sale_usecases.dart';
import '../../../customer/domain/usecases/customer_usecases.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/printer_helper.dart';
import '../../../../core/data/hive_database.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/id_generator.dart';

part 'billing_event.dart';
part 'billing_state.dart';

class BillingBloc extends Bloc<BillingEvent, BillingState> {
  final GetProductByBarcodeUseCase getProductByBarcodeUseCase;
  final SaveSaleUseCase saveSaleUseCase;
  final GetNextTicketNumberUseCase getNextTicketNumberUseCase;
  final UpdateProductUseCase updateProductUseCase;
  final AddDebtUseCase addDebtUseCase;

  BillingBloc({
    required this.getProductByBarcodeUseCase,
    required this.saveSaleUseCase,
    required this.getNextTicketNumberUseCase,
    required this.updateProductUseCase,
    required this.addDebtUseCase,
  }) : super(const BillingState()) {
    on<ScanBarcodeEvent>(_onScanBarcode);
    on<AddProductToCartEvent>(_onAddProductToCart);
    on<RemoveProductFromCartEvent>(_onRemoveProductFromCart);
    on<UpdateQuantityEvent>(_onUpdateQuantity);
    on<ClearCartEvent>(_onClearCart);
    on<PrintReceiptEvent>(_onPrintReceipt);
    on<ValidateSale>(_onValidateSale);
    on<FastPayEvent>(_onFastPay);
  }

  void _onFastPay(FastPayEvent event, Emitter<BillingState> emit) {
    final fastPayProduct = Product(
      id: 'fast_pay_${Uuid().v4()}',
      name: 'VENTE RAPIDE',
      price: event.amount,
      purchasePrice: 0.0, // Usually unknown for manual entry
      barcode: null,
    );
    final newItem = CartItem(product: fastPayProduct);
    emit(state.copyWith(cartItems: [...state.cartItems, newItem], status: BillingStatus.initial)); 
  }

  Future<void> _onValidateSale(
      ValidateSale event, Emitter<BillingState> emit) async {
    if (state.cartItems.isEmpty) return;

    emit(state.copyWith(status: BillingStatus.loading));

    // 1. Generate Ticket Number (Local & Fast)
    final ticketNumberResult = await getNextTicketNumberUseCase(NoParams());
    String ticketNumber = 'TKT-000000';
    ticketNumberResult.fold((l) => null, (r) => ticketNumber = r);

    final totalMillimes = CurrencyUtils.toMillimes(state.totalAmount);
    final dueMillimes = totalMillimes - event.paidMillimes;

    // 2. Create Sale Record
    final sale = sales.Sale(
      id: Uuid().v4(),
      ticketNumber: ticketNumber,
      createdAt: DateTime.now(),
      customerId: event.customerId,
      items: state.cartItems
          .map((item) => sales.SaleItem(
                id: const Uuid().v4(),
                saleId: '', // Will be set or not used depending on backend
                productId: item.product.id,
                productName: item.product.name,
                quantity: item.quantity,
                priceAtSaleMillimes: CurrencyUtils.toMillimes(item.product.price),
                purchasePriceAtSaleMillimes: CurrencyUtils.toMillimes(item.product.purchasePrice),
                createdAt: DateTime.now(),
              ))
          .toList(),
      totalMillimes: totalMillimes,
      paidMillimes: event.paidMillimes,
      dueMillimes: dueMillimes,
      paymentMethod: event.paymentMethod,
    );

    // 3. Atomically Persist Sale (The Ticket)
    final saveResult = await saveSaleUseCase(sale);

    if (saveResult.isRight()) {
      // 4. Update debt if needed (High priority for ledger integrity)
      if (event.paymentMethod == sales.PaymentMethod.credit &&
          event.customerId != null) {
        final paymentId = IdGenerator.generatePaymentId(ticketNumber);
        await addDebtUseCase(AddDebtParams(
          customerId: event.customerId!,
          amountMillimes: dueMillimes,
          saleId: sale.id,
          ticketNumber: ticketNumber,
          paymentId: paymentId,
        ));
      }

      // 5. Update Stock (Sequential await to ensure database consistency)
      for (final item in state.cartItems) {
        if (!item.product.id.startsWith('fast_pay_')) {
          // Re-fetch product to get latest stock from DB before subtracting
          final pResult = await getProductByBarcodeUseCase(item.product.barcode ?? '');
          await pResult.fold(
            (l) async {}, // Ignore if not found
            (latestProduct) async {
              final updatedProduct = latestProduct.copyWith(
                stock: latestProduct.stock - item.quantity,
              );
              await updateProductUseCase(updatedProduct);
            },
          );
        }
      }

      // 6. The sale is now durably persisted — this is the only point in
      // the whole flow where the cart may be cleared. Clearing it any
      // earlier (e.g. on checkout navigation) would lose the user's
      // in-progress sale if they back out or the payment fails; clearing
      // it later (or leaving it to a separate manual step) lets the old
      // sale's items bleed into the next one.
      emit(state.copyWith(cartItems: [], status: BillingStatus.success));
    } else {
      emit(state.copyWith(status: BillingStatus.error, error: 'Erreur lors de l\'enregistrement de la vente'));
    }
  }

  Future<void> _onScanBarcode(
      ScanBarcodeEvent event, Emitter<BillingState> emit) async {
    final result = await getProductByBarcodeUseCase(event.barcode);
    result.fold(
      (failure) =>
          emit(state.copyWith(error: 'Produit non trouvé: ${event.barcode}')),
      (product) {
        add(AddProductToCartEvent(product));
      },
    );
  }

  void _onAddProductToCart(
      AddProductToCartEvent event, Emitter<BillingState> emit) {
    final cleanState = state.copyWith(error: null, status: BillingStatus.initial);

    final existingIndex = cleanState.cartItems
        .indexWhere((item) => item.product.id == event.product.id);
    if (existingIndex >= 0) {
      final existingItem = cleanState.cartItems[existingIndex];
      final backendItems = List<CartItem>.from(cleanState.cartItems);
      backendItems[existingIndex] =
          existingItem.copyWith(quantity: existingItem.quantity + 1);
      emit(cleanState.copyWith(cartItems: backendItems, error: null));
    } else {
      final newItem = CartItem(product: event.product);
      emit(cleanState.copyWith(
          cartItems: [...cleanState.cartItems, newItem], error: null));
    }
  }

  void _onRemoveProductFromCart(
      RemoveProductFromCartEvent event, Emitter<BillingState> emit) {
    final updatedList = state.cartItems
        .where((item) => item.product.id != event.productId)
        .toList();
    emit(state.copyWith(cartItems: updatedList, status: BillingStatus.initial));
  }

  void _onUpdateQuantity(
      UpdateQuantityEvent event, Emitter<BillingState> emit) {
    if (event.quantity <= 0) {
      add(RemoveProductFromCartEvent(event.productId));
      return;
    }

    final index = state.cartItems
        .indexWhere((item) => item.product.id == event.productId);
    if (index >= 0) {
      final items = List<CartItem>.from(state.cartItems);
      items[index] = items[index].copyWith(quantity: event.quantity);
      emit(state.copyWith(cartItems: items, status: BillingStatus.initial));
    }
  }

  void _onClearCart(ClearCartEvent event, Emitter<BillingState> emit) {
    emit(const BillingState());
  }

  Future<void> _onPrintReceipt(
      PrintReceiptEvent event, Emitter<BillingState> emit) async {
    final printerHelper = PrinterHelper();

    if (!printerHelper.isConnected) {
      final savedMac = HiveDatabase.settingsBox.get('printer_mac');
      if (savedMac != null) {
        final connected = await printerHelper.connect(savedMac);
        if (!connected) {
          emit(state.copyWith(
              error: 'Failed to auto-connect to printer!', clearError: false));
          emit(state.copyWith(clearError: true));
          return;
        }
      } else {
        emit(state.copyWith(
            error: 'Printer not connected & no saved printer found!',
            clearError: false));
        emit(state.copyWith(clearError: true));
        return;
      }
    }

    emit(state.copyWith(
        isPrinting: true, printSuccess: false, clearError: true));

    try {
      final List<Map<String, dynamic>> items;
      double totalAmount;
      String? ticketNumber;
      String? paymentMethod;
      double? paidAmount;
      double? dueAmount;
      String? customerName;

      if (event.sale != null) {
        final sale = event.sale!;
        items = sale.items
            .map((item) => {
                  'name': item.productName,
                  'qty': item.quantity,
                  'price': CurrencyUtils.fromMillimes(item.priceAtSaleMillimes),
                  'total': CurrencyUtils.fromMillimes(item.totalMillimes),
                })
            .toList();
        totalAmount = CurrencyUtils.fromMillimes(sale.totalMillimes);
        ticketNumber = sale.ticketNumber;
        paymentMethod = sale.paymentMethod == sales.PaymentMethod.cash ? 'ESPÈCES' : 'CRÉDIT';
        paidAmount = CurrencyUtils.fromMillimes(sale.paidMillimes);
        dueAmount = CurrencyUtils.fromMillimes(sale.dueMillimes);
      } else {
        items = state.cartItems
            .map((item) => {
                  'name': item.product.name,
                  'qty': item.quantity,
                  'price': item.product.price,
                  'total': item.total,
                })
            .toList();
        totalAmount = state.totalAmount;
      }

      await printerHelper.printReceipt(
          shopName: event.shopName,
          address1: event.address1,
          address2: event.address2,
          phone: event.phone,
          items: items,
          total: totalAmount,
          footer: event.footer,
          ticketNumber: ticketNumber,
          paymentMethod: paymentMethod,
          paidAmount: paidAmount,
          dueAmount: dueAmount,
          customerName: customerName);

      emit(state.copyWith(isPrinting: false, printSuccess: true));
    } catch (e) {
      emit(state.copyWith(
          isPrinting: false, error: 'Print failed: $e', clearError: false));
      emit(state.copyWith(clearError: true));
    }
  }
}
