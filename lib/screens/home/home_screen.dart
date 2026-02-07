import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../data/models/transaction_model.dart';
import '../../data/providers/transaction_provider.dart';
import '../../data/providers/currency_provider.dart';
import '../../widget/app_drawer.dart';
import '../report/reports_screen.dart';
import '../transactions/add_transaction_screen.dart';
import '../transactions/transactions_list_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  DateTime selectedMonth = DateTime.now();
  int selectedYear = DateTime.now().year;
  bool showYearlyView = false; // ← NOUVEAU : Toggle entre mensuel/annuel
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final monthStats = ref.watch(statsProvider(selectedMonth));
    final yearStats = ref.watch(yearStatsProvider(selectedYear));
    final transactions = ref.watch(transactionsProvider);
    final recentTransactions = transactions.take(5).toList();

    // ← Choisir les stats à afficher selon la vue
    final displayStats = showYearlyView ? yearStats : monthStats;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      drawer: const AppDrawer(),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // AppBar moderne avec glassmorphism
          _buildModernAppBar(),

          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // ← NOUVEAU : Toggle Mensuel/Annuel
                  _buildViewToggle(),

                  const SizedBox(height: 16),

                  // Carte de solde moderne avec stats mensuelles ET annuelles
                  _buildModernBalanceCard(displayStats),

                  const SizedBox(height: 24),

                  // Statistiques avec design amélioré
                  _buildModernStatsCards(displayStats),

                  const SizedBox(height: 24),

                  // Actions rapides modernisées
                  _buildModernQuickActions(),

                  const SizedBox(height: 24),

                  // Transactions récentes avec meilleur design
                  _buildModernRecentTransactions(recentTransactions),

                  const SizedBox(height: 100), // Espace pour le FAB
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildModernFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ← NOUVEAU : Widget Toggle Mensuel/Annuel
  Widget _buildViewToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
              label: showYearlyView ? '${selectedMonth.year}' : DateFormat('MMM yyyy', 'fr_FR').format(selectedMonth),
              isSelected: !showYearlyView,
              onTap: () {
                if (showYearlyView) {
                  setState(() {
                    showYearlyView = false;
                    _animationController.reset();
                    _animationController.forward();
                  });
                } else {
                  _selectMonth(context);
                }
              },
              icon: Icons.calendar_month,
            ),
          ),
          Expanded(
            child: _buildToggleButton(
              label: 'Année $selectedYear',
              isSelected: showYearlyView,
              onTap: () {
                if (!showYearlyView) {
                  setState(() {
                    showYearlyView = true;
                    _animationController.reset();
                    _animationController.forward();
                  });
                } else {
                  _selectYear(context);
                }
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
              Flexible(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernAppBar() {
    return SliverAppBar(
      expandedHeight: 80,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: Builder(
        builder: (context) => Container(
          margin: const EdgeInsets.only(left: 12, top: 6, bottom: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 22),
            onPressed: () => Scaffold.of(context).openDrawer(),
            padding: EdgeInsets.zero,
          ),
        ),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
            ],
          ),
        ),
        child: FlexibleSpaceBar(
          centerTitle: true,
          title: Text(
            'Mon Budget',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          titlePadding: const EdgeInsets.only(left: 56, bottom: 12),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12, top: 6, bottom: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: Icon(
              showYearlyView ? Icons.calendar_today : Icons.calendar_month_outlined,
              color: Colors.white,
              size: 22,
            ),
            onPressed: () {
              if (showYearlyView) {
                _selectYear(context);
              } else {
                _selectMonth(context);
              }
            },
            tooltip: showYearlyView ? 'Sélectionner l\'année' : 'Sélectionner le mois',
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Widget _buildModernBalanceCard(Map<String, double> stats) {
    final balance = stats['balance'] ?? 0;
    final income = stats['income'] ?? 0;
    final expense = stats['expense'] ?? 0;
    final currency = ref.watch(currencyProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    showYearlyView
                        ? 'Année $selectedYear'
                        : DateFormat('MMMM yyyy', 'fr_FR').format(selectedMonth),
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    showYearlyView ? 'Solde annuel' : 'Solde mensuel',
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  balance >= 0 ? Icons.trending_up : Icons.trending_down,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            currency.format(balance),
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 20),

          // Mini statistiques dans la carte
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  'Revenus',
                  currency.format(income),
                  Icons.arrow_downward,
                  Colors.green.shade300,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              Expanded(
                child: _buildMiniStat(
                  'Dépenses',
                  currency.format(expense),
                  Icons.arrow_upward,
                  Colors.red.shade300,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildModernStatsCards(Map<String, double> stats) {
    final income = stats['income'] ?? 0;
    final expense = stats['expense'] ?? 0;
    final transactions = ref.watch(transactionsProvider);

    final filteredTransactions = showYearlyView
        ? transactions.where((t) => t.date.year == selectedYear).toList()
        : transactions.where((t) {
      final startOfMonth = DateTime(selectedMonth.year, selectedMonth.month, 1);
      final endOfMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);
      return t.date.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
          t.date.isBefore(endOfMonth.add(const Duration(days: 1)));
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildModernStatCard(
              'Revenus',
              income,
              Icons.south_west,
              Colors.green,
              filteredTransactions.where((t) => t.type == TransactionType.income).length,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildModernStatCard(
              'Dépenses',
              expense,
              Icons.north_east,
              Colors.red,
              filteredTransactions.where((t) => t.type == TransactionType.expense).length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernStatCard(String title, double amount, IconData icon, Color color, int count) {
    final currency = ref.watch(currencyProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Text(
                '$count',
                style: GoogleFonts.inter(
                  color: Colors.grey[400],
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.inter(
              color: Colors.grey[600],
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              currency.format(amount),
              style: GoogleFonts.inter(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actions rapides',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildModernActionButton(
                  'Transactions',
                  Icons.receipt_long_outlined,
                  Colors.blue,
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TransactionsListScreen()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildModernActionButton(
                  'Rapports',
                  Icons.bar_chart_rounded,
                  Colors.orange,
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReportsScreen()),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernRecentTransactions(List<TransactionModel> transactions) {
    if (transactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Aucune transaction',
                style: GoogleFonts.inter(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ajoutez votre première transaction',
                style: GoogleFonts.inter(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transactions récentes',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TransactionsListScreen()),
                ),
                child: Text(
                  'Voir tout',
                  style: GoogleFonts.inter(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: transactions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            return _buildModernTransactionItem(transactions[index]);
          },
        ),
      ],
    );
  }

  Widget _buildModernTransactionItem(TransactionModel transaction) {
    final category = ref.watch(categoriesProvider).firstWhere(
          (c) => c.id == transaction.categoryId,
      orElse: () => ref.watch(categoriesProvider).first,
    );

    final currency = ref.watch(currencyProvider);
    final color = transaction.type == TransactionType.income ? Colors.green : Colors.red;
    final categoryColor = Color(int.parse('0xFF${category.colorHex.substring(1)}'));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // TODO: Naviguer vers les détails de la transaction
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _getIconData(category.icon),
                    color: categoryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.grey[800],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(
                            flex: 2,
                            child: Text(
                              category.name,
                              style: GoogleFonts.inter(
                                color: Colors.grey[500],
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('dd MMM', 'fr_FR').format(transaction.date),
                            style: GoogleFonts.inter(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${transaction.type == TransactionType.income ? '+' : '-'} ${currency.format(transaction.amount)}',
                  style: GoogleFonts.inter(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernFAB() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      height: 56,
      child: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add, size: 24, color: Colors.white),
        label: Text(
          'Nouvelle transaction',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    final iconMap = {
      'restaurant': Icons.restaurant_outlined,
      'directions_car': Icons.directions_car_outlined,
      'home': Icons.home_outlined,
      'local_hospital': Icons.local_hospital_outlined,
      'sports_esports': Icons.sports_esports_outlined,
      'account_balance_wallet': Icons.account_balance_wallet_outlined,
      'work': Icons.work_outline,
      'shopping_cart': Icons.shopping_cart_outlined,
      'school': Icons.school_outlined,
      'fitness_center': Icons.fitness_center_outlined,
      'phone': Icons.phone_outlined,
      'local_gas_station': Icons.local_gas_station_outlined,
      'restaurant_menu': Icons.restaurant_menu_outlined,
      'coffee': Icons.coffee_outlined,
      'movie': Icons.movie_outlined,
      'pets': Icons.pets_outlined,
      'face': Icons.face_outlined,
      'content_cut': Icons.content_cut_outlined,
    };
    return iconMap[iconName] ?? Icons.category_outlined;
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
                          _animationController.reset();
                          _animationController.forward();
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
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('fr', 'FR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.grey[800]!,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedMonth = DateTime(picked.year, picked.month);
        selectedYear = picked.year; // ← Synchroniser l'année aussi
        _animationController.reset();
        _animationController.forward();
      });
    }
  }
}