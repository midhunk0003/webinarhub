import 'package:flutter/material.dart';
import 'package:lms/core/colors.dart';
import 'package:lms/presentation/screen/user/certificates/certificate_service.dart';
import 'package:lms/presentation/screen/user/certificates/widget/certificate_widget.dart';
import 'package:lms/presentation/widgets/common_custom_app_bar_widget.dart';
import 'package:lms/presentation/widgets/reusablebackground/reusablebackground.dart';

class CertificatesPreviewScreen extends StatefulWidget {
  const CertificatesPreviewScreen({Key? key}) : super(key: key);

  @override
  _CertificatesPreviewScreenState createState() =>
      _CertificatesPreviewScreenState();
}

class _CertificatesPreviewScreenState extends State<CertificatesPreviewScreen> {
  @override
  final GlobalKey certificateKey = GlobalKey();
  bool _isGenerating = false;
  final TransformationController _transformationController =
      TransformationController();
  String? _instructorName = "Instructor Name";

  Future<void> _downloadCertificates() async {
    if (_isGenerating) return;
    setState(() {
      _isGenerating = true;
    });
    try {
      final certificateBytes = await CertificateService.generateCerificate(
        studentName: "Abhinand",
        instructorName: _instructorName ?? "Instructor Name",
        course: "UI/UX DESIGNER",
        certificateKey: certificateKey,
      );

      if (certificateBytes != null) {
        final isSaved = await CertificateService.saveCertificate(
          certificateBytes,
        );
        if (isSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Certificate saved to gallery')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save certificate')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate certificate')),
        );
      }
    } catch (e) {
      debugPrint('Error downloading certificate: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while downloading')),
      );
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
  }

  Widget build(BuildContext context) {
    return Reusablebackground(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isTablet = constraints.maxWidth > 600;
          return Column(
            children: [
              SizedBox(height: isTablet ? 80 : 66),
              CommonCustomAppBarWidget(
                isTablet: isTablet,
                showBackButton: true,
                title: "Completion Certificate",
                onBackButtonPressed: () {
                  Navigator.pop(context);
                },
                onShareButtonPressed: () {},
                showShareButton: false,
              ),
              SizedBox(height: isTablet ? 80 : 66),

              Expanded(
                child: Stack(
                  children: [
                    // Certificate
                    Positioned.fill(
                      child: InteractiveViewer(
                        transformationController: _transformationController,
                        minScale: 0.8,
                        maxScale: 4,
                        child: Center(
                          child: CertificateWidget(
                            course: "UI/UX DESIGNER",
                            studentName: "Sivayogesh Balamurugan",
                            instructorName: "MIDHUN K",
                            cerificationKey: certificateKey,
                          ),
                        ),
                      ),
                    ),

                    // // Zoom In
                    // Positioned(
                    //   bottom: 150,
                    //   right: 20,
                    //   child: FloatingActionButton.small(
                    //     heroTag: "zoomIn",
                    //     backgroundColor: Colors.white,
                    //     child: const Icon(Icons.add, color: Colors.black),
                    //     onPressed: () {},
                    //   ),
                    // ),

                    // // Zoom Out
                    // Positioned(
                    //   bottom: 90,
                    //   right: 20,
                    //   child: FloatingActionButton.small(
                    //     heroTag: "zoomOut",
                    //     backgroundColor: Colors.white,
                    //     child: const Icon(Icons.remove, color: Colors.black),
                    //     onPressed: () {},
                    //   ),
                    // ),

                    // Download
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: FloatingActionButton(
                        heroTag: "download",
                        backgroundColor: AppColor.blueGrey,
                        child: const Icon(Icons.download),
                        onPressed: () {
                          _downloadCertificates();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
