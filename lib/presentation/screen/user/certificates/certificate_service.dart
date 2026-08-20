import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

class CertificateService {
  static Future<Uint8List?> generateCerificate({
    required String studentName,
    required String instructorName,
    required String course,
    required GlobalKey certificateKey,
  }) async {
    try {
      RenderRepaintBoundary boundary =
          certificateKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary;
      if (boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 20));
        return generateCerificate(
          studentName: studentName,
          instructorName: instructorName,
          course: course,
          certificateKey: certificateKey,
        );
      }
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error generating certificate: $e');
      return null;
    }
  }

  static Future<bool> saveCertificate(Uint8List certificateBytes) async {
    // Implement the logic to save the certificate bytes to the device's storage
    // You can use packages like path_provider and image_gallery_saver for this purpose

    try {
      final result = await ImageGallerySaverPlus.saveImage(
        certificateBytes,
        quality: 100,
        name: "certificate_${DateTime.now().millisecondsSinceEpoch}",
      );
      debugPrint('Certificate saved to gallery: $result');

      return result['isSuccess'] ?? false;
    } catch (e) {
      debugPrint('Error saving certificate: $e');
      return false;
    }
  }
}
