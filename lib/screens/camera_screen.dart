import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'problem_solution_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = const [];
  int _cameraIndex = 0;
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;
  bool _isTakingPicture = false;
  bool _isInitializing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      if (state == AppLifecycleState.resumed && !_isInitializing) _initCamera();
      return;
    }
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      controller.dispose();
      _cameraController = null;
      if (mounted) setState(() => _isCameraInitialized = false);
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera({int? index}) async {
    if (_isInitializing) return;
    _isInitializing = true;
    if (mounted) setState(() => _errorMessage = null);
    try {
      _cameras = _cameras.isEmpty ? await availableCameras() : _cameras;
      if (_cameras.isEmpty) throw StateError('لم يتم العثور على كاميرا');
      final target = index ?? _cameraIndex;
      _cameraIndex = target.clamp(0, _cameras.length - 1);

      await _cameraController?.dispose();
      final controller = CameraController(_cameras[_cameraIndex], ResolutionPreset.veryHigh, enableAudio: false);
      _cameraController = controller;
      await controller.initialize();
      await controller.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _isCameraInitialized = true;
        _errorMessage = null;
      });
    } catch (e) {
      debugPrint('خطأ في تهيئة الكاميرا: $e');
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
          _errorMessage = 'تعذر تشغيل الكاميرا. تحقق من الصلاحيات ثم حاول مرة أخرى.';
        });
      }
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> _takePicture() async {
    final controller = _cameraController;
    if (_isTakingPicture || controller == null || !controller.value.isInitialized || controller.value.isTakingPicture) return;
    setState(() => _isTakingPicture = true);
    try {
      final image = await controller.takePicture();
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProblemSolutionScreen(
            problem: 'جاري تحليل الصورة محلياً...',
            imagePath: image.path,
          ),
        ),
      );
    } catch (e) {
      debugPrint('خطأ في التصوير: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر التقاط الصورة')));
      }
    } finally {
      if (mounted) setState(() => _isTakingPicture = false);
    }
  }

  Future<void> _toggleFlash() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;
    final next = !_isFlashOn;
    try {
      await controller.setFlashMode(next ? FlashMode.torch : FlashMode.off);
      if (mounted) setState(() => _isFlashOn = next);
    } catch (e) {
      debugPrint('خطأ في الفلاش: $e');
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _isInitializing || _isTakingPicture) return;
    final nextIndex = (_cameraIndex + 1) % _cameras.length;
    setState(() => _isCameraInitialized = false);
    await _initCamera(index: nextIndex);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _cameraController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _cameraController;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_isCameraInitialized && controller != null)
            CameraPreview(controller)
          else if (_errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 64),
                    const SizedBox(height: 16),
                    Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _initCamera, child: const Text('إعادة المحاولة')),
                  ],
                ),
              ),
            )
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 30), onPressed: () => Navigator.pop(context)),
                      IconButton(icon: const Icon(Icons.cameraswitch, color: Colors.white, size: 30), onPressed: _switchCamera),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off, color: Colors.white, size: 28), onPressed: _toggleFlash),
                      GestureDetector(
                        onTap: _isTakingPicture ? null : _takePicture,
                        child: Container(
                          width: 75, height: 75,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF0C206D), Color(0xFF1E3A8A)]),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: _isTakingPicture
                              ? const Padding(padding: EdgeInsets.all(22), child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                              : const Icon(Icons.camera_alt, color: Colors.white, size: 38),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
