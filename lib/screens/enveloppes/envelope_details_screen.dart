import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/envelope_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/providers/transaction_provider.dart';
import '../../data/providers/currency_provider.dart';

import 'add_envelope_screen.dart';

class EnvelopeDetailsScreen extends ConsumerStatefulWidget {
  final EnvelopeModel envelope;

  const EnvelopeDetailsScreen({Key? key, required this.envelope}) : super(key: key);

  @override
  ConsumerState<EnvelopeDetailsScreen> createState() => _EnvelopeDetailsScreenState();
}

class _EnvelopeDetailsScreenState extends ConsumerState<EnvelopeDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    // Récupérer l'enveloppe mise à jour
    final envelopes = ref.watch(envelopeNotifierProvider);
    final envelope = envelopes.firstWhere(
          (e) => e.id == widget.envelope.id,
      orElse: () => widget.envelope,
    );
    final currency = ref.watch(currencyProvider);
    final transactions = ref.watch(transactionsProvider);

    // Filtrer les transactions de cette enveloppe
    final envelopeTransactions = transactions
        .where((t) => t.envelopeId == envelope.id)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // AppBar personnalisé
          _buildAppBar(context, envelope),

          // Carte principale
          SliverToBoxAdapter(
            child: _buildMainCard(envelope, currency),
          ),

          // Actions rapides
          SliverToBoxAdapter(
            child: _buildQuickActions(context, envelope, currency),
          ),

          // Statistiques
          SliverToBoxAdapter(
            child: _buildStats(envelope, currency),
          ),

          // Transactions liées
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text(
                'Transactions',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ),

          if (envelopeTransactions.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Aucune transaction',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final transaction = envelopeTransactions[index];
                    return _buildTransactionItem(transaction, currency);
                  },
                  childCount: envelopeTransactions.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, EnvelopeModel envelope) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              envelope.color,
              envelope.color.withOpacity(0.8),
            ],
          ),
        ),
        child: FlexibleSpaceBar(
          centerTitle: false,
          title: Row(
            children: [
              Icon(envelope.iconData, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                envelope.name,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddEnvelopeScreen(envelope: envelope),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.white),
          onPressed: () => _confirmDelete(context),
        ),
      ],
    );
  }

  Widget _buildMainCard(EnvelopeModel envelope, currency) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Montant disponible
          Text(
            'Disponible',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(envelope.availableAmount, currency),
            style: GoogleFonts.inter(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: envelope.isOverBudget ? Colors.red : envelope.color,
            ),
          ),
          const SizedBox(height: 24),

          // Barre de progression
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progression',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '${envelope.percentageSpent.toStringAsFixed(0)}%',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: envelope.isOverBudget ? Colors.red : envelope.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (envelope.percentageSpent / 100).clamp(0.0, 1.0),
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation(
                    envelope.isOverBudget ? Colors.red : envelope.color,
                  ),
                  minHeight: 10,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Stats en ligne
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Alloué',
                  CurrencyFormatter.format(envelope.currentAmount, currency),
                  Colors.blue,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.grey[300]),
              Expanded(
                child: _buildStatItem(
                  'Dépensé',
                  CurrencyFormatter.format(envelope.spentAmount, currency),
                  Colors.orange,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.grey[300]),
              Expanded(
                child: _buildStatItem(
                  'Cible',
                  CurrencyFormatter.format(envelope.targetAmount, currency),
                  Colors.grey[600]!,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, EnvelopeModel envelope, currency) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              context,
              icon: Icons.add_circle_outline,
              label: 'Allouer',
              color: Colors.green,
              onTap: () => _showAllocateDialog(context, envelope, currency),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              context,
              icon: Icons.swap_horiz,
              label: 'Transférer',
              color: Colors.blue,
              onTap: () => _showTransferDialog(context, envelope, currency),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              context,
              icon: Icons.remove_circle_outline,
              label: 'Retirer',
              color: Colors.orange,
              onTap: () => _showWithdrawDialog(context, envelope, currency),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Color color,
        required VoidCallback onTap,
      }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStats(EnvelopeModel envelope, currency) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Paramètres',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingRow(
            'Remplissage automatique',
            envelope.autoRefill ? 'Activé' : 'Désactivé',
            envelope.autoRefill ? Colors.green : Colors.grey,
          ),
          Divider(color: Colors.grey[200]),
          _buildSettingRow(
            'Reporter le reste',
            envelope.rollover ? 'Activé' : 'Désactivé',
            envelope.rollover ? Colors.green : Colors.grey,
          ),
          if (envelope.lastRefillDate != null) ...[
            Divider(color: Colors.grey[200]),
            _buildSettingRow(
              'Dernier remplissage',
              DateFormat('dd/MM/yyyy').format(envelope.lastRefillDate!),
              Colors.grey[600]!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(TransactionModel transaction, currency) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.receipt,
              color: Colors.grey[700],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('dd MMM yyyy', 'fr_FR').format(transaction.date),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '- ${CurrencyFormatter.format(transaction.amount, currency)}',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAllocateDialog(
      BuildContext context,
      EnvelopeModel envelope,
      currency,
      ) async {
    final controller = TextEditingController();
    final virtualCard = ref.read(virtualCardProvider);

    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Allouer des fonds',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Disponible: ${CurrencyFormatter.format(virtualCard, currency)}',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Montant',
                suffixText: currency.code,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: GoogleFonts.inter()),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              Navigator.pop(context, amount);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Allouer', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );

    if (result != null && result > 0) {
      final success = await ref
          .read(envelopeNotifierProvider.notifier)
          .allocateToEnvelope(envelope.id, result);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? '✓ ${CurrencyFormatter.format(result, currency)} alloué'
                  : '✗ Fonds insuffisants',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showTransferDialog(
      BuildContext context,
      EnvelopeModel fromEnvelope,
      currency,
      ) async {
    final envelopes = ref.read(envelopeNotifierProvider);
    final otherEnvelopes = envelopes.where((e) => e.id != fromEnvelope.id).toList();

    if (otherEnvelopes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Créez d\'abord une autre enveloppe',
            style: GoogleFonts.inter(),
          ),
        ),
      );
      return;
    }

    EnvelopeModel? selectedEnvelope = otherEnvelopes.first;
    final controller = TextEditingController();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Transférer vers',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<EnvelopeModel>(
                value: selectedEnvelope,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: otherEnvelopes.map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Row(
                      children: [
                        Icon(e.iconData, color: e.color, size: 20),
                        const SizedBox(width: 8),
                        Text(e.name, style: GoogleFonts.inter()),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedEnvelope = value);
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Montant',
                  suffixText: currency.code,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler', style: GoogleFonts.inter()),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(controller.text);
                if (amount != null && selectedEnvelope != null) {
                  Navigator.pop(context, {
                    'to': selectedEnvelope!.id,
                    'amount': amount,
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Transférer', style: GoogleFonts.inter()),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      final success = await ref
          .read(envelopeNotifierProvider.notifier)
          .transferBetweenEnvelopes(
        fromEnvelope.id,
        result['to'],
        result['amount'],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? '✓ Transfert effectué' : '✗ Fonds insuffisants',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showWithdrawDialog(
      BuildContext context,
      EnvelopeModel envelope,
      currency,
      ) async {
    final controller = TextEditingController();

    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Retirer des fonds',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Disponible: ${CurrencyFormatter.format(envelope.availableAmount, currency)}',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              // ❌ ANCIEN
              // ✅ NOUVEAU
              decoration: InputDecoration(
                labelText: 'Montant à retirer',
                suffixText: currency.symbol, // ← Utilisez .symbol
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: GoogleFonts.inter()),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              Navigator.pop(context, amount);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Retirer', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );

    if (result != null && result > 0) {
      // Retirer = remettre dans la carte virtuelle
      final updated = envelope.copyWith(
        currentAmount: envelope.currentAmount - result,
      );

      await ref.read(envelopeNotifierProvider.notifier).updateEnvelope(updated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✓ ${CurrencyFormatter.format(result, currency)} retiré',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Supprimer l\'enveloppe',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer cette enveloppe ? '
              'Les fonds seront retournés à la carte virtuelle.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler', style: GoogleFonts.inter()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Supprimer', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(envelopeNotifierProvider.notifier).deleteEnvelope(widget.envelope.id);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✓ Enveloppe supprimée',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
}