import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/category_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/providers/transaction_provider.dart';

class AddCategoryScreen extends ConsumerStatefulWidget {
  final CategoryModel? category;

  const AddCategoryScreen({super.key, this.category});

  @override
  ConsumerState<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends ConsumerState<AddCategoryScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  String _selectedIcon = 'restaurant';
  String _selectedColor = '#FF6B6B';
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Liste des icônes disponibles
  final List<Map<String, dynamic>> _availableIcons = [
    {'name': 'restaurant', 'icon': Icons.restaurant},
    {'name': 'directions_car', 'icon': Icons.directions_car},
    {'name': 'home', 'icon': Icons.home},
    {'name': 'local_hospital', 'icon': Icons.local_hospital},
    {'name': 'sports_esports', 'icon': Icons.sports_esports},
    {'name': 'account_balance_wallet', 'icon': Icons.account_balance_wallet},
    {'name': 'work', 'icon': Icons.work},
    {'name': 'shopping_cart', 'icon': Icons.shopping_cart},
    {'name': 'school', 'icon': Icons.school},
    {'name': 'fitness_center', 'icon': Icons.fitness_center},
    {'name': 'phone', 'icon': Icons.phone},
    {'name': 'local_gas_station', 'icon': Icons.local_gas_station},
    {'name': 'restaurant_menu', 'icon': Icons.restaurant_menu},
    {'name': 'coffee', 'icon': Icons.coffee},
    {'name': 'movie', 'icon': Icons.movie},
    {'name': 'pets', 'icon': Icons.pets},
    {'name': 'card_giftcard', 'icon': Icons.card_giftcard},
    {'name': 'business', 'icon': Icons.business},
    {'name': 'attach_money', 'icon': Icons.attach_money},
    {'name': 'trending_up', 'icon': Icons.trending_up},
    {'name': 'face', 'icon': Icons.face},
    {'name': 'content_cut', 'icon': Icons.content_cut},
    {'name': 'flight', 'icon': Icons.flight},
    {'name': 'hotel', 'icon': Icons.hotel},
    {'name': 'local_taxi', 'icon': Icons.local_taxi},
    {'name': 'train', 'icon': Icons.train},
    {'name': 'directions_bike', 'icon': Icons.directions_bike},
    {'name': 'fastfood', 'icon': Icons.fastfood},
    {'name': 'local_pizza', 'icon': Icons.local_pizza},
    {'name': 'spa', 'icon': Icons.spa},
    {'name': 'theater_comedy', 'icon': Icons.theater_comedy},
    {'name': 'music_note', 'icon': Icons.music_note},
    {'name': 'brush', 'icon': Icons.brush},
    {'name': 'camera_alt', 'icon': Icons.camera_alt},
    {'name': 'laptop', 'icon': Icons.laptop},
    {'name': 'phone_android', 'icon': Icons.phone_android},
    {'name': 'headphones', 'icon': Icons.headphones},
    {'name': 'lightbulb', 'icon': Icons.lightbulb},
    {'name': 'construction', 'icon': Icons.construction},
    {'name': 'medication', 'icon': Icons.medication},
    {'name': 'child_care', 'icon': Icons.child_care},
  ];

  // Liste des couleurs disponibles
  final List<String> _availableColors = [
    '#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FFEAA7', '#DFE6E9',
    '#74B9FF', '#A29BFE', '#FD79A8', '#FDCB6E', '#FF85C0', '#9B59B6',
    '#E17055', '#6C5CE7', '#0984E3', '#00B894', '#55EFC4', '#F39C12',
    '#E74C3C', '#3498DB', '#2ECC71', '#9C88FF', '#FFA502', '#FF6348',
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();

    // Si modification, charger les données
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _selectedType = widget.category!.type;
      _selectedIcon = widget.category!.icon;
      _selectedColor = widget.category!.colorHex;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildModernAppBar(),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Aperçu de la catégorie
                        _buildCategoryPreview(),

                        const SizedBox(height: 24),

                        // Type de catégorie
                        _buildTypeSelector(),

                        const SizedBox(height: 20),

                        // Nom
                        _buildNameField(),

                        const SizedBox(height: 20),

                        // Sélection d'icône
                        _buildIconSelector(),

                        const SizedBox(height: 20),

                        // Sélection de couleur
                        _buildColorSelector(),

                        const SizedBox(height: 32),

                        // Bouton de sauvegarde
                        _buildSaveButton(),

                        const SizedBox(height: 20),
                      ],
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

