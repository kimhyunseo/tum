import 'package:flutter/material.dart';
import 'models/wardrobe_item.dart';
import 'services/storage_service.dart';
import 'screens/wardrobe_screen.dart';
import 'screens/recommendation_screen.dart';
import 'screens/add_item_screen.dart';
import 'services/weather_service.dart';
import 'services/recommendation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = StorageService();
  final items = await storage.loadItems();
  runApp(HachiApp(initialItems: items));
}

class HachiApp extends StatefulWidget {
  final List<WardrobeItem> initialItems;
  const HachiApp({Key? key, required this.initialItems}) : super(key: key);

  @override
  State<HachiApp> createState() => _HachiAppState();
}

class _HachiAppState extends State<HachiApp> {
  late List<WardrobeItem> items;
  final StorageService storage = StorageService();
  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    items = widget.initialItems;
  }

  void _addItem(WardrobeItem item) async {
    setState(() => items.add(item));
    await storage.saveItems(items);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navKey,
      title: 'Hachi Wardrobe',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.teal).copyWith(secondary: const Color(0xFFFFB74D)),
        scaffoldBackgroundColor: Colors.grey[50],
        // cardTheme compatibility varies by Flutter version; use defaults or override as needed
        elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))),
        textTheme: const TextTheme(titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
      routes: {
        '/wardrobe': (c) => WardrobeScreen(),
        '/recommend': (c) => RecommendationScreen(),
      },
      home: HomeScreen(
        items: items,
        onAddPressed: () async {
          // Use navigatorKey to ensure we have a NavigatorContext
          await _navKey.currentState?.push(MaterialPageRoute(
            builder: (_) => AddItemScreen(onAdd: _addItem),
          ));
        },
        onAddItem: (it) => _addItem(it),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final List<WardrobeItem> items;
  final VoidCallback onAddPressed;
  final void Function(WardrobeItem) onAddItem;
  const HomeScreen({Key? key, required this.items, required this.onAddPressed, required this.onAddItem}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weather = WeatherService();
  final RecommendationService _recommender = RecommendationService();
  Map<String, dynamic>? _weatherData;
  RecommendationResult? _recommendation;
  bool _loadingWeather = true;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    setState(() => _loadingWeather = true);
    final data = await _weather.fetchCurrent(37.5665, 126.9780); // 서울 기본 좌표
    setState(() {
      _weatherData = data;
      _loadingWeather = false;
    });
    // if weather available, compute recommendation
    if (_weatherData != null) {
      try {
        final current = _weatherData!['current_weather'] as Map<String, dynamic>;
        final temp = (current['temperature'] as num).toDouble();
        final precip = (_weatherData!['hourly']?['precipitation_probability'] is List) ? (_weatherData!['hourly']['precipitation_probability'][0] ?? 0) : 0;
        _recommendation = _recommender.recommend(widget.items, temp, precip as int);
      } catch (e) {
        _recommendation = null;
      }
    } else {
      _recommendation = null;
    }
  }

  Color _tempColor(double temp) {
    if (temp <= 0) return Colors.blue.shade700;
    if (temp <= 10) return Colors.blue;
    if (temp <= 20) return Colors.teal;
    if (temp <= 30) return Colors.orange;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    return Scaffold(
      appBar: AppBar(title: const Text('Hachi Wardrobe')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: GestureDetector(
              onTap: () {
                if (_weatherData != null) {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => RecommendationScreen()));
                }
              },
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: _loadingWeather
                      ? Row(children: const [CircularProgressIndicator(), SizedBox(width: 12), Text('날씨 불러오는 중...')])
                      : _weatherData == null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('날씨 정보를 불러올 수 없습니다.'),
                                TextButton(onPressed: _loadWeather, child: const Text('다시시도'))
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildWeatherCard(),
                                const SizedBox(height: 12),
                                _buildRecommendationSummary(),
                              ],
                            ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(child: Text('Items: ${items.length}')),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => WardrobeScreen())),
                  child: const Text('옷장')),
              ElevatedButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => RecommendationScreen())),
                  child: const Text('추천')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOptions(context),
        tooltip: '아이템 추가',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('사진으로 추가'),
              onTap: () {
                Navigator.of(context).pop();
                widget.onAddPressed();
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('수동 입력으로 추가'),
              onTap: () {
                Navigator.of(context).pop();
                widget.onAddPressed();
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_awesome),
              title: const Text('샘플 데이터 추가'),
              onTap: () async {
                Navigator.of(context).pop();
                // add sample items via provided callback
                final samples = [
                  WardrobeItem(id: 'sample1', name: '흰 티셔츠', category: 'top', minTemp: 15, maxTemp: 30, waterproof: false, imagePath: null),
                  WardrobeItem(id: 'sample2', name: '청바지', category: 'bottom', minTemp: 5, maxTemp: 30, waterproof: false, imagePath: null),
                  WardrobeItem(id: 'sample3', name: '경량 패딩', category: 'outer', minTemp: -5, maxTemp: 10, waterproof: false, imagePath: null),
                  WardrobeItem(id: 'sample4', name: '스니커즈', category: 'shoes', minTemp: 0, maxTemp: 30, waterproof: false, imagePath: null),
                ];
                for (final s in samples) {
                  widget.onAddItem(s);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    try {
      final current = _weatherData!['current_weather'] as Map<String, dynamic>;
      final temp = (current['temperature'] as num).toDouble();
      final precip = (_weatherData!['hourly']?['precipitation_probability'] is List) ? (_weatherData!['hourly']['precipitation_probability'][0] ?? 0) : 0;
      final color = _tempColor(temp);
      final weatherCode = (current['weathercode'] is int) ? current['weathercode'] as int : (current['weathercode'] is num ? (current['weathercode'] as num).toInt() : null);
      final iconInfo = _weatherIconForCode(weatherCode);
      return Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(colors: [Color.fromRGBO(color.red, color.green, color.blue, 0.15), Color.fromRGBO(color.red, color.green, color.blue, 0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(iconInfo.icon, color: color, size: 22),
                const SizedBox(height: 4),
                Text('${temp.round()}°', style: TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [Icon(Icons.thermostat, size: 16, color: Colors.grey[600]), const SizedBox(width:6), Text('현재 기온', style: TextStyle(fontSize: 14, color: Colors.grey[600]))]),
                const SizedBox(height: 4),
                Text('${temp}°C', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(children:[Icon(Icons.umbrella, size:14, color:Colors.grey[700]), const SizedBox(width:6), Text('강수 확률: ${precip}%', style: TextStyle(fontSize: 12, color: Colors.grey[700]))])
              ],
            ),
          ),
          IconButton(onPressed: _loadWeather, icon: const Icon(Icons.refresh))
        ],
      );
    } catch (e) {
      return const Text('날씨 표시 오류');
    }
  }

  Widget _buildRecommendationSummary() {
    if (_recommendation == null) return const SizedBox();
    final rec = _recommendation!;
    String summary;
    final top = rec.choices['top']?.item?.name ?? rec.choices['top']?.reason ?? '-';
    final bottom = rec.choices['bottom']?.item?.name ?? rec.choices['bottom']?.reason ?? '-';
    final outer = rec.choices['outer']?.item?.name ?? rec.choices['outer']?.reason ?? '-';
    final shoes = rec.choices['shoes']?.item?.name ?? rec.choices['shoes']?.reason ?? '-';
    summary = '$top · $bottom · $outer · $shoes';
    String confLabel = '신뢰도: ' + (rec.confidence == Confidence.HIGH ? '높음' : rec.confidence == Confidence.MEDIUM ? '보통' : '낮음');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('추천 조합', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(summary),
        const SizedBox(height: 6),
        Text(confLabel, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => RecommendationScreen())), child: const Text('자세히 보기')))
      ],
    );
  }

  // Helper for mapping Open-Meteo weather codes to an icon + label
  _WeatherIconInfo _weatherIconForCode(int? code) {
    // default
    var icon = Icons.wb_sunny;
    var label = '맑음';
    if (code == null) return _WeatherIconInfo(icon, label);
    if (code == 0) {
      icon = Icons.wb_sunny;
      label = '맑음';
    } else if (code == 1 || code == 2 || code == 3) {
      icon = Icons.wb_cloudy;
      label = '구름';
    } else if (code >= 45 && code <= 48) {
      icon = Icons.blur_on;
      label = '안개';
    } else if ((code >= 51 && code <= 67) || (code >= 80 && code <= 86)) {
      icon = Icons.umbrella;
      label = '비';
    } else if (code >= 71 && code <= 77) {
      icon = Icons.ac_unit;
      label = '눈';
    } else if (code >= 95 && code <= 99) {
      icon = Icons.flash_on;
      label = '천둥';
    } else {
      icon = Icons.wb_cloudy;
      label = '흐림';
    }
    return _WeatherIconInfo(icon, label);
  }

}

class _WeatherIconInfo {
  final IconData icon;
  final String label;
  _WeatherIconInfo(this.icon, this.label);
}
