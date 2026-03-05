class Item {
  String id;
  String title;
  String? note;
  double? price;
  String? imagePath;
  DateTime createdAt;
  int delayDays; // waiting period in days
  DateTime remindAt;
  String status; // pending / bought / gaveup

  Item({
    required this.id,
    required this.title,
    this.note,
    this.price,
    this.imagePath,
    DateTime? createdAt,
    this.delayDays = 7,
    DateTime? remindAt,
    this.status = 'pending',
  })  : this.createdAt = createdAt ?? DateTime.now(),
        this.remindAt = remindAt ?? DateTime.now().add(Duration(days: delayDays));

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'note': note,
        'price': price,
        'imagePath': imagePath,
        'createdAt': createdAt.toIso8601String(),
        'delayDays': delayDays,
        'remindAt': remindAt.toIso8601String(),
        'status': status,
      };

  static Item fromJson(Map<String, dynamic> j) => Item(
        id: j['id'],
        title: j['title'],
        note: j['note'],
        price: j['price'] != null ? (j['price'] as num).toDouble() : null,
        imagePath: j['imagePath'],
        createdAt: DateTime.parse(j['createdAt']),
        delayDays: j['delayDays'] ?? 7,
        remindAt: DateTime.parse(j['remindAt']),
        status: j['status'] ?? 'pending',
      );
}
