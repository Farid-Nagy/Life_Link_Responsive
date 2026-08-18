import 'package:flutter/material.dart';
import 'package:lifelink/core/services/profile_image_service.dart';
import 'package:lifelink/core/theme/app_colors.dart';

class ProfileAvatar extends StatefulWidget {
  final String? imageUrl;
  final double size;
  final ValueChanged<String>? onUploaded;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.size = 84,
    this.onUploaded,
  });

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  bool uploading = false;

  Future<void> _pickImage() async {
    setState(() => uploading = true);
    try {
      final url = await ProfileImageService.pickAndUpload();
      if (!mounted) return;
      if (url != null) {
        widget.onUploaded?.call(url);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile image updated successfully.')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update the profile image.')),
      );
    } finally {
      if (mounted) setState(() => uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.imageUrl?.trim();
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.surface, width: 3),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowSoft,
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: ClipOval(
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.person_rounded,
                      size: 42,
                      color: AppColors.primary,
                    ),
                  )
                : const Icon(
                    Icons.person_rounded,
                    size: 42,
                    color: AppColors.primary,
                  ),
          ),
        ),
        Positioned(
          right: -2,
          bottom: -2,
          child: Material(
            color: AppColors.primary,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: uploading ? null : _pickImage,
              customBorder: const CircleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: uploading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Icon(
                        Icons.camera_alt_rounded,
                        size: 16,
                        color: AppColors.white,
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
