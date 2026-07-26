import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/core/widgets/appbar/custom_appbar.dart';
import 'package:tisini/features/blog/presentation/controllers/blog_controller.dart';

class BlogScreen extends GetView<BlogController> {
  const BlogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.light,
      appBar: const CustomAppBar(),
      body: const Center(child: _UpdatingSoon()),
    );
  }
}

class _UpdatingSoon extends StatelessWidget {
  const _UpdatingSoon();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: TColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.article_outlined,
              size: 40,
              color: TColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Updating soon',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: TColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Stories and news are on the way. Check back shortly.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: TColors.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
