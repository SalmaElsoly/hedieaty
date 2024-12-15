import 'package:flutter/material.dart';
import 'package:hedieaty/controllers/gifts.dart';
import 'package:hedieaty/models/event.dart';
import 'dart:io';

import 'package:hedieaty/shared/methods/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/gift.dart';
import '../shared/components/form.dart';
import '../shared/theme.dart';

class GiftCreatePage extends StatefulWidget {
  final GiftModel? gift;
  final EventModel? event;

  const GiftCreatePage({super.key, this.gift, this.event});

  @override
  _GiftCreatePageState createState() => _GiftCreatePageState();
}

class _GiftCreatePageState extends State<GiftCreatePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  GiftCategory _category = GiftCategory.other;
  String _imagePath = '';
  String? _imageError;
  bool _isLoading = false;

  final GiftsController _giftsController = GiftsController.instance;
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.gift?.name ?? '');
    _priceController = TextEditingController(text: widget.gift?.price.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.gift?.description ?? '');
    if (widget.gift?.category != null) {
      _category = GiftCategory.values.firstWhere(
        (e) => e.toString() == 'GiftCategory.${widget.gift!.category}',
        orElse: () => GiftCategory.other,
      );
    }
    _imagePath = widget.gift?.giftImageUrl ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool validateImage() {
    if (_imagePath.isEmpty) {
      setState(() {
        _imageError = 'Please select an image';
      });
      return false;
    }
    setState(() {
      _imageError = null;
    });
    return true;
  }

  void _saveGift() async {
    if (_formKey.currentState!.validate() && validateImage()) {
      setState(() {
        _isLoading = true;
      });
      final editedGift = GiftModel(
        id: widget.gift!.id,
        name: _nameController.text,
        price: double.parse(_priceController.text),
        category: _category,
        description: _descriptionController.text,
        giftImageUrl: _imagePath,
        eventId: widget.gift?.eventId,
        firestoreId: widget.gift?.firestoreId,
      );
      try {
        await _giftsController.updateGift(editedGift, context);
        setState(() {
          _isLoading = false;
        });
        if (context.mounted) {
          Navigator.of(context).pop(editedGift);
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _createGift() async {
    if (_formKey.currentState!.validate() && validateImage()) {
      setState(() {
        _isLoading = true;
      });
      final newGift = GiftModel(
        name: _nameController.text,
        price: double.parse(_priceController.text),
        category: _category,
        description: _descriptionController.text,
        giftImageUrl: _imagePath,
      );
      try {
        await _giftsController.createGift(newGift, widget.event!, context);
        setState(() {
          _isLoading = false;
        });
        if (context.mounted) {
          Navigator.of(context).pop(newGift);
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.gift != null;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Gift' : 'Create Gift'),
        elevation: 2,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Theme.of(context).primaryColor.withOpacity(0.4), Colors.white],
          ),
        ),
        height: screenHeight,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              elevation: 5,
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Column(
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
                                          _imageError = null;
                                        });
                                      }).showImagePickerDialog();
                                },
                                icon: Icon(Icons.image)),
                          ),
                          if (_imageError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                _imageError!,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        isEditing ? 'Edit Your Gift' : 'Create Your Gift',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 30),
                      defaultFormField(
                        controller: _nameController,
                        label: 'Name',
                        hintText: 'Enter gift name',
                        prefix: Icons.card_giftcard,
                        validate: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                        type: TextInputType.name,
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: defaultFormField(
                              controller: _priceController,
                              label: 'Price',
                              hintText: 'Enter gift price',
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
                          SizedBox(width: 20),
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<GiftCategory>(
                              isExpanded: true,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(color: Colors.transparent),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(color: Colors.transparent),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(color: Colors.transparent),
                                ),
                                filled: true,
                                fillColor: Provider.of<ThemeColorData>(context, listen: false).isDark?Colors.black38:Theme.of(context).colorScheme.onSecondary.withOpacity(0.7),
                                prefixIcon: Icon(Icons.category, color: Theme.of(context).primaryColor),
                              ),
                              value: _category,
                              items: GiftCategory.values.map((category) {
                                return DropdownMenuItem<GiftCategory>(
                                  value: category,
                                  child: Text(
                                    category.name.toUpperCase(),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 12),
                                  ),
                                );
                              }).toList(),
                              onChanged: (GiftCategory? value) {
                                setState(() {
                                  _category = value!;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a category';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      defaultFormField(
                        type: TextInputType.multiline,
                        controller: _descriptionController,
                        label: 'Description',
                        hintText: 'Enter gift description',
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
                        onPressed: _isLoading ? (){} : (isEditing ? _saveGift : _createGift),
                        child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              isEditing ? 'Save Changes' : 'Create Gift',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        screenWidth: screenWidth,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}