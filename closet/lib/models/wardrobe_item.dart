import 'dart:convert';

class WardrobeItem {
  final String id;
  final String name;
  final String category; // top/bottom/outer/shoes
  final int minTemp;
  final int maxTemp;
  final bool waterproof;
  final String? imagePath;

  WardrobeItem({
    required this.id,
    required this.name,
    required this.category,
    required this.minTemp,
    required this.maxTemp,
    required this.waterproof,
    this.imagePath,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'minTemp': minTemp,
        'maxTemp': maxTemp,
        'waterproof': waterproof,
        'imagePath': imagePath,
      };

  factory WardrobeItem.fromJson(Map<String, dynamic> j) => WardrobeItem(
        id: j['id'] as String,
        name: j['name'] as String,
        category: j['category'] as String,
        minTemp: (j['minTemp'] ?? 0) as int,
        maxTemp: (j['maxTemp'] ?? 40) as int,
        waterproof: j['waterproof'] ?? false,
        imagePath: j['imagePath'],
      );

  @override
  String toString() => json.encode(toJson());
}
