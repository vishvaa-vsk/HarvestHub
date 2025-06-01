import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:harvesthub/core/services/auth_service.dart';
import 'package:harvesthub/l10n/app_localizations.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Updated _loadUserData to dynamically fetch user data based on the logged-in user's phone number
  Future<void> _loadUserData() async {
    const maxRetries = 5;
    int retryCount = 0;
    final user = FirebaseAuth.instance.currentUser; // Get the current user

    if (user == null) {
      return;
    }

    while (retryCount < maxRetries) {
      try {
        final userDoc =
            await _firestore.collection('users').doc(user.phoneNumber).get();
        if (userDoc.exists) {
          final data = userDoc.data();
          setState(() {
            _nameController.text = data?['name'] ?? '';
            _emailController.text = data?['email'] ?? '';
            _phoneController.text = data?['phoneNumber'] ?? '';
          });
        }
        return; // Exit the loop if successful
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          return;
        }
        await Future.delayed(
          Duration(seconds: 2 * retryCount),
        ); // Exponential backoff
      }
    }
  }

  // Updated EditProfilePage to allow editing the phone number with OTP verification
  Future<void> _saveUserData() async {
    const maxRetries = 5;
    int retryCount = 0;
    final user = FirebaseAuth.instance.currentUser; // Get the current user

    if (user == null) {
      return;
    }

    // Check if the phone number has been changed
    if (_phoneController.text != user.phoneNumber) {
      // Send OTP to the new phone number
      await _authService.sendOTP(_phoneController.text, (verificationId) async {
        // Show a dialog to enter the OTP
        final otp = await _showOtpDialog();
        if (otp == null || otp.isEmpty) {
          return;
        }

        // Verify the OTP
        final isVerified = await _authService.verifyOTP(otp);
        if (!isVerified) {
          return;
        }

        // Replace old phone number data with new phone number data
        while (retryCount < maxRetries) {
          try {
            final oldPhoneNumber = user.phoneNumber;
            await _firestore.collection('users').doc(oldPhoneNumber).delete();
            await _firestore
                .collection('users')
                .doc(_phoneController.text)
                .set({
                  'name': _nameController.text,
                  'email': _emailController.text,
                  'phoneNumber': _phoneController.text,
                });

            // Show a confirmation message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Your mobile number has been updated successfully.',
                ),
              ),
            );

            Navigator.pop(context);
            return; // Exit the loop if successful
          } catch (e) {
            retryCount++;
            if (retryCount >= maxRetries) {
              return;
            }
            await Future.delayed(
              Duration(seconds: 2 * retryCount),
            ); // Exponential backoff
          }
        }
      }, (error) {});
    } else {
      // Save data without phone number change
      while (retryCount < maxRetries) {
        try {
          await _firestore.collection('users').doc(user.phoneNumber).set({
            'name': _nameController.text,
            'email': _emailController.text,
            'phoneNumber': _phoneController.text,
          });

          // Show a confirmation message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Your profile has been updated successfully.'),
            ),
          );

          Navigator.pop(context);
          return; // Exit the loop if successful
        } catch (e) {
          retryCount++;
          if (retryCount >= maxRetries) {
            return;
          }
          await Future.delayed(
            Duration(seconds: 2 * retryCount),
          ); // Exponential backoff
        }
      }
    }
  }

  Future<String?> _showOtpDialog() async {
    final loc = AppLocalizations.of(context)!;
    String? otp;
    await showDialog(
      context: context,
      builder: (context) {
        final otpController = TextEditingController();
        return AlertDialog(
          title: Text(loc.enterOTP),
          content: TextField(
            controller: otpController,
            decoration: InputDecoration(labelText: loc.enterOTP),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(loc.cancel),
            ),
            TextButton(
              onPressed: () {
                otp = otpController.text;
                Navigator.of(context).pop();
              },
              child: Text(loc.verifyOTP),
            ),
          ],
        );
      },
    );
    return otp;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          title: Text(loc.editProfileSettings),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green, Colors.lightGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
          ),
          elevation: 0,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture Section
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade200,
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.green,
                      child: IconButton(
                        icon: const Icon(
                          Icons.edit,
                          size: 16,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          // Add logic to edit profile picture
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Name Input Field
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
            const SizedBox(height: 16),
            // Email Input Field
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            // Made the phone number input field editable
            TextField(
              controller: _phoneController,
              readOnly: false, // Changed from true to false to make it editable
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            // Save Changes Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                onPressed: _saveUserData,
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
