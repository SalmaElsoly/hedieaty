import 'package:flutter/material.dart';
import 'package:hedieaty/shared/components/form.dart';
import 'package:hedieaty/shared/components/tabs.dart';

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
  late TextEditingController _mobileController;
  final _formKey = GlobalKey<FormState>();

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
    _mobileController = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 10,
                              color: Colors.black12,
                              spreadRadius: 5)
                        ]),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage('assets/images/avater.png'),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black26,
                        ),
                        child: IconButton(
                          onPressed: () {
                            if (!_isEditing) return;
                          },
                          icon: Icon(Icons.camera_alt,
                              color: Colors.white, size: 30),
                        ),
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
                                    return 'Please enter your new username';
                                  }
                                  return null;
                                }),
                            SizedBox(height: 20),
                            defaultFormField(
                                type: TextInputType.phone,
                                label: 'Mobile Number',
                                prefix: Icons.phone,
                                isPassword: false,
                                controller: _mobileController,
                                readOnly: !_isEditing,
                                validate: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your new mobile number';
                                  }
                                  final regex =
                                      RegExp(r'^(015|011|012|010)\d{8}$');
                                  if (value.length != 11 ||
                                      !regex.hasMatch(value)) {
                                    return 'Please enter a valid mobile number';
                                  }
                                  return null;
                                }),
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
                          if (_formKey.currentState!.validate()) {
                            _isEditing = false;
                          }
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
  }
}
