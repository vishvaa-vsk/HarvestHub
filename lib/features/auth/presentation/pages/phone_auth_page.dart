import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/auth_service.dart';
import '../../../home/presentation/pages/home_page.dart';

class PhoneAuthPage extends StatefulWidget {
  const PhoneAuthPage({super.key});

  @override
  State<PhoneAuthPage> createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  final _nameController = TextEditingController(); // Added name controller
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  bool _showOtpField = false;
  String? _errorMessage;
  String _selectedCountryCode = '+91'; // Default country code

  // Added debugging logs to verify the phone number and name being stored
  Future<void> _storeUserData(String phoneNumber) async {
    try {
      debugPrint('Storing user data:');
      debugPrint('Name: ${_nameController.text}');
      debugPrint('Phone Number: $phoneNumber');

      await _firestore.collection('users').doc(phoneNumber).set({
        'name': _nameController.text,
        'phoneNumber': phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('User data stored successfully');
    } catch (e) {
      debugPrint('Error storing user data: $e');
    }
  }

  Future<void> _onPhoneNumberChanged(String value) async {
    if (value.isEmpty) return;

    try {
      final isoCode = IsoCode.values.firstWhere(
        (code) =>
            code.name.toUpperCase() == _selectedCountryCode.replaceAll('+', ''),
        orElse: () => IsoCode.IN, // Default to India if not found
      );
      final phoneNumber = PhoneNumber.parse(value, destinationCountry: isoCode);
      if (phoneNumber.isValid()) {
        // Store the valid phone number in Firestore
        await _storeUserData(phoneNumber.international);
        setState(() {
          // Phone number is valid, no additional action needed
        });
      } else {
        setState(() {
          _selectedCountryCode = '+91'; // Reset to default if invalid
        });
      }
    } catch (e) {
      debugPrint('Error parsing phone number: $e');
    }
  }

  // Updated _sendOTP to check for existing user data in Firestore
  Future<void> _sendOTP() async {
    if (_phoneController.text.isEmpty || _nameController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter your name and phone number');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String phoneNumber = '+91${_phoneController.text}'; // Add your country code

    try {
      // Check if user data already exists in Firestore
      final userDoc =
          await _firestore.collection('users').doc(phoneNumber).get();
      if (userDoc.exists) {
        debugPrint('User data already exists for phone number: $phoneNumber');
      } else {
        // Create a new user entry if it doesn't exist
        await _firestore.collection('users').doc(phoneNumber).set({
          'name': _nameController.text,
          'phoneNumber': phoneNumber,
          'createdAt': FieldValue.serverTimestamp(),
        });
        debugPrint('New user data created for phone number: $phoneNumber');
      }

      await _authService.sendOTP(
        phoneNumber,
        (verificationId) {
          setState(() {
            _showOtpField = true;
            _isLoading = false;
          });
        },
        (error) {
          setState(() {
            _errorMessage = error;
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to send OTP. Please try again.';
        _isLoading = false;
      });
      debugPrint('Error during OTP sending: $e');
    }
  }

  // Ensure verificationId is non-null before using it
  Future<void> _verifyOTP() async {
    if (_otpController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter the OTP');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final verificationId = _authService.verificationId;
      if (verificationId == null) {
        setState(() {
          _errorMessage = 'Verification ID is missing. Please resend the OTP.';
          _isLoading = false;
        });
        return;
      }

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: _otpController.text,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      if (userCredential.user != null) {
        debugPrint(
          'User signed in: UID = ${userCredential.user!.uid}, Phone = ${userCredential.user!.phoneNumber}',
        );
        await _storeUserData(userCredential.user!.phoneNumber!);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        setState(() {
          _errorMessage = 'Failed to sign in';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Invalid OTP';
        _isLoading = false;
      });
      debugPrint('Error during OTP verification: $e');
    }
  }

  // Added debugging logs to verify authentication flow
  Future<void> _verifyAuthentication() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      debugPrint(
        'User is signed in: UID = ${user.uid}, Phone = ${user.phoneNumber}',
      );
    } else {
      debugPrint('No user is signed in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          // Added SingleChildScrollView to prevent overflow
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'HarvestHub',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (!_showOtpField) ...[
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      onTap: () {
                        setState(() {
                          // Change the prefix icon to the country code when the field is focused
                        });
                      },
                      onChanged:
                          (value) => _onPhoneNumberChanged(
                            value,
                          ), // Detect changes dynamically
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            color:
                                _errorMessage != null
                                    ? Theme.of(context).colorScheme.error
                                    : Colors.grey,
                          ),
                        ),
                        errorText: _errorMessage,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(
                            left: 8.0,
                          ), // Added padding to the left
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.phone), // Default icon
                              const VerticalDivider(width: 1, thickness: 1),
                            ],
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFF1B5E20,
                          ), // Dark green color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onPressed: _isLoading ? null : _sendOTP,
                        child:
                            _isLoading
                                ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                )
                                : const Text(
                                  'Send OTP',
                                  style: TextStyle(color: Colors.white),
                                ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Lottie.asset(
                      'assets/lottie/farming_animation.json',
                      height: 270, // Increased animation size
                    ),
                  ] else ...[
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    TextField(
                      controller: _otpController,
                      decoration: InputDecoration(
                        labelText: 'Enter OTP',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        errorText:
                            _errorMessage, // Correctly used errorText for validation messages
                        prefixIcon: const Icon(
                          Icons.lock,
                        ), // Moved the lock icon to prefixIcon for better alignment
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFF1B5E20,
                          ), // Dark green color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onPressed: _isLoading ? null : _verifyOTP,
                        child:
                            _isLoading
                                ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                )
                                : const Text(
                                  'Verify OTP',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ), // Updated text color to white
                                ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Lottie.asset(
                      'assets/lottie/farming_animation.json',
                      height: 270,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _nameController.dispose(); // Dispose name controller
    super.dispose();
  }
}
