import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerHelper {
  final BuildContext context;
  String? imagePath;
  final Function(String) onImageSelected;

  ImagePickerHelper({required this.context, required this.onImageSelected});

  Future<void> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      imagePath = image.path;
      onImageSelected(image.path);
    }
  }

  void showImagePickerDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Select Image'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  pickImage(ImageSource.gallery);
                },
                icon: Icon(Icons.photo),
                label: Text('Gallery'),
                style: ElevatedButton.styleFrom(
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
                icon: Icon(Icons.camera),
                label: Text('Camera'),
                style: ElevatedButton.styleFrom(
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