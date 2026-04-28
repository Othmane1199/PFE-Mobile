import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrdexLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? color;

  const OrdexLogo({
    super.key,
    this.size = 100,
    this.showText = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color logoColor = color ?? (isDark ? Colors.white : Colors.black);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(size * 0.25),
            border: Border.all(
              color: logoColor.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Text(
            'OR',
            style: GoogleFonts.outfit(
              fontSize: size * 0.45,
              fontWeight: FontWeight.w900,
              color: logoColor,
              letterSpacing: -size * 0.02,
            ),
          ),
        ),
        if (showText) ...[
          SizedBox(height: size * 0.15),
          Text(
            'ORDEX',
            style: GoogleFonts.outfit(
              fontSize: size * 0.35,
              fontWeight: FontWeight.w800,
              letterSpacing: size * 0.08,
              color: logoColor,
            ),
          ),
        ],
      ],
    );
  }
}
