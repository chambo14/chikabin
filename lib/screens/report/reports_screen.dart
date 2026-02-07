import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/models/transaction_model.dart';
import '../../data/providers/transaction_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_filex/open_filex.dart';
import '../../data/services/file_storage_service.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  DateTime selectedMonth = DateTime.now();
  int selectedYear = DateTime.now().year;
  bool showYearlyView = false; // ← NOUVEAU : Toggle entre mensuel/annuel
  bool isGeneratingPdf = false;

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);
    final monthStats = ref.watch(statsProvider(selectedMonth));
    final yearStats = ref.watch(yearStatsProvider(selectedYear));

    // ← Choisir les stats selon la vue
    final displayStats = showYearlyView ? yearStats : monthStats;

    // Filtrer les transactions
    final filteredTransactions = showYearlyView
        ? transactions.where((t) => t.date.year == selectedYear).toList()
        : _getMonthTransactions(transactions);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Rapports',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: Icon(
              showYearlyView ? Icons.calendar_today : Icons.calendar_month_outlined,
            ),
            onPressed: () {
              if (showYearlyView) {
                _selectYear(context);
              } else {
                _selectMonth(context);
              }
            },
          ),
          IconButton(
            icon: isGeneratingPdf
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : const Icon(Icons.picture_as_pdf),
            onPressed: isGeneratingPdf
                ? null
                : () => _generatePdfReport(filteredTransactions, displayStats),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ← NOUVEAU : Toggle Mensuel/Annuel
            _buildViewToggle(),

            const SizedBox(height: 16),

            // Sélecteur de période (mois ou année)
            _buildPeriodSelector(),

            const SizedBox(height: 20),

            // Résumé général
            _buildSummaryCards(displayStats),

            const SizedBox(height: 20),

            // Graphique en camembert (répartition par catégorie)
            _buildCategoryPieChart(filteredTransactions),

            const SizedBox(height: 20),

            // Graphique en barres (évolution)
            showYearlyView
                ? _buildMonthlyBarChart(filteredTransactions)
                : _buildDailyBarChart(filteredTransactions),

            const SizedBox(height: 20),

            // Graphique linéaire (tendance)
            _buildTrendLineChart(filteredTransactions),

            const SizedBox(height: 20),

            // Top catégories de dépenses
            _buildTopCategories(filteredTransactions),
          ],
        ),
      ),
    );
  }

  // ← NOUVEAU : Toggle Mensuel/Annuel
  Widget _buildViewToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              label: 'Mensuel',
              isSelected: !showYearlyView,
              onTap: () {
                setState(() {
                  showYearlyView = false;
                });
              },
              icon: Icons.calendar_month,
            ),
          ),
          Expanded(
            child: _buildToggleButton(
              label: 'Annuel',
              isSelected: showYearlyView,
              onTap: () {
                setState(() {
                  showYearlyView = true;
                });
              },
              icon: Icons.calendar_today,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<TransactionModel> _getMonthTransactions(List<TransactionModel> transactions) {
    final startOfMonth = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final endOfMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);

    return transactions.where((t) =>
    t.date.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
        t.date.isBefore(endOfMonth.add(const Duration(days: 1)))
    ).toList();
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                if (showYearlyView) {
                  selectedYear--;
                } else {
                  selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
                }
              });
            },
          ),
          GestureDetector(
            onTap: () {
              if (showYearlyView) {
                _selectYear(context);
              } else {
                _selectMonth(context);
              }
            },
            child: Text(
              showYearlyView
                  ? 'Année $selectedYear'
                  : DateFormat('MMMM yyyy', 'fr_FR').format(selectedMonth),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              if (showYearlyView) {
                if (selectedYear < DateTime.now().year) {
                  setState(() {
                    selectedYear++;
                  });
                }
              } else {
                final nextMonth = DateTime(selectedMonth.year, selectedMonth.month + 1);
                if (nextMonth.isBefore(DateTime.now().add(const Duration(days: 1)))) {
                  setState(() {
                    selectedMonth = nextMonth;
                  });
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(Map<String, double> stats) {
    final formatter = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);
    final income = stats['income'] ?? 0;
    final expense = stats['expense'] ?? 0;
    final balance = stats['balance'] ?? 0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Revenus',
            formatter.format(income),
            Icons.trending_up,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Dépenses',
            formatter.format(expense),
            Icons.trending_down,
            Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Solde',
            formatter.format(balance),
            Icons.account_balance,
            balance >= 0 ? Colors.blue : Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              amount,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPieChart(List<TransactionModel> transactions) {
    final expenses = transactions.where((t) => t.type == TransactionType.expense).toList();

    if (expenses.isEmpty) {
      return _buildEmptyChart('Aucune dépense pour cette période');
    }

    // Grouper par catégorie
    final categoryTotals = <String, double>{};
    for (var transaction in expenses) {
      categoryTotals[transaction.categoryId] =
          (categoryTotals[transaction.categoryId] ?? 0) + transaction.amount;
    }

    final categories = ref.watch(categoriesProvider);
    final sections = categoryTotals.entries.map((entry) {
      final category = categories.firstWhere((c) => c.id == entry.key);
      final color = Color(int.parse('0xFF${category.colorHex.substring(1)}'));
      final percentage = (entry.value / expenses.fold(0.0, (sum, t) => sum + t.amount)) * 100;

      return PieChartSectionData(
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        color: color,
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Répartition des dépenses',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 2,
                centerSpaceRadius: 0,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildLegend(categoryTotals),
        ],
      ),
    );
  }

  Widget _buildLegend(Map<String, double> categoryTotals) {
    final categories = ref.watch(categoriesProvider);
    final formatter = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: categoryTotals.entries.map((entry) {
        final category = categories.firstWhere((c) => c.id == entry.key);
        final color = Color(int.parse('0xFF${category.colorHex.substring(1)}'));

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${category.name}: ${formatter.format(entry.value)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildDailyBarChart(List<TransactionModel> transactions) {
    if (transactions.isEmpty) {
      return _buildEmptyChart('Aucune transaction pour cette période');
    }

    // Grouper par jour
    final dailyData = <int, Map<String, double>>{};
    final daysInMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day;

    for (int i = 1; i <= daysInMonth; i++) {
      dailyData[i] = {'income': 0, 'expense': 0};
    }

    for (var transaction in transactions) {
      final day = transaction.date.day;
      if (transaction.type == TransactionType.income) {
        dailyData[day]!['income'] = dailyData[day]!['income']! + transaction.amount;
      } else {
        dailyData[day]!['expense'] = dailyData[day]!['expense']! + transaction.amount;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Évolution quotidienne',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: dailyData.values.fold(0.0, (max, day) {
                  final dayMax = day.values.reduce((a, b) => a > b ? a : b);
                  return dayMax > max ? dayMax : max;
                }) * 1.2,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() % 5 == 0 || value.toInt() == 1) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: dailyData.entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value['income']! + entry.value['expense']!,
                        color: entry.value['income']! > entry.value['expense']!
                            ? Colors.green
                            : Colors.red,
                        width: 3,
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ← NOUVEAU : Graphique mensuel pour la vue annuelle
  Widget _buildMonthlyBarChart(List<TransactionModel> transactions) {
    if (transactions.isEmpty) {
      return _buildEmptyChart('Aucune transaction pour cette période');
    }

    // Grouper par mois
    final monthlyData = <int, Map<String, double>>{};

    for (int i = 1; i <= 12; i++) {
      monthlyData[i] = {'income': 0, 'expense': 0};
    }

    for (var transaction in transactions) {
      final month = transaction.date.month;
      if (transaction.type == TransactionType.income) {
        monthlyData[month]!['income'] = monthlyData[month]!['income']! + transaction.amount;
      } else {
        monthlyData[month]!['expense'] = monthlyData[month]!['expense']! + transaction.amount;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Évolution mensuelle',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: monthlyData.values.fold(0.0, (max, month) {
                  final monthMax = month.values.reduce((a, b) => a > b ? a : b);
                  return monthMax > max ? monthMax : max;
                }) * 1.2,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
                        final index = value.toInt() - 1;
                        if (index >= 0 && index < months.length) {
                          return Text(
                            months[index],
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: monthlyData.entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value['income']! + entry.value['expense']!,
                        color: entry.value['income']! > entry.value['expense']!
                            ? Colors.green
                            : Colors.red,
                        width: 8,
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendLineChart(List<TransactionModel> transactions) {
    if (transactions.isEmpty) {
      return _buildEmptyChart('Aucune donnée pour afficher la tendance');
    }

    final cumulativeBalance = <FlSpot>[];
    double balance = 0;

    if (showYearlyView) {
      // Vue annuelle : tendance par mois
      for (int i = 1; i <= 12; i++) {
        final monthTransactions = transactions.where((t) => t.date.month == i);

        for (var transaction in monthTransactions) {
          if (transaction.type == TransactionType.income) {
            balance += transaction.amount;
          } else {
            balance -= transaction.amount;
          }
        }

        cumulativeBalance.add(FlSpot(i.toDouble(), balance));
      }
    } else {
      // Vue mensuelle : tendance par jour
      final daysInMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day;

      for (int i = 1; i <= daysInMonth; i++) {
        final dayTransactions = transactions.where((t) => t.date.day == i);

        for (var transaction in dayTransactions) {
          if (transaction.type == TransactionType.income) {
            balance += transaction.amount;
          } else {
            balance -= transaction.amount;
          }
        }

        cumulativeBalance.add(FlSpot(i.toDouble(), balance));
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tendance du solde',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: showYearlyView ? 1 : 5,
                      getTitlesWidget: (value, meta) {
                        if (showYearlyView) {
                          const months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
                          final index = value.toInt() - 1;
                          if (index >= 0 && index < months.length) {
                            return Text(
                              months[index],
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                        } else {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: cumulativeBalance,
                    isCurved: true,
                    color: const Color(0xFF6C63FF),
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF6C63FF).withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCategories(List<TransactionModel> transactions) {
    final expenses = transactions.where((t) => t.type == TransactionType.expense).toList();

    if (expenses.isEmpty) {
      return const SizedBox.shrink();
    }

    // Grouper et trier par montant
    final categoryTotals = <String, double>{};
    for (var transaction in expenses) {
      categoryTotals[transaction.categoryId] =
          (categoryTotals[transaction.categoryId] ?? 0) + transaction.amount;
    }

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topCategories = sortedCategories.take(5).toList();
    final categories = ref.watch(categoriesProvider);
    final formatter = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);
    final totalExpense = expenses.fold(0.0, (sum, t) => sum + t.amount);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top 5 Catégories de dépenses',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...topCategories.asMap().entries.map((entry) {
            final index = entry.key;
            final categoryEntry = entry.value;
            final category = categories.firstWhere((c) => c.id == categoryEntry.key);
            final color = Color(int.parse('0xFF${category.colorHex.substring(1)}'));
            final percentage = (categoryEntry.value / totalExpense) * 100;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              formatter.format(categoryEntry.value),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildEmptyChart(String message) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // ← NOUVEAU : Sélecteur d'année
  Future<void> _selectYear(BuildContext context) async {
    final availableYears = ref.read(availableYearsProvider);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sélectionner une année',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: availableYears.length,
                  itemBuilder: (context, index) {
                    final year = availableYears[index];
                    final isSelected = year == selectedYear;

                    return ListTile(
                      title: Text(
                        'Année $year',
                        style: GoogleFonts.inter(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Theme.of(context).colorScheme.primary : null,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                          : null,
                      onTap: () {
                        setState(() {
                          selectedYear = year;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectMonth(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
    );

    if (picked != null) {
      setState(() {
        selectedMonth = DateTime(picked.year, picked.month);
        selectedYear = picked.year; // ← Synchroniser l'année
      });
    }
  }

  Future<void> _generatePdfReport(List<TransactionModel> transactions, Map<String, double> stats) async {
    setState(() => isGeneratingPdf = true);

    try {
      final pdf = pw.Document();
      final formatter = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);
      final categories = ref.read(categoriesProvider);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // En-tête
              pw.Header(
                level: 0,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'ChikaBin - Rapport Financier',
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      showYearlyView
                          ? 'Année $selectedYear'
                          : DateFormat('MMMM yyyy', 'fr_FR').format(selectedMonth),
                      style: pw.TextStyle(
                        fontSize: 18,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      'Généré le ${DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR').format(DateTime.now())}',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 30),

              // Résumé financier
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      showYearlyView ? 'RÉSUMÉ DE L\'ANNÉE' : 'RÉSUMÉ DU MOIS',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 12),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Revenus:', style: const pw.TextStyle(fontSize: 12)),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              formatter.format(stats['income'] ?? 0),
                              style: pw.TextStyle(
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.green,
                              ),
                            ),
                          ],
                        ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Dépenses:', style: const pw.TextStyle(fontSize: 12)),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              formatter.format(stats['expense'] ?? 0),
                              style: pw.TextStyle(
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.red,
                              ),
                            ),
                          ],
                        ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Solde:', style: const pw.TextStyle(fontSize: 12)),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              formatter.format(stats['balance'] ?? 0),
                              style: pw.TextStyle(
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold,
                                color: (stats['balance'] ?? 0) >= 0
                                    ? PdfColors.blue
                                    : PdfColors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 30),

              // Liste des transactions
              pw.Text(
                'DÉTAIL DES TRANSACTIONS (${transactions.length})',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),

              if (transactions.isEmpty)
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  child: pw.Text(
                    'Aucune transaction pour cette période',
                    style: const pw.TextStyle(color: PdfColors.grey600),
                  ),
                )
              else
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(1),
                    1: const pw.FlexColumnWidth(2),
                    2: const pw.FlexColumnWidth(1.5),
                    3: const pw.FlexColumnWidth(1.5),
                  },
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Date',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Description',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Catégorie',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Montant',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    ...transactions.map((t) {
                      final category = categories.firstWhere((c) => c.id == t.categoryId);
                      final isIncome = t.type == TransactionType.income;

                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              DateFormat('dd/MM/yy').format(t.date),
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              t.title,
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              category.name,
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              '${isIncome ? '+' : '-'} ${formatter.format(t.amount)}',
                              style: pw.TextStyle(
                                fontSize: 10,
                                color: isIncome ? PdfColors.green : PdfColors.red,
                                fontWeight: pw.FontWeight.bold,
                              ),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
            ];
          },
          footer: (pw.Context context) {
            return pw.Container(
              alignment: pw.Alignment.centerRight,
              margin: const pw.EdgeInsets.only(top: 10),
              child: pw.Text(
                'Page ${context.pageNumber}/${context.pagesCount}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              ),
            );
          },
        ),
      );

      // Générer le nom du fichier
      final fileName = showYearlyView
          ? 'ChikaBin_Rapport_Annuel_$selectedYear.pdf'
          : 'ChikaBin_Rapport_${DateFormat('yyyy-MM').format(selectedMonth)}.pdf';

      final pdfBytes = await pdf.save();

      // Sauvegarder via MediaStore
      final filePath = await FileStorageService.saveToDownloads(fileName, pdfBytes);

      if (filePath != null && mounted) {
        // Dialogue de succès
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 12),
                Text('PDF Téléchargé !'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Votre rapport a été sauvegardé dans :',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.folder, color: Colors.blue, size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Téléchargements',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            Text(
                              fileName,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '📱 Ouvrez l\'app "Fichiers" puis "Téléchargements".',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await OpenFilex.open(filePath);
                  } catch (e) {
                    // Ignorer si l'ouverture échoue
                  }
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('Ouvrir'),
              ),
            ],
          ),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Impossible de sauvegarder le PDF'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => isGeneratingPdf = false);
    }
  }
}
