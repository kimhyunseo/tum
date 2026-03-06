import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlparser;
import '../domain/entities/product_parse_result.dart';
import 'dart:convert';

class ProductParser {
  static Future<ProductParseResult> parseFromUrl(String url) async {
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode != 200) {
        return ProductParseResult(sourceUrl: url, rawHtml: null, success: false);
      }
      final doc = htmlparser.parse(res.body);
      final raw = res.body;

      // Try JSON-LD
      final jsonLd = doc.getElementsByTagName('script')
          .where((e) => e.attributes['type'] == 'application/ld+json')
          .map((e) => e.text)
          .toList();
      for (final s in jsonLd) {
        try {
          final data = json.decode(s);
          if (data is Map && data['@type'] != null && (data['@type'] == 'Product' || data['@type'] == 'product')) {
            final name = data['name'] as String?;
            double? price;
            String? currency;
            if (data['offers'] != null) {
              final offers = data['offers'];
              price = offers['price'] != null ? double.tryParse(offers['price'].toString()) : null;
              currency = offers['priceCurrency']?.toString();
            }
            final image = data['image'] is String ? data['image'] : (data['image'] is List ? (data['image'] as List).first : null);
            final category = data['category']?.toString();
            return ProductParseResult(title: name, price: price, currency: currency, imageUrl: image, category: category, sourceUrl: url, rawHtml: raw, success: true);
          }
        } catch (e) {
          // ignore JSON errors
        }
      }

      // Try Open Graph
      String? ogTitle;
      String? ogImage;
      String? priceStr;
      String? currency;
      final metas = doc.getElementsByTagName('meta');
      for (final m in metas) {
        final prop = m.attributes['property'] ?? m.attributes['name'];
        final content = m.attributes['content'];
        if (prop == null || content == null) continue;
        if (prop.toLowerCase() == 'og:title' && ogTitle == null) ogTitle = content;
        if (prop.toLowerCase() == 'og:image' && ogImage == null) ogImage = content;
        if (prop.toLowerCase() == 'product:price:amount' && priceStr == null) priceStr = content;
        if (prop.toLowerCase() == 'product:price:currency' && currency == null) currency = content;
      }
      double? price;
      if (priceStr != null) price = double.tryParse(priceStr.replaceAll(',', ''));
      String? title = ogTitle ?? doc.getElementsByTagName('title')
          .map((e) => e.text)
          .firstWhere((t) => t.trim().isNotEmpty, orElse: () => '');
      if (title.isEmpty) title = null;

      // Price regex fallback
      if (price == null) {
        final regex = RegExp(r'([₩$€£]\s?[0-9,]+(?:\.[0-9]{1,2})?)');
        final match = regex.firstMatch(res.body);
        if (match != null) {
          final matched = match.group(1)!;
          // strip non-digit
          final digits = matched.replaceAll(RegExp(r'[^0-9\.]'), '');
          price = double.tryParse(digits.replaceAll(',', ''));
        }
      }

      return ProductParseResult(title: title, price: price, currency: currency, imageUrl: ogImage, category: null, sourceUrl: url, rawHtml: raw, success: true);
    } catch (e) {
      return ProductParseResult(sourceUrl: url, rawHtml: null, success: false);
    }
  }
}
