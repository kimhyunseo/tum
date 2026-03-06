import 'package:equatable/equatable.dart';

class PurchaseAttempt extends Equatable {
  final String id;
  final String title;
  final String category;
  final double amount;
  final String emotion;
  final DateTime createdAt;
  final DateTime? thinkUntil;
  final String status; // 'thinking', 'bought', 'skipped'
  final String? imageUrl;
  final String? sourceUrl;

  const PurchaseAttempt({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.emotion,
    required this.createdAt,
    this.thinkUntil,
    required this.status,
    this.imageUrl,
    this.sourceUrl,
  });

  @override
  List<Object?> get props => [id, title, category, amount, emotion, createdAt, thinkUntil, status, imageUrl, sourceUrl];

  PurchaseAttempt copyWith({
    String? status,
    DateTime? thinkUntil,
  }) {
    return PurchaseAttempt(
      id: id,
      title: title,
      category: category,
      amount: amount,
      emotion: emotion,
      createdAt: createdAt,
      thinkUntil: thinkUntil ?? this.thinkUntil,
      status: status ?? this.status,
      imageUrl: imageUrl,
      sourceUrl: sourceUrl,
    );
  }
}
