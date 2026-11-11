
import 'dart:convert';
import 'dart:typed_data';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/app_theme.dart';
import '../utils/image_paste_stub.dart'
    if (dart.library.js_interop) '../utils/image_paste_web.dart'
    as image_paste;

class UserFormDialog extends StatefulWidget {
  final Map<String, String>? user;

  const UserFormDialog({
    super.key,
    this.user,
  });

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Uint8List? _imageBytes;
  String? _imageName;

  bool _dragging = false;
  bool _loadingImage = false;
  bool _showPassword = false;
  bool _removeExistingImage = false;

  static const int maxImageBytes = 700 * 1024;

  bool get isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();

    _nameController.text = widget.user?['name'] ?? '';
    _emailController.text = widget.user?['email'] ?? '';

    final savedImage = widget.user?['hinhanh'] ?? '';

    if (savedImage.isNotEmpty) {
      try {
        _imageBytes = base64Decode(savedImage);
        _imageName = 'Current profile picture';
      } catch (_) {
        _imageBytes = null;
      }
    }

    // Clipboard paste is available on Flutter Web only.
    if (kIsWeb) {
      image_paste.registerImagePaste(_handlePastedImage);
    }
  }

  @override
  void dispose() {
    if (kIsWeb) {
      image_paste.unregisterImagePaste();
    }

    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _pickImage() async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 75,
      );

      if (file != null) {
        await _loadImage(file);
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Cannot choose image: $e');
      }
    }
  }

  Future<void> _loadImage(XFile file) async {
    if (_loadingImage) return;

    setState(() => _loadingImage = true);

    try {
      final bytes = await file.readAsBytes();

      if (!mounted) return;

      _setImage(bytes, file.name);
    } catch (e) {
      if (mounted) {
        _showMessage('Cannot read image: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _loadingImage = false);
      }
    }
  }

  void _setImage(Uint8List bytes, String name) {
    if (bytes.length > maxImageBytes) {
      _showMessage('Image must be smaller than 700 KB.');
      return;
    }

    final isPng = bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A;

    final isJpeg = bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF;

    if (!isPng && !isJpeg) {
      _showMessage('Only JPG and PNG images are supported.');
      return;
    }

    setState(() {
      _imageBytes = bytes;
      _imageName = name;
      _removeExistingImage = false;
    });
  }

  void _handlePastedImage(String dataUrl) {
    if (!mounted) return;

    try {
      final commaIndex = dataUrl.indexOf(',');

      if (commaIndex < 0) return;

      final header = dataUrl.substring(0, commaIndex);

      if (!header.contains('image/png') &&
          !header.contains('image/jpeg')) {
        return;
      }

      final bytes = base64Decode(
        dataUrl.substring(commaIndex + 1),
      );

      _setImage(bytes, 'pasted-image.png');
    } catch (_) {
      if (mounted) {
        _showMessage('Cannot paste this image.');
      }
    }
  }

  void _removeImage() {
    setState(() {
      _imageBytes = null;
      _imageName = null;
      _removeExistingImage = true;
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(<String, dynamic>{
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      'imageBytes': _imageBytes,
      'removeImage': _removeExistingImage,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: Colors.transparent,
      child: Container(
        width: 520,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        decoration: BoxDecoration(
          color: AppTheme.snowWhite,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppTheme.lavender.withValues(alpha: 0.35),
              blurRadius: 35,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _header(),
                Padding(
                  padding: const EdgeInsets.all(25),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _imageUploader(),

                        const SizedBox(height: 25),

                        _label('Full name'),

                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            hintText: 'Enter full name',
                            prefixIcon:
                                Icon(Icons.person_outline_rounded),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Please enter a full name';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        _label('Email address'),

                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'example@email.com',
                            prefixIcon:
                                Icon(Icons.mail_outline_rounded),
                          ),
                          validator: (value) {
                            final email = value?.trim() ?? '';

                            if (!RegExp(
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                            ).hasMatch(email)) {
                              return 'Please enter a valid email';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        _label(
                          isEditing
                              ? 'New password (optional)'
                              : 'Password',
                        ),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_showPassword,
                          decoration: InputDecoration(
                            hintText: isEditing
                                ? 'Leave blank to keep password'
                                : 'Enter password',
                            prefixIcon: const Icon(
                              Icons.lock_outline_rounded,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _showPassword = !_showPassword;
                                });
                              },
                              icon: Icon(
                                _showPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (isEditing &&
                                (value == null || value.isEmpty)) {
                              return null;
                            }

                            if (value == null || value.length < 8) {
                              return 'At least 8 characters required';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 28),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () =>
                                    Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor:
                                      AppTheme.textPrimary,
                                  padding: const EdgeInsets.all(17),
                                  side: const BorderSide(
                                    color: AppTheme.lavender,
                                  ),
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: AppTheme.buttonGradient,
                                  borderRadius:
                                      BorderRadius.circular(14),
                                ),
                                child: ElevatedButton(
                                  onPressed: _save,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.all(17),
                                  ),
                                  child: Text(
                                    isEditing
                                        ? 'Save Changes'
                                        : 'Add User',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 20,
      ),
      decoration: const BoxDecoration(
        gradient: AppTheme.pastelGradient,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.person_add_alt_1_rounded,
            color: AppTheme.primary,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              isEditing ? 'Edit User' : 'Add New User',
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
          ),

          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }

  Widget _imageUploader() {
    return DropTarget(
      onDragEntered: (_) {
        if (mounted) {
          setState(() => _dragging = true);
        }
      },
      onDragExited: (_) {
        if (mounted) {
          setState(() => _dragging = false);
        }
      },
      onDragDone: (details) async {
        if (!mounted) return;

        setState(() => _dragging = false);

        if (details.files.isNotEmpty) {
          await _loadImage(details.files.first);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: _dragging
              ? AppTheme.softLilac
              : AppTheme.snowWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _dragging
                ? AppTheme.primary
                : AppTheme.lavender,
            width: _dragging ? 2 : 1.5,
          ),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 47,
              backgroundColor: AppTheme.softLilac,
              backgroundImage: _imageBytes == null
                  ? null
                  : MemoryImage(_imageBytes!),
              child: _imageBytes == null
                  ? const Icon(
                      Icons.add_photo_alternate_outlined,
                      color: AppTheme.primary,
                      size: 40,
                    )
                  : null,
            ),

            const SizedBox(height: 13),

            Text(
              _imageBytes == null
                  ? 'Upload profile picture'
                  : 'Image ready!',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppTheme.textPrimary,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              _imageName ??
                  (kIsWeb
                      ? 'Drag & drop or paste with Ctrl + V'
                      : 'Choose an image from your device'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),

            const SizedBox(height: 15),

            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: _loadingImage ? null : _pickImage,
                  icon: const Icon(Icons.upload_rounded),
                  label: Text(
                    _loadingImage
                        ? 'Loading...'
                        : _imageBytes == null
                            ? 'Choose Image'
                            : 'Change Image',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: const BorderSide(
                      color: AppTheme.lavender,
                    ),
                  ),
                ),

                if (_imageBytes != null)
                  OutlinedButton.icon(
                    onPressed: _removeImage,
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                    ),
                    label: const Text('Remove'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.danger,
                      side: const BorderSide(
                        color: AppTheme.lavender,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            const Text(
              'JPG or PNG · Maximum 700 KB',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }
}
