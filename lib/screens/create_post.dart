import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../core/constants/app_constants.dart';
import '../utils/performance_utils.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _controller = TextEditingController();
  File? _image;
  bool _loading = false;
  bool _canPost = false;

  // Performance optimization: debounce text changes
  late final Debouncer _textDebouncer;

  @override
  void initState() {
    super.initState();
    _textDebouncer = Debouncer(milliseconds: 200);
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    // Debounce text changes to prevent excessive setState calls
    _textDebouncer.run(() {
      final canPost = _controller.text.trim().isNotEmpty;
      if (canPost != _canPost && mounted) {
        setState(() {
          _canPost = canPost;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _textDebouncer.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  Future<void> _submit() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      String? imageUrl;

      if (_image != null) {
        // Validate and upload image
        if (!await _image!.exists()) {
          throw Exception('Selected image file no longer exists');
        }

        // Add file size check (optional)
        final fileSize = await _image!.length();
        if (fileSize > 10 * 1024 * 1024) {
          // 10MB limit
          throw Exception('Image file is too large (max 10MB)');
        }

        imageUrl = await FirebaseService().uploadImage(
          _image!.path,
          user.phoneNumber!,
        );
      }

      await FirebaseService().createPost(
        authorId: user.phoneNumber!,
        content: _controller.text.trim(),
        imageUrl: imageUrl,
      );

      if (mounted) {
        setState(() => _loading = false);
        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Post created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);

        // Show more specific error message
        String errorMessage = 'Failed to create post';
        if (e.toString().contains('Storage bucket not properly configured')) {
          errorMessage =
              'Storage not configured properly. Please contact support.';
        } else if (e.toString().contains('Unauthorized access')) {
          errorMessage = 'Permission denied. Please check your account.';
        } else if (e.toString().contains('too large')) {
          errorMessage = 'Image file is too large (max 10MB)';
        } else if (e.toString().contains('no longer exists')) {
          errorMessage = 'Selected image is no longer available';
        } else {
          errorMessage = 'Failed to create post: ${e.toString()}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return FutureBuilder<Map<String, dynamic>?>(
      future: FirebaseService().getUserByPhone(user!.phoneNumber!),
      builder: (context, snapshot) {
        String displayName = 'User';
        if (snapshot.hasData && snapshot.data != null) {
          displayName = snapshot.data!['name'] ?? 'User';
        }
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
            titleSpacing: 0,
            title: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage:
                      user.photoURL != null
                          ? NetworkImage(user.photoURL!)
                          : null,
                  child: user.photoURL == null ? Icon(Icons.person) : null,
                ),
                SizedBox(width: 8),
                Text(
                  displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        (!_canPost || _loading)
                            ? Colors.grey.shade300
                            : AppConstants.primaryGreen,
                    foregroundColor:
                        (!_canPost || _loading)
                            ? Colors.grey.shade600
                            : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                  ),
                  onPressed: (!_canPost || _loading) ? null : _submit,
                  child:
                      _loading
                          ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : Text('Post'),
                ),
              ),
            ],
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            elevation: 0.5,
          ),
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _controller,
                      maxLines: null,
                      minLines: 5,
                      style: TextStyle(fontSize: 18),
                      decoration: InputDecoration(
                        hintText: "Share your thoughts...",
                        border: InputBorder.none,
                      ),
                    ),
                    if (_image != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _image!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Positioned(
                bottom: 24,
                right: 24,
                child: FloatingActionButton(
                  heroTag: 'pickImage',
                  backgroundColor: Colors.grey.shade100,
                  elevation: 2,
                  onPressed: _pickImage,
                  tooltip: 'Add Image',
                  child: Icon(Icons.image, color: AppConstants.primaryGreen),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
        );
      },
    );
  }
}
