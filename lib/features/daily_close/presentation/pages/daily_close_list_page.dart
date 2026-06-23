import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/app_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/money_text.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/entities/daily_close.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/usecases/get_daily_close_list.dart';
import 'package:promsell_pos_ce/features/daily_close/presentation/pages/daily_close_page.dart';

class DailyCloseListPage extends StatelessWidget {
  const DailyCloseListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.dailyCloseHistoryTitle)),
      body: FutureBuilder<List<DailyClose>>(
        future: sl<GetDailyCloseList>().call(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return AppEmptyState(
              icon: Icons.error_outline,
              title: context.l10n.dailyCloseLoadError(
                snapshot.error.toString(),
              ),
            );
          }
          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return AppEmptyState(
              icon: Icons.lock_clock_outlined,
              title: context.l10n.noDailyClosesYet,
            );
          }
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              final formattedDate = DateFormat(
                'dd/MM/yyyy',
              ).format(DateTime.parse(item.closeDate));
              final overShortColor = item.overShortAmount > 0
                  ? Colors.green
                  : item.overShortAmount < 0
                  ? Colors.red
                  : null;
              return ListTile(
                leading: CircleAvatar(child: Text('${item.salesCount}')),
                title: Text(formattedDate),
                subtitle: Text(
                  '${context.l10n.dailyCloseSales(item.salesCount)}  |  ${context.l10n.dailyCloseVoids(item.voidCount)}',
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    MoneyText(value: item.totalRevenue, currency: '฿'),
                    Text(
                      '${item.overShortAmount >= 0 ? '+' : ''}${item.overShortAmount.toStringAsFixed(2)}',
                      style: TextStyle(color: overShortColor, fontSize: 12),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DailyClosePage(date: item.closeDate),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DailyClosePage(date: today)),
          );
        },
        heroTag: 'daily_close_list_fab',
        icon: const Icon(Icons.lock_outline),
        label: Text(context.l10n.closeToday),
      ),
    );
  }
}
