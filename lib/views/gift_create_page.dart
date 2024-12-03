import 'package:flutter/material.dart';
import 'dart:io';

import 'package:hedieaty/shared/methods/image_picker.dart';

import '../shared/components/form.dart';

class GiftCreatePage extends StatefulWidget {
  final Map<String, dynamic>? gift;

  const GiftCreatePage({super.key, this.gift});

  @override
  _GiftCreatePageState createState() => _GiftCreatePageState();
}

class _GiftCreatePageState extends State<GiftCreatePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late String _category;
  String _imagePath = '';

  final _dropDownMenuList = [
    'Electronics',
    'Fashion',
    'Home',
    'Beauty',
    'Toys',
    'Books',
    'Sports',
    'Food',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.gift?['name'] ?? '');
    _priceController = TextEditingController(text: widget.gift?['price'] ?? '');
    _descriptionController =
        TextEditingController(text: widget.gift?['description'] ?? '');
    _category = widget.gift?['category'] ?? 'Select Category';
    _imagePath = widget.gift?['image'] ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveGift() {
    if (_formKey.currentState!.validate()) {
      final editedGift = {
        'id': widget.gift?['id'],
        'name': _nameController.text,
        'price': _priceController.text,
        'category': _category,
        'description': _descriptionController.text,
        'image': _imagePath,
      };
      Navigator.of(context).pop(editedGift);
    }
  }

  void _createGift() {
    if (_formKey.currentState!.validate()) {
      final newGift = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'name': _nameController.text,
        'price': _priceController.text,
        'category': _category,
        'description': _descriptionController.text,
        'image': _imagePath,
      };
      Navigator.of(context).pop(newGift);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.gift != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Gift' : 'Create Gift'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 60.0,
                backgroundImage:
                    _imagePath.isNotEmpty ? FileImage(File(_imagePath)) : null,
                child: IconButton(
                    onPressed: () {
                      ImagePickerHelper(
                          context: context,
                          onImageSelected: (imagePath) {
                            setState(() {
                              _imagePath = imagePath;
                            });
                          }).showImagePickerDialog();
                    },
                    icon: Icon(Icons.image)),
              ),
              SizedBox(height: 30),
              defaultFormField(
                controller: _nameController,
                label: 'Name',
                prefix: Icons.card_giftcard,
                validate: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                type: TextInputType.name,
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: defaultFormField(
                      controller: _priceController,
                      label: 'Price',
                      prefix: Icons.attach_money,
                      validate: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid price';
                        }
                        return null;
                      },
                      type: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 30),
                  DropdownMenu<String>(
                    inputDecorationTheme: InputDecorationTheme(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      filled: true,
                      fillColor: Theme.of(context)
                          .colorScheme
                          .onSecondary
                          .withOpacity(0.7),
                    ),
                    dropdownMenuEntries: _dropDownMenuList.map((item) {
                      return DropdownMenuEntry<String>(
                        value: item,
                        label: item,
                      );
                    }).toList(),
                    initialSelection: 'Category',
                    label: Text('Category'),
                    onSelected: (String? value) {
                      setState(() {
                        _category = value!;
                      });
                    },
                    errorText: _category == 'Category'
                        ? 'Please select a category'
                        : null,
                  ),
                ],
              ),
              SizedBox(height: 30),
              defaultFormField(
                type: TextInputType.multiline,
                controller: _descriptionController,
                label: 'Description',
                prefix: Icons.description,
                validate: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              defaultFormButton(
                onPressed: isEditing ? _saveGift : _createGift,
                child: Text(isEditing ? 'Save Gift' : 'Create Gift'),
                screenWidth: MediaQuery.of(context).size.width,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
