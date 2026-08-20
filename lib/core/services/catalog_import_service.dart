import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../../features/product/data/models/product_model.dart';
import '../data/hive_database.dart';

class CatalogImportService {
  static Future<void> importIfNeeded() async {
    final settingsBox = HiveDatabase.settingsBox;
    final bool isImported = settingsBox.get('catalog_imported', defaultValue: false);

    if (isImported) return;

    try {
      final String content = await rootBundle.loadString('assets/tunisian_products.jsonl');
      final List<String> lines = content.split('\n');
      final productBox = HiveDatabase.productBox;
      
      // Get existing barcodes to avoid duplicates
      final existingBarcodes = productBox.values
          .map((p) => p.barcode)
          .where((b) => b != null && b.isNotEmpty)
          .toSet();

      for (String line in lines) {
        if (line.trim().isEmpty) continue;
        try {
          final Map<String, dynamic> json = jsonDecode(line);
          final String? barcode = json['barcode']?.toString();
          
          if (barcode == null || barcode.isEmpty) continue;
          if (existingBarcodes.contains(barcode)) continue;

          final product = ProductModel(
            id: const Uuid().v4(),
            name: json['name'] ?? 'Inconnu',
            barcode: barcode,
            price: 0.0,
            purchasePrice: 0.0,
            stock: 0,
            brand: json['brands'] == 'undefined' ? null : json['brands'],
            category: json['categories'] == 'undefined' ? null : json['categories'],
            unit: json['quantity'] == 'undefined' ? null : json['quantity'],
            lowStockThreshold: 5,
          );

          await productBox.put(product.id, product);
          existingBarcodes.add(barcode);
        } catch (e) {
          // Skip malformed lines
          continue;
        }
      }

      await settingsBox.put('catalog_imported', true);
    } catch (e) {
      print('Error importing catalog: $e');
    }
  }
}
