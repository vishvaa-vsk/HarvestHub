import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:harvesthub/l10n/app_localizations.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../../../core/services/auth_service.dart';
import 'language_selection_page.dart';
import 'dart:async';

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

class _PhoneAuthPageState extends State<PhoneAuthPage> with CodeAutoFill {
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
  bool _autoFillEnabled = false;
  Timer? _otpTimer;
  int _otpTimeLeft = 60;
  bool _canResend = false;
  bool _hasRequestedSmsPermission = false;

  @override
  void codeUpdated() {
    // Handle auto-filled OTP code
    if (code != null && code!.length == 6) {
      _otpController.text = code!;
      _autoFillEnabled = true;
      setState(() {});

      // Show a brief success indicator for autofill
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('OTP auto-filled successfully'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Auto-verify if OTP is complete
      Future.delayed(const Duration(milliseconds: 800), () {
        if (_otpController.text.length == 6) {
          _verifyOTP();
        }
      });
    }
  }

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
      // Start listening for SMS autofill
      await SmsAutoFill().listenForCode();

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
              _canResend = false;
              _otpTimeLeft = 60;
            });

            // Start countdown timer for resend
            _startResendTimer();

            // Request focus on OTP field when it becomes visible
            Future.delayed(const Duration(milliseconds: 300), () {
              _otpFocusNode.requestFocus();
            });

            // Request SMS autofill permission when OTP field is shown
            if (!_hasRequestedSmsPermission) {
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  _showSmsAutofillInfo();
                  _hasRequestedSmsPermission = true;
                }
              });
            }

            // Show helpful message about autofill
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('OTP will be auto-filled when received'),
                    ),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
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

  void _startResendTimer() {
    _otpTimer?.cancel();
    _otpTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_otpTimeLeft > 0) {
        setState(() {
          _otpTimeLeft--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  Future<void> _resendOTP() async {
    if (!_canResend) return;

    final loc = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String phoneNumber = '+91${_phoneController.text}';

    try {
      // Re-initialize autofill for new OTP
      await SmsAutoFill().listenForCode();

      await _authService.sendOTP(
        phoneNumber,
        (verificationId) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _canResend = false;
              _otpTimeLeft = 60;
            });
            _startResendTimer();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('OTP resent successfully'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
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
        if (mounted) {
          await _onOtpVerified(
            context,
          ); // Call the function to set preferred language
        }
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
    _initializeAutoFill();
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
  void dispose() {
    _otpTimer?.cancel();
    _nameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _phoneFocusNode.dispose();
    _otpFocusNode.dispose();
    cancel(); // Cancel SMS autofill listening
    super.dispose();
  }

  Future<void> _initializeAutoFill() async {
    try {
      // Initialize SMS autofill - modern Android versions don't require explicit SMS permission
      await SmsAutoFill().getAppSignature;

      // Listen for auto fill state changes
      listenForCode();

      // Request SMS autofill info if not already shown
      if (!_hasRequestedSmsPermission) {
        _hasRequestedSmsPermission = true;
        // Show informational message about SMS autofill
        Future.delayed(Duration(seconds: 1), () {
          if (mounted) {
            _showSmsAutofillInfo();
          }
        });
      }

      // SMS AutoFill initialized
    } catch (e) {
      // Error initializing SMS AutoFill: $e
      // Handle error silently but log for debugging
    }
  }

  void _showSmsAutofillInfo() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'SMS autofill is enabled. OTP will be filled automatically when received.',
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue.shade600,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
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
                          const SizedBox(height: 12),
                          // Autofill hint
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _autoFillEnabled
                                      ? Icons.check_circle
                                      : Icons.auto_awesome,
                                  size: 16,
                                  color:
                                      _autoFillEnabled
                                          ? Colors.green.shade600
                                          : Colors.blue.shade600,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _autoFillEnabled
                                        ? 'OTP auto-filled successfully!'
                                        : 'OTP will be filled automatically when SMS is received',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          _autoFillEnabled
                                              ? Colors.green.shade700
                                              : Colors.blue.shade700,
                                      fontWeight:
                                          _autoFillEnabled
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: List.generate(6, (index) {
                                    final isActive =
                                        _otpController.text.length == index &&
                                        _otpFocusNode.hasFocus;
                                    final isFilled =
                                        index < _otpController.text.length;
                                    return Flexible(
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 150,
                                        ),
                                        width: 48,
                                        height: 56,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
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
                                                          .withValues(
                                                            alpha: 0.15,
                                                          ),
                                                      blurRadius: 6,
                                                      offset: const Offset(
                                                        0,
                                                        2,
                                                      ),
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
                                    child: PinFieldAutoFill(
                                      focusNode: _otpFocusNode,
                                      controller: _otpController,
                                      codeLength: 6,
                                      autoFocus: true,
                                      decoration: BoxLooseDecoration(
                                        strokeColorBuilder: FixedColorBuilder(
                                          Colors.transparent,
                                        ),
                                        bgColorBuilder: FixedColorBuilder(
                                          Colors.transparent,
                                        ),
                                      ),
                                      currentCode: _otpController.text,
                                      onCodeSubmitted: (code) {
                                        _otpController.text = code;
                                        setState(() {});
                                        if (code.length == 6) {
                                          _verifyOTP();
                                        }
                                      },
                                      onCodeChanged: (code) {
                                        if (code != null) {
                                          _otpController.text = code;
                                          setState(() {});
                                        }
                                      },
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

                          // Resend OTP section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Didn't receive OTP? ",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                              if (_canResend)
                                GestureDetector(
                                  onTap: _resendOTP,
                                  child: Text(
                                    'Resend',
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                )
                              else
                                Text(
                                  'Resend in ${_otpTimeLeft}s',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 14,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
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
}
