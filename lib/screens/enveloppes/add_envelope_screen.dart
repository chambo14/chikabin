import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/envelope_model.dart';
import '../../data/providers/transaction_provider.dart';

class AddEnvelopeScreen extends ConsumerStatefulWidget {
  final EnvelopeModel? envelope;

  const AddEnvelopeScreen({Key? key, this.envelope}) : super(key: key);

  @override
  ConsumerState<AddEnvelopeScreen> createState() => _AddEnvelopeScreenState();
}

class _AddEnvelopeScreenState extends ConsumerState<AddEnvelopeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();

  String _selectedIcon = 'home';
  String _selectedColor = '#FF5722';
  bool _autoRefill = false;
  bool _rollover = true;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _availableIcons = [
    {'name': 'home', 'icon': Icons.home},
    {'name': 'restaurant', 'icon': Icons.restaurant},
    {'name': 'directions_car', 'icon': Icons.directions_car},
    {'name': 'local_hospital', 'icon': Icons.local_hospital},
    {'name': 'shopping_cart', 'icon': Icons.shopping_cart},
    {'name': 'school', 'icon': Icons.school},
    {'name': 'fitness_center', 'icon': Icons.fitness_center},
    {'name': 'movie', 'icon': Icons.movie},
    {'name': 'savings', 'icon': Icons.savings},
    {'name': 'phone', 'icon': Icons.phone},
    {'name': 'local_gas_station', 'icon': Icons.local_gas_station},
    {'name': 'credit_card', 'icon': Icons.credit_card},
    {'name': 'lightbulb', 'icon': Icons.lightbulb},
    {'name': 'pets', 'icon': Icons.pets},
    {'name': 'child_care', 'icon': Icons.child_care},
    {'name': 'coffee', 'icon': Icons.coffee},
    {'name': 'sports_esports', 'icon': Icons.sports_esports},
    {'name': 'beach_access', 'icon': Icons.beach_access},
  ];

  final List<String> _availableColors = [
    '#FF5722', '#4CAF50', '#2196F3', '#F44336', '#FFB300',
    '#9C27B0', '#00BCD4', '#3F51B5', '#FF9800', '#E91E63',
    '#009688', '#8BC34A', '#FFC107', '#673AB7', '#FF5252',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.envelope != null) {
      _nameController.text = widget.envelope!.name;
      _targetController.text = widget.envelope!.targetAmount.toString();
      _selectedIcon = widget.envelope!.icon;
      _selectedColor = widget.envelope!.colorHex;
      _autoRefill = widget.envelope!.autoRefill;
      _rollover = widget.envelope!.rollover;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          widget.envelope == null ? 'Nouvelle enveloppe' : 'Modifier enveloppe',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Aperçu
            _buildPreview(),
            const SizedBox(height: 24),

            // Nom
            _buildNameField(),
            const SizedBox(height: 20),

            // Montant cible
            _buildTargetField(),
            const SizedBox(height: 20),

            // Icône
            _buildIconSelector(),
            const SizedBox(height: 20),

            // Couleur
            _buildColorSelector(),
            const SizedBox(height: 24),

            // Options
            _buildOptions(),
            const SizedBox(height: 32),

            // Bouton sauvegarder
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    final color = Color(int.parse('0xFF${_selectedColor.substring(1)}'));
    final icon = _availableIcons.firstWhere(
          (i) => i['name'] == _selectedIcon,
      orElse: () => _availableIcons.first,
    )['icon'] as IconData;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aperçu',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _nameController.text.isEmpty ? 'Nom enveloppe' : _nameController.text,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _targetController.text.isEmpty
                      ? '0 FCFA'
                      : '${_targetController.text} FCFA / mois',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nom de l\'enveloppe',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          style: GoogleFonts.inter(fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Ex: Loyer, Nourriture, Transport...',
            prefixIcon: const Icon(Icons.label_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer un nom';
            }
            return null;
          },
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildTargetField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Montant cible mensuel',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _targetController,
          style: GoogleFonts.inter(fontSize: 16),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '150 000',
            prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
            suffixText: 'FCFA',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer un montant';
            }
            if (double.tryParse(value) == null) {
              return 'Montant invalide';
            }
            return null;
          },
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildIconSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Icône',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _availableIcons.length,
            itemBuilder: (context, index) {
              final iconData = _availableIcons[index];
              final isSelected = _selectedIcon == iconData['name'];
              final color = Color(int.parse('0xFF${_selectedColor.substring(1)}'));

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedIcon = iconData['name'];
                    HapticFeedback.selectionClick();
                  });
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? color.withOpacity(0.15) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? color : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    iconData['icon'] as IconData,
                    color: isSelected ? color : Colors.grey[600],
                    size: 24,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Couleur',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _availableColors.length,
            itemBuilder: (context, index) {
              final colorHex = _availableColors[index];
              final color = Color(int.parse('0xFF${colorHex.substring(1)}'));
              final isSelected = _selectedColor == colorHex;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedColor = colorHex;
                    HapticFeedback.selectionClick();
                  });
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? Colors.grey[800]! : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Options',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Remplissage automatique',
              style: GoogleFonts.inter(fontSize: 14),
            ),
            subtitle: Text(
              'Allouer automatiquement le montant cible chaque mois',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
            ),
            value: _autoRefill,
            onChanged: (value) => setState(() => _autoRefill = value),
          ),
          Divider(color: Colors.grey[200]),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Reporter le reste',
              style: GoogleFonts.inter(fontSize: 14),
            ),
            subtitle: Text(
              'Garder le montant non dépensé pour le mois suivant',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
            ),
            value: _rollover,
            onChanged: (value) => setState(() => _rollover = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveEnvelope,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
          widget.envelope == null ? 'Créer l\'enveloppe' : 'Mettre à jour',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _saveEnvelope() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final envelope = EnvelopeModel(
        id: widget.envelope?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        icon: _selectedIcon,
        colorHex: _selectedColor,
        targetAmount: double.parse(_targetController.text),
        currentAmount: widget.envelope?.currentAmount ?? 0,
        spentAmount: widget.envelope?.spentAmount ?? 0,
        autoRefill: _autoRefill,
        rollover: _rollover,
        lastRefillDate: widget.envelope?.lastRefillDate,
      );

      if (widget.envelope == null) {
        await ref.read(envelopeNotifierProvider.notifier).addEnvelope(envelope);
      } else {
        await ref.read(envelopeNotifierProvider.notifier).updateEnvelope(envelope);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.envelope == null
                  ? '✓ Enveloppe créée'
                  : '✓ Enveloppe mise à jour',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
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