  Widget _buildModernAppBar() {
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
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
            ],
          ),
        ),
        child: FlexibleSpaceBar(
          centerTitle: false,
          title: Text(
            widget.category == null ? 'Nouvelle catégorie' : 'Modifier catégorie',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildCategoryPreview() {
    final color = Color(int.parse('0xFF${_selectedColor.substring(1)}'));
    final icon = _availableIcons.firstWhere(
          (i) => i['name'] == _selectedIcon,
      orElse: () => _availableIcons.first,
    )['icon'] as IconData;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 40),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aperçu',
                  style: GoogleFonts.inter(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _nameController.text.isEmpty ? 'Nom de la catégorie' : _nameController.text,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedType == TransactionType.expense ? 'Dépense' : 'Revenu',
                  style: GoogleFonts.inter(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Type de catégorie',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildTypeOption(
                  'Dépense',
                  TransactionType.expense,
                  Icons.south_west,
                  Colors.red,
                ),
              ),
              Expanded(
                child: _buildTypeOption(
                  'Revenu',
                  TransactionType.income,
                  Icons.north_east,
                  Colors.green,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeOption(
      String label,
      TransactionType type,
      IconData icon,
      Color color,
      ) {
    final isSelected = _selectedType == type;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedType = type;
            HapticFeedback.selectionClick();
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? color : Colors.grey[400],
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: isSelected ? color : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Nom de la catégorie',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: _nameController,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'Ex: Coiffure, Restaurant, etc.',
              hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
              prefixIcon: Icon(
                Icons.label_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(20),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer un nom';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {}); // Pour mettre à jour l'aperçu
            },
          ),
        ),
      ],
    );
  }

  Widget _buildIconSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Icône',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: _availableIcons.length,
            itemBuilder: (context, index) {
              final iconData = _availableIcons[index];
              final isSelected = _selectedIcon == iconData['name'];
              final color = Color(int.parse('0xFF${_selectedColor.substring(1)}'));

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedIcon = iconData['name'];
                      HapticFeedback.selectionClick();
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withOpacity(0.15) : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? color : Colors.grey[200]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Icon(
                      iconData['icon'] as IconData,
                      color: isSelected ? color : Colors.grey[600],
                      size: 24,
                    ),
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
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Couleur',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: _availableColors.length,
            itemBuilder: (context, index) {
              final colorHex = _availableColors[index];
              final color = Color(int.parse('0xFF${colorHex.substring(1)}'));
              final isSelected = _selectedColor == colorHex;

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedColor = colorHex;
                      HapticFeedback.selectionClick();
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.grey[800]! : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                          : [],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveCategory,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.5,
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 24, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              widget.category == null ? 'Créer la catégorie' : 'Mettre à jour',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final category = CategoryModel(
        id: widget.category?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        icon: _selectedIcon,
        colorHex: _selectedColor,
        type: _selectedType,
        isDefault: false, // Les catégories créées par l'utilisateur ne sont pas par défaut
      );

      if (widget.category == null) {
        await ref.read(categoryNotifierProvider.notifier).addCategory(category);
      } else {
        await ref.read(categoryNotifierProvider.notifier).updateCategory(category);
      }

      if (mounted) {
        HapticFeedback.mediumImpact();
        Navigator.pop(context);
        _showSnackBar(
          widget.category == null
              ? '✓ Catégorie créée avec succès'
              : '✓ Catégorie mise à jour',
          Colors.green,
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erreur: $e', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}