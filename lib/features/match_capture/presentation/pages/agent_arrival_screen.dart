import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/features/match_capture/domain/entities/agent_arrival.dart';
import 'package:tisini/features/match_capture/presentation/controllers/agent_arrival_controller.dart';
import 'package:tisini/features/match_capture/presentation/controllers/sop_controller.dart';

class AgentArrivalScreen extends GetView<AgentArrivalController> {
  const AgentArrivalScreen({super.key});

  static final _stampFormat = DateFormat('dd MMM yyyy, HH:mm');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.softGrey,
      appBar: AppBar(
        title: const Text('Pitch arrival'),
        backgroundColor: TColors.primary,
        foregroundColor: TColors.textWhite,
        elevation: 0,
        actions: [
          Obx(() {
            if (controller.hasArrived) return const SizedBox.shrink();
            return IconButton(
              tooltip: 'Record arrival',
              onPressed: controller.openForm,
              icon: const Icon(Icons.add),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final arrival = controller.arrival.value;
        if (arrival == null || !arrival.hasArrived) {
          return const _EmptyArrival();
        }

        return _ArrivalReadView(arrival: arrival, stampFormat: _stampFormat);
      }),
    );
  }
}

class _EmptyArrival extends StatelessWidget {
  const _EmptyArrival();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.photo_camera_outlined,
              size: 48,
              color: TColors.textSecondary,
            ),
            SizedBox(height: 12),
            Text(
              'No arrival yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: TColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tap + to take a pitch photo. GPS is recorded automatically.',
              textAlign: TextAlign.center,
              style: TextStyle(color: TColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArrivalReadView extends StatelessWidget {
  const _ArrivalReadView({
    required this.arrival,
    required this.stampFormat,
  });

  final AgentArrival arrival;
  final DateFormat stampFormat;

  @override
  Widget build(BuildContext context) {
    final loc = arrival.location;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        if (arrival.arrivedAt != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'Arrived ${stampFormat.format(arrival.arrivedAt!.toLocal())}',
              style: const TextStyle(
                color: TColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        if (sopHasImage(arrival.arrivalImg))
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: sopImageWidget(arrival.arrivalImg),
            ),
          )
        else
          Container(
            height: 160,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: TColors.borderSecondary),
            ),
            child: const Text(
              'No pitch photo',
              style: TextStyle(color: TColors.textSecondary),
            ),
          ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: TColors.borderSecondary),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on_outlined, color: TColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'GPS location',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: TColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      loc == null
                          ? 'No location recorded'
                          : '${loc.lat.toStringAsFixed(5)}, ${loc.lon.toStringAsFixed(5)}  ·  ±${loc.accuracyM.toStringAsFixed(0)} m',
                      style: const TextStyle(
                        fontSize: 12,
                        color: TColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
