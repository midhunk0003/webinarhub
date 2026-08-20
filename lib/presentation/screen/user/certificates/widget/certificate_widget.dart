import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:lms/core/colors.dart';

/// A rich, print-quality completion certificate.
///
/// Wrap this in [RepaintBoundary] (via [cerificationKey]) wherever you
/// capture it to an image for sharing / PDF export.
class CertificateWidget extends StatelessWidget {
  final String? course;
  final String? studentName;
  final String? instructorName;
  final GlobalKey? cerificationKey;

  /// Optional extras — safe to leave null, sensible fallbacks are used.
  final String? organizationName;
  final String? certificateId;
  final DateTime? completionDate;
  final double? durationHours;

  const CertificateWidget({
    Key? key,
    required this.course,
    required this.studentName,
    required this.instructorName,
    required this.cerificationKey,
    this.organizationName,
    this.certificateId,
    this.completionDate,
    this.durationHours,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final certificateWidth = screenSize.width * 0.92;
    // This is now a MINIMUM height — the certificate will grow taller
    // automatically if the student name / course title needs more room.
    final certificateMinHeight =
        certificateWidth * 0.68; // classic landscape ratio
    final scale = certificateWidth / 900;

    final gold = const Color(0xFFC9A24B);
    final ink = const Color(0xFF1F2430);
    final subtleInk = const Color(0xFF6B7280);
    final paper = const Color(0xFFFFFDF7);

    final resolvedDate = completionDate ?? DateTime.now();
    final resolvedId =
        certificateId ?? _generateId(studentName, course, resolvedDate);
    final resolvedOrg = organizationName ?? 'Wisbato Learning';

    // Shrink the name's font size a bit if it's long, so short/medium
    // names still look identical to before, and only very long names
    // wrap to a second line instead of overflowing.
    final name = studentName ?? 'Student Name';
    final nameFontSize = _resolveNameFontSize(name, scale);

    return RepaintBoundary(
      key: cerificationKey,
      child: Container(
        width: certificateWidth,
        // NOTE: fixed `height:` removed — replaced with a `constraints`
        // minHeight so the box can grow if content needs more space,
        // which is what removes the overflow error.
        constraints: BoxConstraints(minHeight: certificateMinHeight),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: paper,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 28 * scale,
              offset: Offset(0, 10 * scale),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Faint corner-to-corner watermark pattern.
            Positioned.fill(
              child: CustomPaint(
                painter: _WatermarkPainter(color: gold.withOpacity(0.06)),
              ),
            ),

            // Outer + inner border frame.
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(14 * scale),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: gold, width: 2.5 * scale),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(6 * scale),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColor.primaryBlueMid,
                          width: 1 * scale,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Ornamental corner flourishes.
            Positioned(
              top: 18 * scale,
              left: 18 * scale,
              child: _CornerFlourish(scale: scale, color: gold),
            ),
            Positioned(
              top: 18 * scale,
              right: 18 * scale,
              child: Transform.flip(
                flipX: true,
                child: _CornerFlourish(scale: scale, color: gold),
              ),
            ),
            Positioned(
              bottom: 18 * scale,
              left: 18 * scale,
              child: Transform.flip(
                flipY: true,
                child: _CornerFlourish(scale: scale, color: gold),
              ),
            ),
            Positioned(
              bottom: 18 * scale,
              right: 18 * scale,
              child: Transform.flip(
                flipX: true,
                flipY: true,
                child: _CornerFlourish(scale: scale, color: gold),
              ),
            ),

            // Main content.
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 64 * scale,
                vertical: 40 * scale,
              ),
              child: Column(
                // MainAxisSize.min lets the Column (and therefore the
                // whole certificate) size itself to its content instead
                // of being forced to an exact fixed height.
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Emblem
                  Container(
                    width: 56 * scale,
                    height: 56 * scale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [gold, gold.withOpacity(0.6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Icon(
                      Icons.school_rounded,
                      color: paper,
                      size: 30 * scale,
                    ),
                  ),
                  SizedBox(height: 14 * scale),

                  Text(
                    resolvedOrg.toUpperCase(),
                    style: TextStyle(
                      fontSize: 13 * scale,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 5 * scale,
                      color: subtleInk,
                    ),
                  ),
                  SizedBox(height: 18 * scale),

                  Text(
                    'CERTIFICATE',
                    style: TextStyle(
                      fontSize: 46 * scale,
                      fontWeight: FontWeight.bold,
                      color: ink,
                      letterSpacing: 9 * scale,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    'OF COMPLETION',
                    style: TextStyle(
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w500,
                      color: gold,
                      letterSpacing: 6 * scale,
                    ),
                  ),

                  SizedBox(height: 28 * scale),
                  _DividerWithDiamond(scale: scale, color: gold),
                  SizedBox(height: 26 * scale),

                  Text(
                    'This certificate is proudly presented to',
                    style: TextStyle(
                      fontSize: 15 * scale,
                      color: subtleInk,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(height: 14 * scale),

                  // Student name — wraps onto a 2nd line and shrinks
                  // slightly for long names, instead of overflowing.
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                    child: Text(
                      name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                      style: TextStyle(
                        fontSize: nameFontSize,
                        fontWeight: FontWeight.w700,
                        color: ink,
                        fontFamily: 'Georgia',
                        height: 1.15,
                      ),
                    ),
                  ),
                  SizedBox(height: 6 * scale),
                  Container(
                    width: 220 * scale,
                    height: 1.4 * scale,
                    color: gold.withOpacity(0.5),
                  ),

                  SizedBox(height: 22 * scale),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40 * scale),
                    child: Text(
                      'for successfully completing the course',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15 * scale, color: subtleInk),
                    ),
                  ),
                  SizedBox(height: 10 * scale),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40 * scale),
                    child: Text(
                      course ?? 'Course Title',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                      style: TextStyle(
                        fontSize: 26 * scale,
                        fontWeight: FontWeight.bold,
                        color: AppColor.primaryBlueMid,
                      ),
                    ),
                  ),

                  if (durationHours != null) ...[
                    SizedBox(height: 10 * scale),
                    Text(
                      '(${durationHours!.toStringAsFixed(durationHours! % 1 == 0 ? 0 : 1)} hours of instruction)',
                      style: TextStyle(
                        fontSize: 13 * scale,
                        color: subtleInk,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],

                  // `Spacer()` needs a bounded height to flex within,
                  // which we no longer have now that the certificate can
                  // grow. Replaced with fixed breathing room instead.
                  SizedBox(height: 34 * scale),

                  // Footer: signature / date / seal / certificate id.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: _SignatureBlock(
                          scale: scale,
                          name: instructorName ?? 'Instructor',
                          role: 'Course Instructor',
                          ink: ink,
                          subtleInk: subtleInk,
                        ),
                      ),
                      SizedBox(width: 20 * scale),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _Seal(scale: scale, gold: gold, paper: paper),
                          SizedBox(height: 6 * scale),
                          Text(
                            'ID: $resolvedId',
                            style: TextStyle(
                              fontSize: 9 * scale,
                              color: subtleInk,
                              letterSpacing: 0.5 * scale,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 20 * scale),
                      Expanded(
                        child: _SignatureBlock(
                          scale: scale,
                          name: DateFormat(
                            'MMMM dd, yyyy',
                          ).format(resolvedDate),
                          role: 'Date Issued',
                          ink: ink,
                          subtleInk: subtleInk,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _generateId(String? student, String? course, DateTime date) {
    final raw = '${student ?? ''}${course ?? ''}${date.millisecondsSinceEpoch}';
    final hash = raw.hashCode.toUnsigned(20).toRadixString(36).toUpperCase();
    return 'CERT-${DateFormat('yyyy').format(date)}-$hash';
  }

  /// Shrinks the student-name font size a bit for longer names so it's
  /// less likely to need 2 lines at all; very long names still wrap
  /// (maxLines: 2) instead of overflowing.
  static double _resolveNameFontSize(String name, double scale) {
    final baseSize = 38 * scale;
    if (name.length <= 20) return baseSize;
    if (name.length <= 30) return baseSize * 0.82;
    return baseSize * 0.68;
  }
}

class _SignatureBlock extends StatelessWidget {
  final double scale;
  final String name;
  final String role;
  final Color ink;
  final Color subtleInk;

  const _SignatureBlock({
    required this.scale,
    required this.name,
    required this.role,
    required this.ink,
    required this.subtleInk,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 15 * scale,
            fontWeight: FontWeight.w600,
            fontFamily: 'Georgia',
            fontStyle: FontStyle.italic,
            color: ink,
          ),
        ),
        SizedBox(height: 4 * scale),
        Container(height: 1 * scale, color: subtleInk.withOpacity(0.5)),
        SizedBox(height: 6 * scale),
        Text(
          role.toUpperCase(),
          style: TextStyle(
            fontSize: 10 * scale,
            letterSpacing: 1.5 * scale,
            color: subtleInk,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _Seal extends StatelessWidget {
  final double scale;
  final Color gold;
  final Color paper;

  const _Seal({required this.scale, required this.gold, required this.paper});

  @override
  Widget build(BuildContext context) {
    final size = 74 * scale;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Fallback vector seal drawn in code so the widget never breaks
          // if the svg asset is missing; swap for SvgPicture.asset below
          // if you want the illustrated asset instead.
          CustomPaint(
            size: Size(size, size),
            painter: _SealPainter(color: gold),
          ),
          Icon(Icons.star_rounded, color: paper, size: 20 * scale),
        ],
      ),
    );
  }
}

class _DividerWithDiamond extends StatelessWidget {
  final double scale;
  final Color color;

  const _DividerWithDiamond({required this.scale, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60 * scale,
          height: 1.2 * scale,
          color: color.withOpacity(0.6),
        ),
        SizedBox(width: 10 * scale),
        Transform.rotate(
          angle: math.pi / 4,
          child: Container(width: 8 * scale, height: 8 * scale, color: color),
        ),
        SizedBox(width: 10 * scale),
        Container(
          width: 60 * scale,
          height: 1.2 * scale,
          color: color.withOpacity(0.6),
        ),
      ],
    );
  }
}

class _CornerFlourish extends StatelessWidget {
  final double scale;
  final Color color;

  const _CornerFlourish({required this.scale, required this.color});

  @override
  Widget build(BuildContext context) {
    final size = 34 * scale;
    return CustomPaint(
      size: Size(size, size),
      painter: _CornerPainter(color: color),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  _CornerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final path =
        Path()
          ..moveTo(0, size.height * 0.55)
          ..quadraticBezierTo(0, 0, size.width * 0.55, 0);
    canvas.drawPath(path, paint);

    final dotPaint = Paint()..color = color;
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.15),
      2.5,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CornerPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _SealPainter extends CustomPainter {
  final Color color;
  _SealPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()..color = color;

    // Scalloped edge — a ring of small circles behind a solid disc.
    const points = 16;
    for (var i = 0; i < points; i++) {
      final angle = (2 * math.pi / points) * i;
      final offset = Offset(
        center.dx + radius * 0.92 * math.cos(angle),
        center.dy + radius * 0.92 * math.sin(angle),
      );
      canvas.drawCircle(offset, radius * 0.16, paint);
    }
    canvas.drawCircle(center, radius * 0.72, paint..color = color);
    canvas.drawCircle(
      center,
      radius * 0.72,
      Paint()
        ..color = Colors.white.withOpacity(0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _SealPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _WatermarkPainter extends CustomPainter {
  final Color color;
  _WatermarkPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    const step = 46.0;
    for (double x = -size.height; x < size.width; x += step) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WatermarkPainter oldDelegate) => false;
}
