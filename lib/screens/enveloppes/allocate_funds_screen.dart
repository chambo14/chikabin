import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/envelope_model.dart';
import '../../data/models/currency_model.dart'; // ← Import pour Currency enum
import '../../data/providers/transaction_provider.dart';
import '../../data/providers/currency_provider.dart';
import '../../core/utils/currency_formatter.dart'; // ← Import pour CurrencyFormatter

class AllocateFundsScreen extends ConsumerStatefulWidget {
  const AllocateFundsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AllocateFundsScreen> createState() => _AllocateFundsScreenState();
}

class _AllocateFundsScreenState extends ConsumerState<AllocateFundsScreen> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, double> _allocations = {};
  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  double get _totalAllocated {
    return _allocations.values.fold(0, (sum, amount) => sum + amount);
  }

  @override
  Widget build(BuildContext context) {
    final envelopes = ref.watch(envelopeNotifierProvider);
    final virtualCard = ref.watch(virtualCardProvider);
    final currency = ref.watch(currencyProvider);

    // Initialiser controllers si besoin
    for (var envelope in envelopes) {
      if (!_controllers.containsKey(envelope.id)) {
        _controllers[envelope.id] = TextEditingController();
        _allocations[envelope.id] = 0;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Allouer des fonds',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          // Carte virtuelle disponible
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'Disponible',
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  CurrencyFormatter.format(virtualCard - _totalAllocated, currency),
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_totalAllocated > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    'À allouer: ${CurrencyFormatter.format(_totalAllocated, currency)}',
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Liste des enveloppes
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: envelopes.length,
              itemBuilder: (context, index) {
                final envelope = envelopes[index];
                return _buildEnvelopeAllocation(envelope, currency);
              },
            ),
          ),

          // Bouton allouer
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                height: 56,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _totalAllocated > 0 && !_isLoading
                      ? _allocateFunds
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    'Allouer ${CurrencyFormatter.format(_totalAllocated, currency)}',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnvelopeAllocation(EnvelopeModel envelope, Currency currency) {
    final controller = _controllers[envelope.id]!;
    final remaining = envelope.targetAmount - envelope.currentAmount;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: envelope.color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(envelope.iconData, color: envelope.color, size: 24),
        ),
        title: Text(
          envelope.name,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'Manque: ${CurrencyFormatter.format(remaining, currency)}',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: SizedBox(
          width: 120,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 20),
                onPressed: () {
                  final current = double.tryParse(controller.text) ?? 0;
                  if (current > 0) {
                    final newAmount = (current - 10000).clamp(0.0, double.infinity); // ← Corrigé
                    controller.text = newAmount.toString();
                    _updateAllocation(envelope.id, newAmount);
                  }
                },
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  onChanged: (value) {
                    final amount = double.tryParse(value) ?? 0;
                    _updateAllocation(envelope.id, amount);
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 20),
                onPressed: () {
                  final current = double.tryParse(controller.text) ?? 0;
                  final newAmount = current + 10000.0; // ← Ajouté .0 pour forcer double
                  controller.text = newAmount.toString();
                  _updateAllocation(envelope.id, newAmount);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateAllocation(String envelopeId, double amount) {
    setState(() {
      _allocations[envelopeId] = amount;
    });
  }

  Future<void> _allocateFunds() async {
    final virtualCard = ref.read(virtualCardProvider);

    // Vérifier disponibilité
    if (_totalAllocated > virtualCard) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Fonds insuffisants sur la carte virtuelle',
            style: GoogleFonts.inter(fontWeight: FontWeight.w500),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      int successCount = 0;

      for (var entry in _allocations.entries) {
        if (entry.value > 0) {
          final success = await ref
              .read(envelopeNotifierProvider.notifier)
              .allocateToEnvelope(entry.key, entry.value);

          if (success) successCount++;
        }
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✓ $successCount enveloppe(s) alimentée(s)',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}