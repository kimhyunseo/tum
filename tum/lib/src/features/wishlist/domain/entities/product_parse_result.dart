import 'package:equatable/equatable.dart';

class ProductParseResult extends Equatable {
  final String? title;
  final double? price;
  final String? imageUrl;
  final String? sourceUrl;
  final String? category;
  final String? rawHtml;
  final bool success;
  final String? currency;

  const ProductParseResult({
    this.title,
    this.price,
    this.imageUrl,
    this.sourceUrl,
    this.category,
    this.rawHtml,
    this.success = false,
    this.currency,
  });

  @override
  List<Object?> get props => [title, price, imageUrl, sourceUrl, category, rawHtml, success, currency];
}
