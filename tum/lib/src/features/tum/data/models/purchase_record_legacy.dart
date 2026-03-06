import 'dart:convert';

class PurchaseRecord {
  final String id;
  final String title;
  final String category;
  final double amount;
  final String emotion;
  final DateTime createdAt;
  final DateTime? thinkUntil;
  final String status; // thinking | bought | skipped
  final String? imageUrl;
  final String? sourceUrl;

  PurchaseRecord({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.emotion,
    required this.createdAt,
    this.thinkUntil,
    this.status = 'thinking',
    this.imageUrl,
    this.sourceUrl,
  });

  PurchaseRecord copyWith({
    String? status,
    String? imageUrl,
    String? sourceUrl,
  }) {
    return PurchaseRecord(
      id: id,
      title: title,
      category: category,
      amount: amount,
      emotion: emotion,
      createdAt: createdAt,
      thinkUntil: thinkUntil,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      sourceUrl: sourceUrl ?? this.sourceUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'amount': amount,
        'emotion': emotion,
        'createdAt': createdAt.toIso8601String(),
        'thinkUntil': thinkUntil?.toIso8601String(),
        'status': status,
        'imageUrl': imageUrl,
        'sourceUrl': sourceUrl,
      };

  static PurchaseRecord fromJson(Map<String, dynamic> json) {
    return PurchaseRecord(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      amount: (json['amount'] as num).toDouble(),
      emotion: json['emotion'],
      createdAt: DateTime.parse(json['createdAt']),
      thinkUntil: json['thinkUntil'] != null
          ? DateTime.parse(json['thinkUntil'])
          : null,
      status: json['status'] ?? 'thinking',
      imageUrl: json['imageUrl'],
      sourceUrl: json['sourceUrl'],
    );
  }

  String toRaw() => jsonEncode(toJson());
  static PurchaseRecord fromRaw(String raw) =>
      PurchaseRecord.fromJson(jsonDecode(raw));
}
