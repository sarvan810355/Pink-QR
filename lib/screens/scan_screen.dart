import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../models/qr_history_item.dart';
import '../services/ads_service.dart';
import '../services/feedback_service.dart';
import '../services/history_service.dart';
import '../services/qr_content_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_background.dart';
import '../widgets/permission_denied_view.dart';
import '../widgets/scan_result_sheet.dart';
import '../widgets/sparkle_burst.dart';

/// Scan Screen — pink animated scan-line camera view with smart
/// content-type detection and a cute success burst.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

enum _PermState { checking, granted, denied }

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  MobileScannerController? _controller;
  _PermState _permState = _PermState.checking;
  bool _torchOn = false;
  bool _showSuccess = false;
  bool _busy = false;

  late final AnimationController _lineController;

  @override
  void initState() {
    super.initState();
    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.camera.request();
    if (!mounted) return;
    if (status.isGranted) {
      setState(() {
        _permState = _PermState.granted;
        _controller = MobileScannerController(
          detectionSpeed: DetectionSpeed.noDuplicates,
        );
      });
    } else {
      setState(() => _permState = _PermState.denied);
    }
  }

  @override
  void dispose() {
    _lineController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_busy) return;
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null || code.isEmpty) return;
    _busy = true;
    await _controller?.stop();

    final type = QrContentService.detectType(code);
    final item = QrHistoryItem(
      type: type,
      source: QrSourceKind.scanned,
      rawData: code,
      title: _titleFor(type, code),
    );

    await FeedbackService.instance.scanSuccess();
    if (!mounted) return;
    setState(() => _showSuccess = true);

    if (!mounted) return;
    await context.read<HistoryService>().add(item);
    AdsService.instance.registerActionAndMaybeShow();
  }

  String _titleFor(QrItemType type, String data) {
    switch (type) {
      case QrItemType.wifi:
        return 'Wi-Fi: ${QrContentService.parseWifi(data)['S'] ?? 'Network'}';
      case QrItemType.contact:
        return QrContentService.parseContactName(data);
      case QrItemType.url:
        return data.length > 40 ? '${data.substring(0, 40)}…' : data;
      default:
        return data.length > 40 ? '${data.substring(0, 40)}…' : data;
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null || _controller == null) return;
    final capture = await _controller!.analyzeImage(file.path);
    if (capture != null && capture.barcodes.isNotEmpty) {
      await _onDetect(capture);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No QR code found in that image 🥺')),
      );
    }
  }

  void _resumeScanning() {
    setState(() => _showSuccess = false);
    _busy = false;
    _controller?.start();
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: switch (_permState) {
          _PermState.checking => const Center(child: CircularProgressIndicator(color: AppColors.hotPink)),
          _PermState.denied => PermissionDeniedView(onRetry: _checkPermission),
          _PermState.granted => _buildScanner(context),
        },
      ),
    );
  }

  Widget _buildScanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Text('Scan a QR ✨', style: AppTextStyles.heading(
              Theme.of(context).textTheme.bodyLarge!.color!)),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.lg),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  MobileScanner(controller: _controller, onDetect: _onDetect),
                  _ScanWindowOverlay(lineController: _lineController),
                  Positioned(
                    top: 12,
                    left: 12,
                    right: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _RoundIconButton(
                          icon: _torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                          onTap: () async {
                            await _controller?.toggleTorch();
                            setState(() => _torchOn = !_torchOn);
                          },
                        ),
                        _RoundIconButton(
                          icon: Icons.photo_library_rounded,
                          onTap: _pickFromGallery,
                        ),
                      ],
                    ),
                  ),
                  if (_showSuccess)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.35),
                        child: SparkleTriggerOverlay(
                          show: true,
                          onComplete: () {
                            final item = context.read<HistoryService>().items.firstOrNull;
                            if (item != null) {
                              ScanResultSheet.show(context, item).then((_) => _resumeScanning());
                            } else {
                              _resumeScanning();
                            }
                          },
                          child: const Center(
                            child: Text('🎉', style: TextStyle(fontSize: 56)),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanWindowOverlay extends StatelessWidget {
  final AnimationController lineController;
  const _ScanWindowOverlay({required this.lineController});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: FractionallySizedBox(
          widthFactor: 0.72,
          heightFactor: 0.42,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  border: Border.all(color: AppColors.softPink, width: 3),
                ),
              ),
              AnimatedBuilder(
                animation: lineController,
                builder: (context, child) {
                  return Align(
                    alignment: Alignment(0, -1 + 2 * lineController.value),
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [
                          Colors.transparent,
                          AppColors.hotPink,
                          Colors.transparent,
                        ]),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.hotPink.withValues(alpha: 0.7),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
