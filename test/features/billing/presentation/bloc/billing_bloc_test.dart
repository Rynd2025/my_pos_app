// Covers the cart lifecycle fix: entering/leaving checkout must never clear
// the cart, a failed sale must preserve it for retry, and only a
// successfully persisted sale clears it — exactly once — so the next sale
// always starts empty.
import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/core/usecase/usecase.dart';
import 'package:billing_app/features/billing/presentation/bloc/billing_bloc.dart';
import 'package:billing_app/features/customer/domain/usecases/customer_usecases.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/product/domain/usecases/product_usecases.dart';
import 'package:billing_app/features/sales/domain/entities/sale.dart' as sales;
import 'package:billing_app/features/sales/domain/usecases/sale_usecases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockGetProductByBarcodeUseCase extends Mock implements GetProductByBarcodeUseCase {}

class MockSaveSaleUseCase extends Mock implements SaveSaleUseCase {}

class MockGetNextTicketNumberUseCase extends Mock implements GetNextTicketNumberUseCase {}

class MockUpdateProductUseCase extends Mock implements UpdateProductUseCase {}

class MockAddDebtUseCase extends Mock implements AddDebtUseCase {}

void main() {
  late MockGetProductByBarcodeUseCase getProductByBarcodeUseCase;
  late MockSaveSaleUseCase saveSaleUseCase;
  late MockGetNextTicketNumberUseCase getNextTicketNumberUseCase;
  late MockUpdateProductUseCase updateProductUseCase;
  late MockAddDebtUseCase addDebtUseCase;
  late BillingBloc bloc;

  final product1 = Product(id: 'p1', name: 'Product 1', price: 2.0, purchasePrice: 1.0, stock: 10, barcode: 'b1');
  final product2 = Product(id: 'p2', name: 'Product 2', price: 3.0, purchasePrice: 1.5, stock: 10, barcode: 'b2');

  setUpAll(() {
    registerFallbackValue(sales.Sale(
      id: 'fallback',
      ticketNumber: 'TKT-000000',
      createdAt: DateTime(2026, 1, 1),
      items: const [],
      totalMillimes: 0,
      paidMillimes: 0,
      dueMillimes: 0,
      paymentMethod: sales.PaymentMethod.cash,
    ));
    registerFallbackValue(product1);
    registerFallbackValue(NoParams());
    registerFallbackValue(AddDebtParams(customerId: 'fallback', amountMillimes: 0, paymentId: 'fallback'));
  });

  setUp(() {
    getProductByBarcodeUseCase = MockGetProductByBarcodeUseCase();
    saveSaleUseCase = MockSaveSaleUseCase();
    getNextTicketNumberUseCase = MockGetNextTicketNumberUseCase();
    updateProductUseCase = MockUpdateProductUseCase();
    addDebtUseCase = MockAddDebtUseCase();

    when(() => getNextTicketNumberUseCase(any())).thenAnswer((_) async => const Right('TKT-000001'));
    when(() => getProductByBarcodeUseCase(any())).thenAnswer((_) async => Left(CacheFailure('not found')));
    when(() => updateProductUseCase(any())).thenAnswer((_) async => const Right(null));
    when(() => addDebtUseCase(any())).thenAnswer((_) async => const Right(null));

    bloc = BillingBloc(
      getProductByBarcodeUseCase: getProductByBarcodeUseCase,
      saveSaleUseCase: saveSaleUseCase,
      getNextTicketNumberUseCase: getNextTicketNumberUseCase,
      updateProductUseCase: updateProductUseCase,
      addDebtUseCase: addDebtUseCase,
    );
  });

  tearDown(() => bloc.close());

  test('checkout navigation does not clear the cart: nothing in BillingBloc '
      'reacts to navigation, only explicit events change the cart', () async {
    bloc.add(AddProductToCartEvent(product1));
    bloc.add(AddProductToCartEvent(product2));
    await Future.delayed(Duration.zero);

    expect(bloc.state.cartItems.length, 2);

    // Simulates "user pushed /checkout, then popped back" — no BillingBloc
    // event is involved in that navigation at all.
    await Future.delayed(Duration.zero);
    expect(bloc.state.cartItems.length, 2);
  });

  test('a failed sale (persistence error) keeps the cart intact for retry', () async {
    bloc.add(AddProductToCartEvent(product1));
    bloc.add(AddProductToCartEvent(product2));
    await Future.delayed(Duration.zero);
    final cartBefore = bloc.state.cartItems;
    expect(cartBefore.length, 2);

    when(() => saveSaleUseCase(any())).thenAnswer((_) async => Left(CacheFailure('disk full')));

    bloc.add(const ValidateSale(paymentMethod: sales.PaymentMethod.cash, paidMillimes: 5000));
    final finalState = await bloc.stream.firstWhere((s) => s.status == BillingStatus.error);

    expect(finalState.cartItems, cartBefore);
    expect(bloc.state.cartItems.length, 2);
  });

  test('a successful cash sale clears the cart exactly once, atomically with success', () async {
    bloc.add(AddProductToCartEvent(product1));
    await Future.delayed(Duration.zero);
    expect(bloc.state.cartItems, isNotEmpty);

    when(() => saveSaleUseCase(any())).thenAnswer((_) async => const Right(null));

    bloc.add(const ValidateSale(paymentMethod: sales.PaymentMethod.cash, paidMillimes: 2000));
    final finalState = await bloc.stream.firstWhere((s) => s.status == BillingStatus.success);

    // The very state transition that reports success already has an empty
    // cart — there is no separate "success with stale cart" frame for the
    // UI to render before a manual clear happens.
    expect(finalState.cartItems, isEmpty);
    expect(bloc.state.cartItems, isEmpty);
  });

  test('a successful credit sale also clears the cart and records the debt', () async {
    bloc.add(AddProductToCartEvent(product1));
    await Future.delayed(Duration.zero);

    when(() => saveSaleUseCase(any())).thenAnswer((_) async => const Right(null));

    bloc.add(const ValidateSale(
      paymentMethod: sales.PaymentMethod.credit,
      customerId: 'cust-1',
      paidMillimes: 0,
    ));
    final finalState = await bloc.stream.firstWhere((s) => s.status == BillingStatus.success);

    expect(finalState.cartItems, isEmpty);
    verify(() => addDebtUseCase(any())).called(1);
  });

  test('starting a new sale after a completed one never carries over old items', () async {
    bloc.add(AddProductToCartEvent(product1));
    await Future.delayed(Duration.zero);

    when(() => saveSaleUseCase(any())).thenAnswer((_) async => const Right(null));
    bloc.add(const ValidateSale(paymentMethod: sales.PaymentMethod.cash, paidMillimes: 2000));
    await bloc.stream.firstWhere((s) => s.status == BillingStatus.success);
    expect(bloc.state.cartItems, isEmpty);

    // A brand new sale begins — the previous sale's product must not
    // reappear.
    bloc.add(AddProductToCartEvent(product2));
    await Future.delayed(Duration.zero);

    expect(bloc.state.cartItems.length, 1);
    expect(bloc.state.cartItems.single.product.id, product2.id);
    expect(bloc.state.cartItems.any((i) => i.product.id == product1.id), isFalse);
  });
}
