import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PremiumButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double height;
  final bool isLoading;
  final IconData? icon;

  const PremiumButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height = 56,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? const Color(0xFF4A6CF7),
          foregroundColor: foregroundColor ?? Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.borderRadius = 24,
    this.boxShadow,
    this.border,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color ?? Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          border: border ?? Border.all(color: const Color(0xFFF3F4F6), width: 1),
          boxShadow: boxShadow ??
              [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
        ),
        child: child,
      ),
    );
  }
}

class StatusTag extends StatelessWidget {
  final String text;
  final Color color;

  const StatusTag({
    super.key,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class PremiumTable extends StatelessWidget {
  final List<String> headers;
  final List<List<String>> rows;

  const PremiumTable({
    super.key,
    required this.headers,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: EdgeInsets.zero,
      borderRadius: 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFFF9FAFB)),
            dataRowMaxHeight: double.infinity,
            dataRowMinHeight: 48,
            columnSpacing: 24,
            horizontalMargin: 20,
            dividerThickness: 1,
            border: const TableBorder(
              horizontalInside: BorderSide(color: Color(0xFFF3F4F6), width: 1),
            ),
            columns: headers.map((h) => DataColumn(
              label: Text(
                h.toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF717171),
                  letterSpacing: 1.0,
                ),
              ),
            )).toList(),
            rows: rows.map((row) => DataRow(
              cells: row.map((cell) => DataCell(
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    cell,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: const Color(0xFF1B1B25),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )).toList(),
            )).toList(),
          ),
        ),
      ),
    );
  }
}
