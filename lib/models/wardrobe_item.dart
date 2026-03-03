class WardrobeItem {
  final String id;
  final String name;
  final String category; // top/bottom/outer/shoes
  final int minTemp;
  final int maxTemp;
  final bool waterproof;
  final String imagePath;

  WardrobeItem({
    required this.id,
    required this.name,
    required this.category,
    required this.minTemp,
    required this.maxTemp,
    required this.waterproof,
    required this.imagePath,
  });
}
