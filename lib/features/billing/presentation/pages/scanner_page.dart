import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';

import '../../../product/presentation/bloc/product_bloc.dart';
import '../../../product/domain/entities/product.dart';
import '../bloc/billing_bloc.dart';

class ScannerPage extends StatefulWidget {
  final bool isContinuous;
  const ScannerPage({super.key, this.isContinuous = false});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final MobileScannerController controller = MobileScannerController(
    formats: [
      BarcodeFormat.ean8,
      BarcodeFormat.ean13,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE
    ],
    detectionSpeed: DetectionSpeed.normal,
  );

  String? _lastDetectedCode;
  int _consecutiveDetections = 0;
  final int _requiredDetections = 2; // Fast but reliable

  bool _isSheetOpen = false;
  String? _activeBarcode;
  int _currentSheetQty = 1;
  StateSetter? _sheetStateSetter;
  DateTime? _lastQuantityIncrementTime;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? rawValue = barcodes.first.rawValue?.trim();
    if (rawValue == null || rawValue.isEmpty) return;

    // Filter by retail barcode lengths
    if (![6, 8, 12, 13].contains(rawValue.length)) return;

    // Logic for Consecutive Detection
    if (_lastDetectedCode == rawValue) {
      _consecutiveDetections++;
    } else {
      _lastDetectedCode = rawValue;
      _consecutiveDetections = 1;
    }

    if (_consecutiveDetections >= _requiredDetections) {
      _consecutiveDetections = 0; // Reset

      if (!widget.isContinuous) {
        // Picker mode
        HapticFeedback.vibrate();
        if (mounted) context.pop(rawValue);
        return;
      }

      // Continuous mode logic (lib1 style)
      if (_isSheetOpen && _activeBarcode == rawValue) {
        // Increment quantity shortcut with 1.5s delay (0.75 + 0.75)
        final now = DateTime.now();
        if (_lastQuantityIncrementTime != null &&
            now.difference(_lastQuantityIncrementTime!).inMilliseconds < 1500) {
          return;
        }
        _lastQuantityIncrementTime = now;

        HapticFeedback.selectionClick();
        _sheetStateSetter?.call(() {
          _currentSheetQty++;
        });
        return;
      }

      if (!_isSheetOpen) {
        HapticFeedback.vibrate();
        _processBarcode(rawValue);
      }
    }
  }

  void _processBarcode(String barcode) {
    setState(() => _isSheetOpen = true);
    _activeBarcode = barcode;
    _currentSheetQty = 1;

    final productState = context.read<ProductBloc>().state;
    final product =
        productState.products.where((p) => p.barcode == barcode).firstOrNull;

    if (product != null) {
      _showProductSheet(product);
    } else {
      _showNotFoundSheet(barcode);
    }
  }

  void _showProductSheet(Product product) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            _sheetStateSetter = setSheetState;
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: product.image.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(File(product.image),
                                    fit: BoxFit.cover),
                              )
                            : const Icon(Icons.inventory_2_outlined,
                                size: 40, color: Colors.grey),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.name,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            Text(product.category,
                                style: TextStyle(color: Colors.blue[700])),
                            Text("${product.price.toStringAsFixed(3)} TND",
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.green)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _qtyBtn(Icons.remove, () => _updateQty(-1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text("$_currentSheetQty",
                            style: const TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold)),
                      ),
                      _qtyBtn(Icons.add, () => _updateQty(1)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: () {
                        // Add to cart N times
                        for (int i = 0; i < _currentSheetQty; i++) {
                          context
                              .read<BillingBloc>()
                              .add(ScanBarcodeEvent(product.barcode));
                        }
                        Navigator.pop(context);
                      },
                      child: const Text("ADD TO CART",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      setState(() {
        _isSheetOpen = false;
        _activeBarcode = null;
      });
    });
  }

  void _showNotFoundSheet(String barcode) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text("Product Not Found",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text("Barcode: $barcode",
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/products/add', extra: barcode);
                  },
                  child: const Text("CREATE PRODUCT"),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      setState(() {
        _isSheetOpen = false;
        _activeBarcode = null;
      });
    });
  }

  void _updateQty(int delta) {
    _sheetStateSetter?.call(() {
      _currentSheetQty = (_currentSheetQty + delta).clamp(1, 99);
    });
  }

  Widget _qtyBtn(IconData icon, VoidCallback onPressed) {
    return IconButton.filledTonal(
      onPressed: onPressed,
      icon: Icon(icon),
      iconSize: 32,
      style: IconButton.styleFrom(
        padding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left,
              size: 28, color: Theme.of(context).primaryColor),
          onPressed: () => context.pop(),
        ),
        title: Text(widget.isContinuous ? "Scan Products" : "Scan Barcode"),
        actions: [
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: controller,
            builder: (context, state, child) {
              final torchIcon = state.torchState == TorchState.on
                  ? Icons.flash_on
                  : Icons.flash_off;
              return IconButton(
                onPressed: () => controller.toggleTorch(),
                icon: Icon(torchIcon,
                    color: state.torchState == TorchState.on
                        ? Colors.yellow
                        : null),
              );
            },
          ),
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: controller,
            builder: (context, state, child) {
              final facingIcon = state.cameraDirection == CameraFacing.front
                  ? Icons.camera_front
                  : Icons.camera_rear;
              return IconButton(
                  onPressed: () => controller.switchCamera(),
                  icon: Icon(facingIcon));
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: controller, onDetect: _onDetect),
          Center(
            child: Container(
              width: 280,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(
                    color: _isSheetOpen ? Colors.green : Colors.white70,
                    width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          if (!_isSheetOpen)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  widget.isContinuous
                      ? "Scanning active..."
                      : "Point at a barcode",
                  style: const TextStyle(
                      color: Colors.white,
                      backgroundColor: Colors.black54,
                      fontSize: 16),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: widget.isContinuous
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pop(context),
              label: const Text("Finish Sale",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              icon: const Icon(Icons.check_circle_outline),
              backgroundColor: Colors.white,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
