import 'dart:io';
import 'package:flutter/material.dart';
import '../models/wardrobe_item.dart';
import '../services/storage_service.dart';
import '../services/weather_service.dart';
import '../services/recommendation_service.dart';
import 'add_item_screen.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({Key? key}) : super(key: key);

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  final StorageService storage = StorageService();
  final WeatherService weather = WeatherService();
  final RecommendationService recommender = RecommendationService();
  List<WardrobeItem> items = [];
  bool loading = true;
  double? temp;
  double? precipProb;
  RecommendationResult? _result;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    final l = await storage.loadItems();
    setState(() => items = l);
    // fallback coords (Seoul)
    final data = await weather.fetchCurrent(37.5665, 126.9780);
    double? t;
    double? p;
    try {
      t = (data?['current_weather']?['temperature'])?.toDouble();
    } catch (e) {}
    try {
      // get precipitation_probability from hourly if present (take first)
      final hourly = data?['hourly'];
      if (hourly != null && hourly['precipitation_probability'] != null) {
        final arr = hourly['precipitation_probability'] as List<dynamic>;
        p = (arr.isNotEmpty ? (arr[0] as num).toDouble() : 0.0);
      }
    } catch (e) {}
    setState(() {
      temp = t;
      precipProb = p ?? 0.0;
      loading = false;
    });

    if (temp != null) {
      final res = recommender.recommend(items, temp!, (precipProb ?? 0).toInt());
      setState(() => _result = res);
    }
  }

  Future<void> _editItem(WardrobeItem item) async {
    final updated = await Navigator.of(context).push<WardrobeItem?>(MaterialPageRoute(builder: (_) => AddItemScreen(onAdd: (it) {}, existing: item)));
    if (updated != null) {
      // reload storage
      final l = await storage.loadItems();
      setState(() => items = l);
      // recompute
      if (temp != null) {
        _result = recommender.recommend(items, temp!, (precipProb ?? 0).toInt());
      }
    }
  }

  Widget _buildChoiceCard(String title, WardrobeChoice choice) {
    final item = choice.item;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), gradient: LinearGradient(colors: [Colors.grey.shade50, Colors.grey.shade100])),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: item != null
                    ? (item.imagePath != null ? Image.file(File(item.imagePath!), fit: BoxFit.cover) : const Icon(Icons.checkroom, size: 36, color: Colors.black54))
                    : const Icon(Icons.help_outline, size: 36, color: Colors.black38),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(item?.name ?? choice.reason ?? '-', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  if (choice.isSubstitute) Text('대체 제안: ${choice.reason ?? ''}', style: const TextStyle(fontSize: 12, color: Colors.orange)),
                ],
              ),
            ),
            if (item != null)
              IconButton(onPressed: () => _editItem(item), icon: const Icon(Icons.edit))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('추천 상세')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('현재 기온: ${temp?.toStringAsFixed(1) ?? '-'} °C'),
                  Text('강수 확률: ${precipProb?.toStringAsFixed(0) ?? '-'} %'),
                  const SizedBox(height: 12),
                  if (_result == null) const Text('추천을 생성할 수 없습니다.'),
                  if (_result != null) ...[
                    _buildChoiceCard('상의', _result!.choices['top']!),
                    const SizedBox(height: 8),
                    _buildChoiceCard('하의', _result!.choices['bottom']!),
                    const SizedBox(height: 8),
                    _buildChoiceCard('아우터', _result!.choices['outer']!),
                    const SizedBox(height: 8),
                    _buildChoiceCard('신발', _result!.choices['shoes']!),
                    const SizedBox(height: 12),
                    Text('신뢰도: ' + (_result!.confidence == Confidence.HIGH ? '높음' : _result!.confidence == Confidence.MEDIUM ? '보통' : '낮음')),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(onPressed: () async {
                          // save as favorite (stub)
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('즐겨찾기로 저장됨')));
                        }, child: const Text('즐겨찾기 저장')),
                        const SizedBox(width: 8),
                        TextButton(onPressed: () {
                          // recompute
                          if (temp != null) {
                            setState(() {
                              _result = recommender.recommend(items, temp!, (precipProb ?? 0).toInt());
                            });
                          }
                        }, child: const Text('다시추천'))
                      ],
                    )
                  ]
                ],
              ),
            ),
    );
  }
}
