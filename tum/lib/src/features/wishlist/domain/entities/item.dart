import 'package:equatable/equatable.dart';

class Item extends Equatable {
  final String id;
  final String title;
  final double price;
  final String? imageUrl;
  final String? url;
  final String category;
  final DateTime createdAt;
  final String? note;
  final String status;
  final int delayDays;

  const Item({
    required this.id,
    required this.title,
    required this.price,
    this.imageUrl,
    this.url,
    required this.category,
    required this.createdAt,
    this.note,
    this.status = 'thinking',
    this.delayDays = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'price': price,
    'imageUrl': imageUrl,
    'url': url,
    'category': category,
    'createdAt': createdAt.toIso8601String(),
    'note': note,
    'status': status,
    'delayDays': delayDays,
  };

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json['id'],
    title: json['title'],
    price: json['price'],
    imageUrl: json['imageUrl'],
    url: json['url'],
    category: json['category'],
    createdAt: DateTime.parse(json['createdAt']),
    note: json['note'],
    status: json['status'] ?? 'thinking',
    delayDays: json['delayDays'] ?? 0,
  );

  @override
  List<Object?> get props => [id, title, price, imageUrl, url, category, createdAt, note, status, delayDays];
}
