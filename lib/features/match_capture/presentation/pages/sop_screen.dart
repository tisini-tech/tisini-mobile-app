import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/features/match_capture/domain/entities/sop.dart';
import 'package:tisini/features/match_capture/presentation/controllers/sop_controller.dart';

class SopScreen extends GetView<SopController> {
  const SopScreen({super.key});

  static final _stampFormat = DateFormat('dd MMM yyyy, HH:mm');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.softGrey,
      appBar: AppBar(
        title: const Text('Match SOP'),
        backgroundColor: TColors.primary,
        foregroundColor: TColors.textWhite,
        elevation: 0,
        actions: [
          Obx(() {
            final editing = controller.isEditing;
            return IconButton(
              tooltip: editing ? 'Edit SOP' : 'Add SOP',
              onPressed: controller.openForm,
              icon: Icon(editing ? Icons.edit_outlined : Icons.add),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final sop = controller.currentSop.value;
        if (sop == null || !sop.hasContent) {
          return const _EmptySop();
        }

        return _SopReadView(
          sop: sop,
          homeTeamName: controller.homeTeamName,
          awayTeamName: controller.awayTeamName,
          stampFormat: _stampFormat,
        );
      }),
    );
  }
}

class _EmptySop extends StatelessWidget {
  const _EmptySop();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.fact_check_outlined,
              size: 48,
              color: TColors.textSecondary,
            ),
            const SizedBox(height: 12),
            const Text(
              'No SOP yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: TColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap + to add lineup photos, referee data, notes, and corrections.',
              textAlign: TextAlign.center,
              style: TextStyle(color: TColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _SopReadView extends StatelessWidget {
  const _SopReadView({
    required this.sop,
    required this.homeTeamName,
    required this.awayTeamName,
    required this.stampFormat,
  });

  final Sop sop;
  final String homeTeamName;
  final String awayTeamName;
  final DateFormat stampFormat;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        if (sop.dateUpdated != null || sop.dateCreated != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'Updated ${stampFormat.format((sop.dateUpdated ?? sop.dateCreated)!.toLocal())}',
              style: const TextStyle(
                color: TColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        _SectionCard(
          title: 'SOP notes',
          child: _ReadStringList(
            items: sop.sop,
            emptyLabel: 'No SOP notes',
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Weather',
          child: Text(
            sop.weather.trim().isEmpty
                ? 'No weather recorded'
                : SopWeather.labelOf(sop.weather),
            style: TextStyle(
              color: sop.weather.trim().isEmpty
                  ? TColors.textSecondary
                  : TColors.textPrimary,
              fontStyle: sop.weather.trim().isEmpty
                  ? FontStyle.italic
                  : FontStyle.normal,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Lineup photos',
          child: Column(
            children: [
              _ReadImage(
                title: '$homeTeamName lineup',
                imagePath: sop.homeLineupImg,
                capturedAt: sop.homeLineupAt,
                stampFormat: stampFormat,
              ),
              const SizedBox(height: 10),
              _ReadImage(
                title: '$awayTeamName lineup',
                imagePath: sop.awayLineupImg,
                capturedAt: sop.awayLineupAt,
                stampFormat: stampFormat,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Referee data',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ReadImage(
                title: 'Referee data photo',
                imagePath: sop.refDataImg,
                capturedAt: sop.refDataAt,
                stampFormat: stampFormat,
              ),
              const SizedBox(height: 12),
              Text(
                _refNotes(sop.refDataJson),
                style: TextStyle(
                  color: _refNotes(sop.refDataJson) == 'No referee notes'
                      ? TColors.textSecondary
                      : TColors.textPrimary,
                  fontStyle: _refNotes(sop.refDataJson) == 'No referee notes'
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Corrections',
          child: _ReadStringList(
            items: sop.corrections,
            emptyLabel: 'No corrections',
          ),
        ),
      ],
    );
  }

  String _refNotes(Map<String, dynamic> json) {
    if (json.isEmpty) return 'No referee notes';
    final notes = json['notes'];
    if (notes is String && notes.trim().isNotEmpty) return notes;
    return json.entries.map((e) => '${e.key}: ${e.value}').join('\n');
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: TColors.lightContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TColors.borderSecondary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: TColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ReadStringList extends StatelessWidget {
  const _ReadStringList({required this.items, required this.emptyLabel});

  final List<String> items;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text(
        emptyLabel,
        style: const TextStyle(
          color: TColors.textSecondary,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Column(
      children: [
        for (final item in items)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: TColors.softGrey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              item,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: TColors.textPrimary,
              ),
            ),
          ),
      ],
    );
  }
}

class _ReadImage extends StatelessWidget {
  const _ReadImage({
    required this.title,
    required this.imagePath,
    required this.capturedAt,
    required this.stampFormat,
  });

  final String title;
  final String imagePath;
  final DateTime? capturedAt;
  final DateFormat stampFormat;

  @override
  Widget build(BuildContext context) {
    final attached = sopHasImage(imagePath);
    final stamp = capturedAt == null
        ? 'No photo'
        : stampFormat.format(capturedAt!.toLocal());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TColors.softGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: TColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            attached ? stamp : 'No photo',
            style: const TextStyle(fontSize: 12, color: TColors.textSecondary),
          ),
          if (attached) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: sopImageWidget(imagePath),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
