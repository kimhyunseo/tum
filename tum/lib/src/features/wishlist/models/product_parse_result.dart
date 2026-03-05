class ProductParseResult {
  final String? title;
  final double? price;
  final String? currency;
  final String? imageUrl;
  final String? category;
  final String sourceUrl;
  final String? rawHtml;
  final bool success;

  ProductParseResult({
    this.title,
    this.price,
    this.currency,
    this.imageUrl,
    this.category,
    required this.sourceUrl,
    this.rawHtml,
    this.success = false,
  });
}
