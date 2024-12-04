import 'package:expense_manager/AccountScreen.dart';
import 'package:expense_manager/ImagePic.dart';
import 'package:expense_manager/MYHOME.dart';
import 'package:expense_manager/SettingScreen.dart';
import 'package:expense_manager/export_data_screen.dart';
import 'package:expense_manager/session.dart';
import 'package:expense_manager/welcome_screen.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String profileName = Username!;
  String profileEmail = "$Username@gmail.com";
  String profilePhone = '9356870559';

  void updateProfileInfo(String newName, String newEmail, String newPhone) {
    setState(() {
      profileName = newName;
      profileEmail = newEmail;
      profilePhone = newPhone;
    });
  }

  void _logout() {
    // Perform logout actions here
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out successfully')),
              );
            },
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)  {
                  SessionData.getSessionData();
                  SessionData.isLogin=false;

                  return WelcomeScreen();
                 
                }));
              },
              child: const Text('Logout')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 246, 229, 1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.purple,
                          child: CircleAvatar(
                            radius: 42,
                            backgroundColor: const Color.fromARGB(255, 237, 206, 243),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                  return ImagePickerPage();
                                }));
                              },
                              child: const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.purple,
                              ),
                            )
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(profileName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(profileEmail, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    Text(profilePhone, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ProfileListTile(
                      icon: Icons.account_box,
                      title: 'Account',
                      color: Colors.purple,
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AccountScreen(
                              currentName: profileName,
                              currentEmail: profileEmail,
                              currentPhone: profilePhone,
                            ),
                          ),
                        );
                        if (result != null) {
                          updateProfileInfo(result['name'], result['email'], result['phone']);
                        }
                      },
                    ),
                    Divider(color: Colors.grey[300]), // Divider between tiles
                    ProfileListTile(
                      icon: Icons.upload_file,
                      title: 'Export Data',
                      color: Colors.blueAccent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ExportDataScreen()),
                        );
                      },
                    ),
                    Divider(color: Colors.grey[300]),
                    ProfileListTile(
                      icon: Icons.settings,
                      title: 'Settings',
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SettingsPage()),
                        );
                      },
                    ),
                    Divider(color: Colors.grey[300]),
                    ProfileListTile(
                      icon: Icons.logout,
                      title: 'Logout',
                      color: Colors.red,
                      onTap: _logout, // Call the logout function
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color color;

  const ProfileListTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}