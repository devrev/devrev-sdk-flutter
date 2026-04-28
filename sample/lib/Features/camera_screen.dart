import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:devrev_sdk_flutter/devrev.dart';
import 'dart:io';
import 'dart:developer' as developer;

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  File? _capturedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    DevRev.trackScreenName("Camera");
  }

  Future<void> _showCameraUnavailableDialog() async {
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Unavailable'),
        content: const Text('This device does not have a camera.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showCameraAccessDeniedDialog() async {
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Access Denied'),
        content: const Text(
          'Camera access has been denied. Please go to Settings → Privacy → Camera and enable access for this app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _openCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _capturedImage = File(image.path);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Photo Captured!')),
          );
        }
        developer.log("Photo captured: ${image.path}");
      }
    } on PlatformException catch (e) {
      developer.log("Camera error: code=${e.code} message=${e.message}",
          error: e);
      if (e.code == 'camera_access_denied' ||
          e.code == 'camera_access_restricted') {
        await _showCameraAccessDeniedDialog();
      } else {
        await _showCameraUnavailableDialog();
      }
    } catch (e) {
      developer.log("Error capturing photo", error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo Capture Failed')),
        );
      }
    }
  }

  void _clearPhoto() {
    setState(() {
      _capturedImage = null;
    });
  }

  @override
  void dispose() {
    _cleanupTempFile();
    super.dispose();
  }

  Future<void> _cleanupTempFile() async {
    if (_capturedImage != null && await _capturedImage!.exists()) {
      try {
        await _capturedImage!.delete();
      } catch (e) {
        developer.log('Failed to cleanup temp file', error: e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _capturedImage != null
                ? SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          DevRevMask(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _capturedImage!,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: _clearPhoto,
                            icon: const Icon(Icons.delete),
                            label: const Text('Clear Photo'),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.expand(),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openCamera,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Open Camera'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
