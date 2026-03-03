import '../models/wardrobe_item.dart';

enum Confidence { HIGH, MEDIUM, LOW }

class WardrobeChoice {
  final WardrobeItem? item;
  final bool isSubstitute;
  final String? reason;

  WardrobeChoice({this.item, this.isSubstitute = false, this.reason});
}

class RecommendationResult {
  final Map<String, WardrobeChoice> choices;
  final Confidence confidence;

  RecommendationResult({required this.choices, required this.confidence});
}

class RecommendationService {
  RecommendationResult recommend(List<WardrobeItem> items, double temp, int precip) {
    // categories in order
    final cats = ['top', 'bottom', 'outer', 'shoes'];
    final Map<String, WardrobeChoice> choices = {};

    WardrobeChoice pickFor(String cat) {
      // filter by category and temperature range
      List<WardrobeItem> candidates = items.where((i) => i.category == cat && i.minTemp <= temp && i.maxTemp >= temp).toList();
      // if precip high, prefer waterproof for outer/shoes
      if (precip > 30 && (cat == 'outer' || cat == 'shoes')) {
        final wf = candidates.where((i) => i.waterproof).toList();
        if (wf.isNotEmpty) candidates = wf;
      }
      if (candidates.isNotEmpty) {
        candidates.sort((a, b) {
          final amid = (a.minTemp + a.maxTemp) / 2.0;
          final bmid = (b.minTemp + b.maxTemp) / 2.0;
          final adiff = (amid - temp).abs();
          final bdiff = (bmid - temp).abs();
          // prefer closer mid temp, then waterproof, then id
          final cmp = adiff.compareTo(bdiff);
          if (cmp != 0) return cmp;
          if (a.waterproof != b.waterproof) return a.waterproof ? -1 : 1;
          return a.id.compareTo(b.id);
        });
        return WardrobeChoice(item: candidates.first, isSubstitute: false);
      }

      // no direct candidate -> try same-category closest by midTemp
      final same = items.where((i) => i.category == cat).toList();
      if (same.isNotEmpty) {
        same.sort((a, b) {
          final amid = (a.minTemp + a.maxTemp) / 2.0;
          final bmid = (b.minTemp + b.maxTemp) / 2.0;
          final adiff = (amid - temp).abs();
          final bdiff = (bmid - temp).abs();
          if (adiff != bdiff) return adiff.compareTo(bdiff);
          return a.id.compareTo(b.id);
        });
        return WardrobeChoice(item: same.first, isSubstitute: true, reason: '온도 근접 대체');
      }

      // cross-category heuristics
      if (cat == 'top') {
        final outer = items.where((i) => i.category == 'outer').toList();
        if (outer.isNotEmpty) {
          outer.sort((a, b) {
            final amid = (a.minTemp + a.maxTemp) / 2.0;
            final bmid = (b.minTemp + b.maxTemp) / 2.0;
            return (amid - temp).abs().compareTo((bmid - temp).abs());
          });
          return WardrobeChoice(item: outer.first, isSubstitute: true, reason: '아우터를 상의로 활용');
        }
      }

      if (cat == 'shoes') {
        // fallback textual
        return WardrobeChoice(item: null, isSubstitute: true, reason: '방수 신발 권장');
      }

      // generic textual fallback
      return WardrobeChoice(item: null, isSubstitute: true, reason: '추천 아이템이 없습니다');
    }

    for (final c in cats) {
      choices[c] = pickFor(c);
    }

    // compute confidence
    final primaryCount = choices.values.where((w) => w.item != null && !w.isSubstitute).length;
    final substituteCount = choices.values.where((w) => w.isSubstitute && w.item != null).length;
    final textualFallbacks = choices.values.where((w) => w.item == null).length;

    Confidence conf = Confidence.LOW;
    if (primaryCount == 4) conf = Confidence.HIGH;
    else if (primaryCount >= 2 && textualFallbacks == 0) conf = Confidence.MEDIUM;
    else conf = Confidence.LOW;

    return RecommendationResult(choices: choices, confidence: conf);
  }
}
