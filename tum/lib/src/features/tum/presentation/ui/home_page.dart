import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tum/src/core/theme/app_colors.dart';
import '../providers/purchase_provider.dart';
import '../../domain/entities/purchase_attempt.dart';
import '../providers/budget_goal_provider.dart';
import 'purchase_attempt_page.dart';
import 'link_import_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final Set<String> _shownDecision = {};

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(purchaseListProvider);
    final goal = ref.watch(budgetGoalProvider);

    return recordsAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
      data: (records) {
        final totalSpent = records
            .where((r) => r.status == 'bought')
            .fold<double>(0, (sum, r) => sum + r.amount);

        final thinking = records.where((r) => r.status == 'thinking').toList();
        final due = thinking
            .where((r) => r.thinkUntil != null && r.thinkUntil!.isBefore(DateTime.now()))
            .toList();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          for (final r in due) {
            if (_shownDecision.contains(r.id)) continue;
            _shownDecision.add(r.id);
            _showDecisionDialog(r.id, r.title);
            break;
          }
        });

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('T.U.M', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2)),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded),
                onPressed: () {},
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async => ref.refresh(purchaseListProvider),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _summaryCard(
                        title: '이번 달 지출',
                        value: '${totalSpent.toStringAsFixed(0)}원',
                        icon: Icons.account_balance_wallet_rounded,
                        color: AppColors.secondary,
                        textColor: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _summaryCard(
                        title: '절약한 금액',
                        value: '${_calculateSaved(records).toStringAsFixed(0)}원',
                        icon: Icons.savings_rounded,
                        color: AppColors.savingsLight,
                        textColor: AppColors.savings,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('🔥 현재 고민 중', 
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    TextButton(
                      onPressed: () {}, 
                      child: const Text('전체보기', style: TextStyle(color: AppColors.primary))),
                  ],
                ),
                const SizedBox(height: 12),
                if (thinking.isEmpty)
                  _emptyState(context)
                else
                  ...thinking.take(3).map((r) => _thinkingItemCard(context, r)),
                
                const SizedBox(height: 32),
                const Text('🚀 빠른 액션', 
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                const SizedBox(height: 16),
                _actionButton(
                  context,
                  title: '새로운 고민 시작하기',
                  subtitle: '살까 말까 망설여진다면?',
                  icon: Icons.add_task_rounded,
                  isPrimary: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PurchaseAttemptPage()),
                  ),
                ),
                const SizedBox(height: 12),
                _actionButton(
                  context,
                  title: '상품 링크 붙여넣기',
                  subtitle: '쿠팡, 네이버 쇼핑 링크 분석',
                  icon: Icons.link_rounded,
                  isPrimary: false,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LinkInputPage()),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  double _calculateSaved(List<PurchaseAttempt> records) {
    return records
        .where((r) => r.status == 'skipped')
        .fold<double>(0, (sum, r) => sum + r.amount);
  }

  Widget _emptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE0E0E0).withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Icon(Icons.chat_bubble_outline_rounded, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('아직 고민 중인 상품이 없어요', 
            style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('현명한 소비의 시작, T.U.M과 함께해요!', 
            style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor, size: 28),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor.withOpacity(0.7))),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(value, 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textColor)),
          ),
        ],
      ),
    );
  }

  Widget _thinkingItemCard(BuildContext context, PurchaseAttempt r) {
    final days = _daysLeft(r.thinkUntil);
    final progress = 1.0 - (days / 15.0).clamp(0.0, 1.0); // Assume max 15 days

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF2E7D32).withOpacity(0.1)),
                minHeight: 4,
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8E9),
                  shape: BoxShape.circle,
                ),
                child: Text('D-$days', 
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF2E7D32))),
              ),
              title: Text(r.title, 
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              subtitle: Text('${r.category} | ${r.amount.toStringAsFixed(0)}원',
                style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF2E7D32) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isPrimary ? null : Border.all(color: const Color(0xFFE0E0E0)),
          boxShadow: isPrimary ? [
            BoxShadow(
              color: const Color(0xFF2E7D32).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ] : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isPrimary ? Colors.white.withOpacity(0.2) : const Color(0xFFF1F8E9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: isPrimary ? Colors.white : const Color(0xFF2E7D32)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, 
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold, 
                      color: isPrimary ? Colors.white : const Color(0xFF2C3E50))),
                  Text(subtitle, 
                    style: TextStyle(
                      fontSize: 12, 
                      color: isPrimary ? Colors.white.withOpacity(0.8) : Colors.grey[500])),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, 
              color: isPrimary ? Colors.white.withOpacity(0.5) : Colors.grey[300]),
          ],
        ),
      ),
    );
  }

  int _daysLeft(DateTime? target) {
    if (target == null) return 0;
    final diff = target.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  Future<void> _showDecisionDialog(String id, String title) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('구매 결정'),
        content: Text('"$title" 구매할까요?'),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(purchaseListProvider.notifier).updateStatus(id, 'skipped');
              Navigator.pop(context);
            },
            child: const Text('안 함'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(purchaseListProvider.notifier).updateStatus(id, 'bought');
              Navigator.pop(context);
            },
            child: const Text('구매'),
          ),
        ],
      ),
    );
  }
}
