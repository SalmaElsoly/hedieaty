import 'package:flutter/material.dart';
import 'package:hedieaty/controllers/user.dart';
import 'package:hedieaty/models/user.dart';
import 'package:hedieaty/shared/components/form.dart';
import 'package:hedieaty/shared/components/tabs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late bool _isEditing = false;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  final _formKey = GlobalKey<FormState>();

  UserController _userController = UserController();

  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _smsNotifications = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  static const List<Tab> tabs = <Tab>[
    Tab(text: 'Info'),
    Tab(text: 'Settings'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: _userController.getUserStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong'));
        }

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: Text('My Profile'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: defaultTabBar(context, tabs, _tabController),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _isEditing ? _pickImage : null,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 10,
                                color: Colors.black12,
                                spreadRadius: 5
                              )
                            ]
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage: _imageFile != null
                                ? FileImage(_imageFile!) as ImageProvider
                                : _imageUrl != null
                                    ? NetworkImage(_imageUrl!) as ImageProvider
                                    : AssetImage('assets/images/avater.png'),
                            child: _isEditing
                                ? Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black26,
                                    ),
                                    child: Icon(Icons.camera_alt,
                                        color: Colors.white, size: 30),
                                  )
                                : null,
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                defaultFormField(
                                  type: TextInputType.name,
                                  label: 'Username',
                                  prefix: Icons.person,
                                  isPassword: false,
                                  controller: _usernameController,
                                  readOnly: !_isEditing,
                                  validate: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your username';
                                    }
                                    return null;
                                  }
                                ),
                                SizedBox(height: 20),
                                defaultFormField(
                                  type: TextInputType.emailAddress,
                                  label: 'Email',
                                  prefix: Icons.email,
                                  isPassword: false,
                                  controller: _emailController,
                                  readOnly: !_isEditing,
                                  validate: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    if (!value.contains('@')) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  }
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      defaultFormButton(
                        onPressed: () {
                          setState(() {
                            if (_isEditing) {
                              _userController.updateProfile()
                            } else {
                              _isEditing = true;
                            }
                          });
                        },
                        child: Text(
                          _isEditing ? 'Save Changes' : 'Edit Profile',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        screenWidth: MediaQuery.of(context).size.width,
                      )
                    ],
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 8,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.white, Colors.grey.shade50],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.settings,
                                    size: 28,
                                    color: Theme.of(context).primaryColor),
                                SizedBox(width: 10),
                                Text(
                                  'Preferences',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            ListTile(
                              leading: Icon(Icons.notifications,
                                  color: Theme.of(context).primaryColor),
                              title: Text('Push Notifications',
                                  style: TextStyle(fontWeight: FontWeight.w500)),
                              trailing: Switch(
                                value: _pushNotifications,
                                onChanged: (bool value) {
                                  setState(() {
                                    _pushNotifications = value;
                                  });
                                },
                              ),
                            ),
                            ListTile(
                              leading: Icon(Icons.email,
                                  color: Theme.of(context).primaryColor),
                              title: Text('Email Notifications',
                                  style: TextStyle(fontWeight: FontWeight.w500)),
                              trailing: Switch(
                                value: _emailNotifications,
                                onChanged: (bool value) {
                                  setState(() {
                                    _emailNotifications = value;
                                  });
                                },
                              ),
                            ),
                            ListTile(
                              leading: Icon(Icons.message,
                                  color: Theme.of(context).primaryColor),
                              title: Text('SMS Notifications',
                                  style: TextStyle(fontWeight: FontWeight.w500)),
                              trailing: Switch(
                                value: _smsNotifications,
                                onChanged: (bool value) {
                                  setState(() {
                                    _smsNotifications = value;
                                  });
                                },
                              ),
                            ),
                            Divider(height: 30, thickness: 1.5),
                            Row(
                              children: [
                                Icon(Icons.volume_up,
                                    size: 28,
                                    color: Theme.of(context).primaryColor),
                                SizedBox(width: 10),
                                Text(
                                  'Sound & Vibration',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            ListTile(
                              leading: Icon(Icons.volume_up,
                                  color: Theme.of(context).primaryColor),
                              title: Text('Sound',
                                  style: TextStyle(fontWeight: FontWeight.w500)),
                              trailing: Switch(
                                value: _soundEnabled,
                                onChanged: (bool value) {
                                  setState(() {
                                    _soundEnabled = value;
                                  });
                                },
                              ),
                            ),
                            ListTile(
                              leading: Icon(Icons.vibration,
                                  color: Theme.of(context).primaryColor),
                              title: Text('Vibration',
                                  style: TextStyle(fontWeight: FontWeight.w500)),
                              trailing: Switch(
                                value: _vibrationEnabled,
                                onChanged: (bool value) {
                                  setState(() {
                                    _vibrationEnabled = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}