import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/features/survey/domain/entities/survey.dart';
import 'package:tisini/features/survey/presentation/controllers/engagements_controller.dart';

class EngagementsScreen extends GetView<EngagementsController> {
  const EngagementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.softGrey,
      appBar: AppBar(
        title: const Text('Surveys'),
        backgroundColor: TColors.primary,
        foregroundColor: TColors.textWhite,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.surveys.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.surveys.isEmpty) {
          return RefreshIndicator(
            color: TColors.primary,
            onRefresh: controller.fetchSurveys,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 120),
                Center(
                  child: Text(
                    'No surveys available',
                    style: TextStyle(color: TColors.textSecondary),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: TColors.primary,
          onRefresh: controller.fetchSurveys,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: controller.surveys.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final survey = controller.surveys[index];
              final status = controller.scheduleStatus(survey);
              final isEnded = status == SurveyScheduleStatus.ended;
              return _EngagementListTile(
                survey: survey,
                statusLabel: controller.scheduleStatusLabel(survey),
                status: status,
                dateRange: controller.dateRangeLabel(survey),
                onTap: isEnded ? null : () => controller.openSurvey(survey),
              );
            },
          ),
        );
      }),
    );
  }
}

class _EngagementListTile extends StatelessWidget {
  const _EngagementListTile({
    required this.survey,
    required this.statusLabel,
    required this.status,
    required this.dateRange,
    required this.onTap,
  });

  final Survey survey;
  final String statusLabel;
  final SurveyScheduleStatus status;
  final String dateRange;
  final VoidCallback? onTap;

  Color get _statusColor {
    return switch (status) {
      SurveyScheduleStatus.upcoming => TColors.warning,
      SurveyScheduleStatus.open => TColors.success,
      SurveyScheduleStatus.ended => TColors.textSecondary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isEnded = status == SurveyScheduleStatus.ended;

    return Opacity(
      opacity: isEnded ? 0.65 : 1,
      child: Material(
        color: TColors.lightContainer,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: TColors.borderPrimary),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: TColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: survey.imageUrl.trim().isNotEmpty
                      ? Image.network(
                          survey.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.poll_outlined,
                            color: TColors.primary,
                          ),
                        )
                      : const Icon(Icons.poll_outlined, color: TColors.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              survey.title.isEmpty
                                  ? 'Untitled survey'
                                  : survey.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: TColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (survey.description.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          survey.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: TColors.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.date_range_outlined,
                            size: 16,
                            color: TColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              dateRange,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: TColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
