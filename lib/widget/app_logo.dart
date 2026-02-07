import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? color;

  const AppLogo({
    Key? key,
    this.size = 80,
    this.showText = true,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryColor = color ?? Theme.of(context).colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo Icon
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor,
                primaryColor.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(size * 0.25),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Coin icon
              Center(
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  size: size * 0.5,
                  color: Colors.white,
                ),
              ),
              // Chart line overlay
              Positioned(
                right: size * 0.15,
                top: size * 0.15,
                child: Container(
                  width: size * 0.25,
                  height: size * 0.25,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.trending_up,
                    size: size * 0.15,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),

        // App Name
        if (showText) ...[
          SizedBox(height: size * 0.15),
          Text(
            'ChikaBin',
            style: GoogleFonts.inter(
              fontSize: size * 0.25,
              fontWeight: FontWeight.bold,
              color: primaryColor,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            'Gestion Budget',
            style: GoogleFonts.inter(
              fontSize: size * 0.12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
              letterSpacing: 1,
            ),
          ),
        ],
      ],
    );
  }
}