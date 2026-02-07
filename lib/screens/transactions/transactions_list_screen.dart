import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../data/models/transaction_model.dart';
import '../../data/providers/transaction_provider.dart';
import 'add_transaction_screen.dart';

enum FilterType { all, today, week, month, custom }

class TransactionsListScreen extends ConsumerStatefulWidget {
  const TransactionsListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TransactionsListScreen> createState() => _TransactionsListScreenState();
}

class _TransactionsListScreenState extends ConsumerState<TransactionsListScreen> {
  FilterType _selectedFilter = FilterType.month;
  TransactionType? _typeFilter;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  @override
  Widget build(BuildContext context) {
    final allTransactions = ref.watch(transactionsProvider);
    final filteredTransactions = _getFilteredTransactions(allTransactions);

    // Calculer les totaux
    double totalIncome = 0;
    double totalExpense = 0;
    for (var transaction in filteredTransactions) {
      if (transaction.type == TransactionType.income) {
        totalIncome += transaction.amount;
      } else {
        totalExpense += transaction.amount;
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title: Text('Transactions', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800),),
        actions: [
          PopupMenuButton<TransactionType?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (type) {
              setState(() {
                _typeFilter = type;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('Toutes'),
              ),
              const PopupMenuItem(
                value: TransactionType.income,
                child: Text('Revenus'),
              ),
              const PopupMenuItem(
                value: TransactionType.expense,
                child: Text('Dépenses'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filtres de période
            _buildFilterChips(),
        
            // Résumé
            _buildSummaryCard(totalIncome, totalExpense, filteredTransactions.length),
        
            // Liste des transactions
            Expanded(
              child: filteredTransactions.isEmpty
                  ? _buildEmptyState()
                  : _buildTransactionsList(filteredTransactions),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('Aujourd\'hui', FilterType.today),
            _buildFilterChip('Cette semaine', FilterType.week),
            _buildFilterChip('Ce mois', FilterType.month),
            _buildFilterChip('Toutes', FilterType.all),
            _buildCustomDateChip(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, FilterType type) {
    final isSelected = _selectedFilter == type;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = type;
            if (type != FilterType.custom) {
              _customStartDate = null;
              _customEndDate = null;
            }
          });
        },
        selectedColor: const Color(0xFF6C63FF).withOpacity(0.2),
        checkmarkColor: const Color(0xFF6C63FF),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFF6C63FF) : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildCustomDateChip() {
    final isSelected = _selectedFilter == FilterType.custom;
    String label = 'Personnalisé';

    if (_customStartDate != null && _customEndDate != null) {
      label = '${DateFormat('dd/MM').format(_customStartDate!)} - ${DateFormat('dd/MM').format(_customEndDate!)}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) async {
          final DateTimeRange? picked = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2020),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            locale: const Locale('fr', 'FR'),
          );

          if (picked != null) {
            setState(() {
              _selectedFilter = FilterType.custom;
              _customStartDate = picked.start;
              _customEndDate = picked.end;
            });
          }
        },
        selectedColor: const Color(0xFF6C63FF).withOpacity(0.2),
        checkmarkColor: const Color(0xFF6C63FF),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFF6C63FF) : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildSummaryCard(double income, double expense, int count) {
    final formatter = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);
    final balance = income - expense;

    return Container(
      margin: const EdgeInsets.all(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem('Revenus', income, Colors.green),
              Container(width: 1, height: 40, color: Colors.grey[300]),
              _buildSummaryItem('Dépenses', expense, Colors.red),
              Container(width: 1, height: 40, color: Colors.grey[300]),
              _buildSummaryItem('Solde', balance, balance >= 0 ? Colors.blue : Colors.orange),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$count transaction${count > 1 ? 's' : ''}',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color color) {
    final formatter = NumberFormat.currency(locale: 'fr_FR', symbol: '', decimalDigits: 0);

    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              formatter.format(amount),
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(List<TransactionModel> transactions) {
    // Grouper par date
    final groupedTransactions = <String, List<TransactionModel>>{};
    for (var transaction in transactions) {
      final dateKey = DateFormat('yyyy-MM-dd').format(transaction.date);
      groupedTransactions.putIfAbsent(dateKey, () => []).add(transaction);
    }

    final sortedDates = groupedTransactions.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final dateKey = sortedDates[index];
        final dateTransactions = groupedTransactions[dateKey]!;
        final date = DateTime.parse(dateKey);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                _formatDateHeader(date),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dateTransactions.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[200]),
                itemBuilder: (context, index) {
                  return _buildTransactionItem(dateTransactions[index]);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildTransactionItem(TransactionModel transaction) {
    final category = ref.watch(categoriesProvider).firstWhere(
          (c) => c.id == transaction.categoryId,
      orElse: () => ref.watch(categoriesProvider).first,
    );

    final formatter = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);
    final color = transaction.type == TransactionType.income ? Colors.green : Colors.red;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddTransactionScreen(transaction: transaction),
          ),
        );
      },
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Color(int.parse('0xFF${category.colorHex.substring(1)}')).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          _getIconData(category.icon),
          color: Color(int.parse('0xFF${category.colorHex.substring(1)}')),
        ),
      ),
      title: Text(
        transaction.title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        category.name,
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${transaction.type == TransactionType.income ? '+' : '-'} ${formatter.format(transaction.amount)}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          if (transaction.description != null && transaction.description!.isNotEmpty)
            Icon(Icons.notes, size: 16, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Aucune transaction',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Changez les filtres ou ajoutez une transaction',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Aujourd\'hui';
    } else if (dateOnly == yesterday) {
      return 'Hier';
    } else {
      return DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(date);
    }
  }

  List<TransactionModel> _getFilteredTransactions(List<TransactionModel> transactions) {
    var filtered = transactions;

    // Filtre par type
    if (_typeFilter != null) {
      filtered = filtered.where((t) => t.type == _typeFilter).toList();
    }

    // Filtre par période
    final now = DateTime.now();
    switch (_selectedFilter) {
      case FilterType.today:
        final today = DateTime(now.year, now.month, now.day);
        filtered = filtered.where((t) {
          final transactionDate = DateTime(t.date.year, t.date.month, t.date.day);
          return transactionDate == today;
        }).toList();
        break;
      case FilterType.week:
        final weekAgo = now.subtract(const Duration(days: 7));
        filtered = filtered.where((t) => t.date.isAfter(weekAgo)).toList();
        break;
      case FilterType.month:
        final monthStart = DateTime(now.year, now.month, 1);
        filtered = filtered.where((t) => t.date.isAfter(monthStart.subtract(const Duration(days: 1)))).toList();
        break;
      case FilterType.custom:
        if (_customStartDate != null && _customEndDate != null) {
          filtered = filtered.where((t) =>
          t.date.isAfter(_customStartDate!.subtract(const Duration(days: 1))) &&
              t.date.isBefore(_customEndDate!.add(const Duration(days: 1)))
          ).toList();
        }
        break;
      case FilterType.all:
        break;
    }

    return filtered;
  }

  IconData _getIconData(String iconName) {
    final iconMap = {
      'restaurant': Icons.restaurant,
      'directions_car': Icons.directions_car,
      'home': Icons.home,
      'local_hospital': Icons.local_hospital,
      'sports_esports': Icons.sports_esports,
      'account_balance_wallet': Icons.account_balance_wallet,
      'work': Icons.work,
    };
    return iconMap[iconName] ?? Icons.category;
  }
}