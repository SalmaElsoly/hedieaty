import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePickerHelper {
  final BuildContext context;
  String? imagePath;
  final Function(String) onImageSelected;

  ImagePickerHelper({required this.context, required this.onImageSelected});

  Future<bool> _handlePermission(Permission permission) async {
    final status = await permission.status;
    if (status.isGranted) {
      return true;
    }
    final result = await permission.request();
    if (!result.isGranted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).dialogBackgroundColor,
          title: Text('Permission Required',
              style: TextStyle(
                  color: Theme.of(context).textTheme.titleLarge?.color)),
          content: Text('Please enable required permissions in settings',
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.secondary,
              ),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                openAppSettings();
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: Text('Open Settings'),
            ),
          ],
        ),
      );
      return false;
    }
    return result.isGranted;
  }

  Future<void> pickImage(ImageSource source) async {
    bool hasPermission = true;
    if (source == ImageSource.camera) {
      hasPermission = await _handlePermission(Permission.camera);
    } else if (source == ImageSource.gallery) {
      hasPermission = true;
    }

    if (hasPermission) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);

      if (image != null) {
        imagePath = image.path;
        onImageSelected(image.path);
      }
    }
  }

  void showImagePickerDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Theme.of(context).dialogBackgroundColor,
              title: Text('Select Image',
                  style: TextStyle(
                      color: Theme.of(context).textTheme.titleLarge?.color)),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      pickImage(ImageSource.gallery);
                    },
                    icon: Icon(Icons.photo,
                        color: Theme.of(context).colorScheme.onPrimary),
                    label: Text('Gallery',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      elevation: 0.0,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      pickImage(ImageSource.camera);
                    },
                    icon: Icon(Icons.camera,
                        color: Theme.of(context).colorScheme.onPrimary),
                    label: Text('Camera',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      elevation: 0.0,
                    ),
                  ),
                ],
              ),
            ));
  }
}
