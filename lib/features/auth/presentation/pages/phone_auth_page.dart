import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import '../../../../core/services/auth_service.dart';
import '../../../home/presentation/pages/home_page.dart';

class PhoneAuthPage extends StatefulWidget {
  const PhoneAuthPage({super.key});

  @override
  State<PhoneAuthPage> createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _showOtpField = false;
  String? _errorMessage;
  String _selectedCountryCode = '+91'; // Default country code

  // Removed the invalid import for `countries` and fixed the logic to use `IsoCode` directly
  Future<void> _onPhoneNumberChanged(String value) async {
    try {
      final isoCode = IsoCode.values.firstWhere(
        (code) =>
            code.name.toUpperCase() == _selectedCountryCode.replaceAll('+', ''),
        orElse: () => IsoCode.IN, // Default to India if not found
      );
      final phoneNumber = PhoneNumber.parse(value, destinationCountry: isoCode);
      if (phoneNumber.isValid()) {
        setState(() {
          // Phone number is valid, no additional action needed
        });
      } else {
        setState(() {
          _selectedCountryCode = '+91'; // Reset to default if invalid
        });
      }
    } catch (e) {
      // Handle parsing or validation errors silently
    }
  }

  Future<void> _sendOTP() async {
    if (_phoneController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter a phone number');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String phoneNumber = '+91${_phoneController.text}'; // Add your country code
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
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter the OTP');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    bool verified = await _authService.verifyOTP(_otpController.text);
    if (mounted) {
      if (verified) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        setState(() {
          _errorMessage = 'Invalid OTP';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 8.0), // Added padding to the left
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
                    height: 250, // Increased animation size
                  ),
                ] else ...[
                  TextFormField(
                    controller: _otpController,
                    decoration: InputDecoration(
                      labelText: 'Enter OTP',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
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
                                style: TextStyle(color: Colors.white), // Updated text color to white
                              ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Lottie.asset(
                    'assets/lottie/farming_animation.json',
                    height: 250,
                  ),
                ],
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
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
    super.dispose();
  }
}
