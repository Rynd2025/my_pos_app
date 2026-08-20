import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../../../../core/data/hive_database.dart';
import '../../domain/repositories/product_import_repository.dart';
import '../models/product_model.dart';

class ProductImportRepositoryImpl implements ProductImportRepository {
  final http.Client client;

  ProductImportRepositoryImpl({required this.client});

  @override
  Stream<double> importTunisianProducts() async* {
    int currentPage = 1;
    bool hasMore = true;
    const int pageSize = 100;

    final box = HiveDatabase.productBox;
    
    // Create a set of existing barcodes to avoid O(N) search and duplicates
    final existingBarcodes = box.values
        .map((p) => p.barcode)
        .where((b) => b != null && b.isNotEmpty)
        .toSet();

    while (hasMore) {
      try {
        // Using world.openfoodfacts.org for the global search API
        // tag_0=tunisia covers most products tagged with Tunisia
        final response = await client.get(
          Uri.parse(
              'https://world.openfoodfacts.org/cgi/search.pl?action=process&tagtype_0=countries&tag_contains_0=contains&tag_0=tunisia&json=true&page=$currentPage&page_size=$pageSize'),
          headers: {
            'User-Agent': 'TunisianPOS - Android - Version 1.1',
            'From': 'contact@myposapp.tn' // OFF recommends adding a contact email
          },
        ).timeout(const Duration(seconds: 45));

        if (response.statusCode == 200) {
          final data = json.decode(utf8.decode(response.bodyBytes));
          final List productsList = data['products'] ?? [];
          final int totalCount = data['count'] ?? 0;
          
          if (productsList.isEmpty) {
            hasMore = false;
            break;
          }

          int addedInThisPage = 0;
          for (var item in productsList) {
            final String? barcode = item['code']?.toString();
            if (barcode == null || barcode.isEmpty) continue;

            if (existingBarcodes.contains(barcode)) continue;

            final product = ProductModel(
              id: const Uuid().v4(),
              name: item['product_name'] ?? item['product_name_fr'] ?? item['product_name_en'] ?? 'Inconnu',
              barcode: barcode,
              price: 0.0,
              purchasePrice: 0.0,
              stock: 0,
              brand: item['brands'],
              category: item['categories'],
              unit: item['quantity'],
            );

            await box.put(product.id, product);
            existingBarcodes.add(barcode);
            addedInThisPage++;
          }

          // Calculate progress based on items processed vs total count
          // progress = (current_page * page_size) / total_count
          double progress = (currentPage * pageSize) / totalCount;
          if (progress > 0.99) progress = 0.99; // Keep 1.0 for the very end
          yield progress;

          // If we got a full page, try the next one
          if (productsList.length >= pageSize) {
            currentPage++;
            // OFF API safety limit for search results is often 1000 items without specific keys,
            // but for tagged search it should work. Let's limit to 100 pages (10,000 products) for safety.
            if (currentPage > 100) hasMore = false;
          } else {
            hasMore = false;
          }
          
          // Small delay to respect API rate limits
          await Future.delayed(const Duration(milliseconds: 500));
        } else {
          // Non-200 status, stop
          hasMore = false;
        }
      } catch (e) {
        // Error occurred, stop to avoid infinite loop
        hasMore = false;
      }
    }
    
    // Final progress and refresh
    yield 1.0;
  }
}
