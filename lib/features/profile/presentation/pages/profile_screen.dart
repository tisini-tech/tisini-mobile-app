import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/features/profile/domain/entities/user_profile.dart';
import 'package:tisini/features/profile/presentation/controllers/profile_controller.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.softGrey,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: TColors.primary,
        foregroundColor: TColors.textWhite,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.profile.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final error = controller.errorMessage.value;
        if (error != null && controller.profile.value == null) {
          return _ProfileError(message: error, onRetry: controller.loadProfile);
        }

        final profile = controller.profile.value;
        if (profile == null) {
          return const Center(child: Text('No profile available'));
        }

        return RefreshIndicator(
          color: TColors.primary,
          onRefresh: controller.loadProfile,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              _ProfileHeader(profile: profile),
              const SizedBox(height: 20),
              _ProfileSection(
                title: 'Account',
                children: [
                  _ProfileInfoTile(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: profile.email.isEmpty ? '—' : profile.email,
                  ),
                  const SizedBox(height: 8),
                  _ProfileInfoTile(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: profile.phoneNumber.isEmpty
                        ? '—'
                        : profile.phoneNumber,
                  ),
                  const SizedBox(height: 8),
                  _ProfileInfoTile(
                    icon: Icons.badge_outlined,
                    label: 'Role',
                    value: profile.roleLabel,
                  ),
                  const SizedBox(height: 8),
                  _ProfileInfoTile(
                    icon: profile.isVerified
                        ? Icons.verified_outlined
                        : Icons.gpp_bad_outlined,
                    label: 'Verification',
                    value: profile.isVerified ? 'Verified' : 'Not verified',
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Obx(
                () => _LogoutButton(
                  isLoading: controller.isLoggingOut.value,
                  onPressed: controller.confirmLogout,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TColors.lightContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TColors.borderSecondary),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: TColors.primary.withValues(alpha: 0.12),
            child: Text(
              profile.initials,
              style: const TextStyle(
                color: TColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: TColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.roleLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    color: TColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: TColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  const _ProfileInfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: TColors.lightContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TColors.borderPrimary),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: TColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: TColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: TColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: TColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TColors.lightContainer,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: TColors.error.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: TColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: TColors.error,
                        ),
                      )
                    : const Icon(
                        Icons.logout_rounded,
                        color: TColors.error,
                        size: 26,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLoading ? 'Logging out…' : 'Log out',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: TColors.error,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Sign out of this device',
                      style: TextStyle(
                        fontSize: 13,
                        color: TColors.textSecondary,
                      ),
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

class _ProfileError extends StatelessWidget {
  const _ProfileError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: TColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
