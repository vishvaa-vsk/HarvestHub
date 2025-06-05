import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:harvesthub/l10n/app_localizations.dart';
import '../../../../core/services/auth_service.dart';
import 'language_selection_page.dart';

/// A widget for handling phone number authentication.
///
/// This page allows users to enter their phone number and OTP for
/// authentication. It also provides options for selecting a preferred
/// language after successful OTP verification.
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
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _otpFocusNode = FocusNode(); // Dedicated FocusNode for OTP

  Future<void> _storeUserData(String phoneNumber) async {
    try {
      await _firestore.collection('users').doc(phoneNumber).set({
        'name': _nameController.text,
        'phoneNumber': phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Handle error
    }
  }

  // Updated _sendOTP to check for existing user data in Firestore
  Future<void> _sendOTP() async {
    final loc = AppLocalizations.of(context)!;
    if (_phoneController.text.isEmpty || _nameController.text.isEmpty) {
      if (mounted) {
        setState(() => _errorMessage = loc.pleaseEnterNameAndPhone);
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    String phoneNumber = '+91${_phoneController.text}'; // Add your country code

    try {
      // Check if user data already exists in Firestore
      final userDoc =
          await _firestore.collection('users').doc(phoneNumber).get();
      if (userDoc.exists) {
        // User data already exists
      } else {
        // Create a new user entry if it doesn't exist
        await _firestore.collection('users').doc(phoneNumber).set({
          'name': _nameController.text,
          'phoneNumber': phoneNumber,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await _authService.sendOTP(
        phoneNumber,
        (verificationId) {
          if (mounted) {
            setState(() {
              _showOtpField = true;
              _isLoading = false;
            });
          }
        },
        (error) {
          if (mounted) {
            setState(() {
              _errorMessage = error;
              _isLoading = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = loc.failedToSendOTP;
          _isLoading = false;
        });
      }
      // Handle error
    }
  }

  // Ensure verificationId is non-null before using it
  Future<void> _verifyOTP() async {
    final loc = AppLocalizations.of(context)!;
    if (_otpController.text.isEmpty) {
      if (mounted) {
        setState(() => _errorMessage = loc.enterOTP);
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final verificationId = _authService.verificationId;
      if (verificationId == null) {
        if (mounted) {
          setState(() {
            _errorMessage =
                'Verification ID is missing. Please resend the OTP.';
            _isLoading = false;
          });
        }
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
        await _storeUserData(userCredential.user!.phoneNumber!);
        await _onOtpVerified(
          context,
        ); // Call the function to set preferred language
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = loc.failedToSignIn;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = loc.invalidOTP;
          _isLoading = false;
        });
      }
      // Handle error
    }
  }

  Future<void> _onOtpVerified(BuildContext context) async {
    // Navigate to the language selection screen after OTP verification
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LanguageSelectionPage()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _phoneFocusNode.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    // Set navigation bar color to match background
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: const Color(
          0xFFF6F8F7,
        ), // or Colors.white if your background is white
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
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
                        labelText: loc.name,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            color: Colors.green.shade700,
                            width: 2,
                          ),
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      focusNode: _phoneFocusNode,
                      decoration: InputDecoration(
                        labelText: loc.phoneNumber,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            color:
                                _errorMessage != null
                                    ? Theme.of(context).colorScheme.error
                                    : Colors.grey,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(
                            color: Colors.green.shade700,
                            width: 2,
                          ),
                        ),
                        errorText: _errorMessage,
                        prefixIcon:
                            _phoneFocusNode.hasFocus
                                ? Container(
                                  alignment: Alignment.center,
                                  width: 48,
                                  child: Text(
                                    '+91',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                )
                                : const Icon(Icons.phone),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 48,
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
                          backgroundColor: Colors.green.shade700,
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
                                : Text(
                                  loc.nextContinue,
                                  style: const TextStyle(color: Colors.white),
                                ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Lottie.asset(
                      'assets/lottie/farming_animation.json',
                      height: 270, // Increased animation size
                    ),
                  ] else ...[
                    // OTP Input UI
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.enterOTP, // Localized
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '+91${_phoneController.text}',
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  FocusScope.of(
                                    context,
                                  ).requestFocus(_otpFocusNode);
                                  Future.delayed(
                                    const Duration(milliseconds: 100),
                                    () {
                                      SystemChannels.textInput.invokeMethod(
                                        'TextInput.show',
                                      );
                                    },
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: List.generate(6, (index) {
                                    final isActive =
                                        _otpController.text.length == index &&
                                        _otpFocusNode.hasFocus;
                                    final isFilled =
                                        index < _otpController.text.length;
                                    return AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 150,
                                      ),
                                      width: 48,
                                      height: 56,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color:
                                              isActive
                                                  ? Colors.green.shade700
                                                  : isFilled
                                                  ? Colors.green.shade400
                                                  : Colors.grey.shade400,
                                          width: 2,
                                        ),
                                        boxShadow:
                                            isActive
                                                ? [
                                                  BoxShadow(
                                                    color: Colors.green
                                                        .withOpacity(0.15),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ]
                                                : [],
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        isFilled
                                            ? _otpController.text[index]
                                            : '',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 24,
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                              // Hidden TextField for OTP input, always focusable
                              Positioned.fill(
                                child: IgnorePointer(
                                  ignoring: false,
                                  child: Opacity(
                                    opacity: 0.0,
                                    child: TextField(
                                      focusNode: _otpFocusNode,
                                      controller: _otpController,
                                      maxLength: 6,
                                      keyboardType: TextInputType.number,
                                      autofocus: true,
                                      style: const TextStyle(
                                        color: Colors.transparent,
                                      ),
                                      cursorColor: Colors.green,
                                      decoration: const InputDecoration(
                                        counterText: '',
                                        border: InputBorder.none,
                                        fillColor: Colors.transparent,
                                        filled: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      onChanged: (value) {
                                        setState(() {});
                                      },
                                      enableInteractiveSelection: false,
                                      showCursor: false,
                                      obscureText: false,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ), // Reduced space before button
                          if (_errorMessage != null) ...[
                            Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onPressed:
                            _otpController.text.length == 6 && !_isLoading
                                ? _verifyOTP
                                : null,
                        child:
                            _isLoading
                                ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                )
                                : Text(
                                  loc.proceed,
                                  style: const TextStyle(color: Colors.white),
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
    _nameController.dispose();
    _phoneFocusNode.dispose();
    _otpFocusNode.dispose(); // Dispose the dedicated FocusNode for OTP
    super.dispose();
  }
}
