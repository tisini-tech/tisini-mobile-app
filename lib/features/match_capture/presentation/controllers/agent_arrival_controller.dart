import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/core/widgets/snackbar/snackbar.dart';
import 'package:tisini/features/fixtures/domain/entities/agent_fixture.dart';
import 'package:tisini/features/match_capture/domain/entities/agent_arrival.dart';
import 'package:tisini/features/match_capture/domain/usecases/agent_arrival.dart';
import 'package:tisini/features/match_capture/domain/usecases/match_sop.dart';
import 'package:tisini/features/match_capture/presentation/controllers/sop_controller.dart';
import 'package:tisini/features/match_capture/presentation/pages/agent_arrival_form_screen.dart';
import 'package:tisini/features/match_capture/presentation/widgets/sop_image_source_sheet.dart';

class AgentArrivalController extends GetxController {
  AgentArrivalController({
    required this.getAgentArrivalUsecase,
    required this.uploadImageUsecase,
    required this.createAgentArrivalUsecase,
  });

  final GetAgentArrivalUsecase getAgentArrivalUsecase;
  final UploadImageUsecase uploadImageUsecase;
  final CreateAgentArrivalUsecase createAgentArrivalUsecase;

  final ImagePicker _imagePicker = ImagePicker();

  final Rx<AgentFixture?> fixture = Rx<AgentFixture?>(null);
  final Rxn<AgentArrival> arrival = Rxn<AgentArrival>();
  final RxString imagePath = ''.obs;
  final Rxn<ArrivalLocation> location = Rxn<ArrivalLocation>();
  final RxBool isLoading = false.obs;
  final RxBool isPickingImage = false.obs;
  final RxBool isFetchingLocation = false.obs;
  final RxBool isSubmitting = false.obs;

  bool get hasArrived => arrival.value?.hasArrived == true;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is AgentFixture) {
      fixture.value = args;
    } else if (args is Map && args['fixture'] is AgentFixture) {
      fixture.value = args['fixture'] as AgentFixture;
    }
    getArrival();
  }

  Future<void> getArrival() async {
    final fixtureId = fixture.value?.id.toString() ?? '';
    if (fixtureId.isEmpty) return;

    isLoading.value = true;
    final result = await getAgentArrivalUsecase.call(
      GetAgentArrivalParams(fixtureId: fixtureId),
    );
    isLoading.value = false;

    result.fold(
      (failure) => showSnackbar('Error', failure.message, TColors.error),
      (saved) {
        if (saved.hasArrived) {
          applyArrival(saved);
        } else {
          arrival.value = null;
        }
      },
    );
  }

  void applyArrival(AgentArrival saved) {
    arrival.value = saved;
    imagePath.value = saved.arrivalImg;
    location.value = saved.location;
  }

  void resetForm() {
    imagePath.value = '';
    location.value = null;
  }

  Future<void> openForm() async {
    if (hasArrived) return;
    resetForm();
    unawaited(captureLocation());
    await Get.to(
      () => const AgentArrivalFormScreen(),
      fullscreenDialog: true,
    );
    await getArrival();
  }

  Future<void> pickImage(BuildContext context) async {
    if (isPickingImage.value || hasArrived) return;

    final source = await showSopImageSourceSheet(context);
    if (source == null) return;

    isPickingImage.value = true;
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );
      if (picked == null) return;

      imagePath.value = picked.path;
      final uploaded = await _uploadLocalImage(picked.path);
      if (uploaded != null) {
        imagePath.value = uploaded;
      }
      if (location.value == null) {
        await captureLocation();
      }
    } catch (_) {
      showSnackbar('Photo', 'Could not pick image. Try again.', TColors.error);
    } finally {
      isPickingImage.value = false;
    }
  }

  void clearImage() {
    if (hasArrived) return;
    imagePath.value = '';
  }

  Future<bool> captureLocation() async {
    isFetchingLocation.value = true;
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        showSnackbar(
          'Location',
          'Turn on GPS to record your pitch arrival.',
          TColors.error,
        );
        return false;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        showSnackbar(
          'Location',
          'Location permission is required to record arrival.',
          TColors.error,
        );
        return false;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      location.value = ArrivalLocation(
        lat: position.latitude,
        lon: position.longitude,
        accuracyM: position.accuracy,
      );
      return true;
    } catch (_) {
      showSnackbar(
        'Location',
        'Could not read GPS. Try again in open air.',
        TColors.error,
      );
      return false;
    } finally {
      isFetchingLocation.value = false;
    }
  }

  Future<void> submitArrival() async {
    if (hasArrived) return;

    final fixtureId = fixture.value?.id.toString() ?? '';
    if (fixtureId.isEmpty) {
      showSnackbar('Error', 'No fixture selected.', TColors.error);
      return;
    }

    var imageUrl = imagePath.value.trim();
    if (imageUrl.isEmpty) {
      showSnackbar('Arrival', 'Take a photo of the pitch first.', TColors.error);
      return;
    }

    isSubmitting.value = true;

    if (!sopIsNetworkImage(imageUrl)) {
      final uploaded = await _uploadLocalImage(imageUrl);
      if (uploaded == null) {
        isSubmitting.value = false;
        return;
      }
      imageUrl = uploaded;
      imagePath.value = uploaded;
    }

    if (location.value == null) {
      final ok = await captureLocation();
      if (!ok || location.value == null) {
        isSubmitting.value = false;
        return;
      }
    }

    final result = await createAgentArrivalUsecase.call(
      CreateAgentArrivalParams(
        fixtureId: fixtureId,
        arrival: AgentArrival(
          match: fixture.value?.id ?? 0,
          arrivalImg: imageUrl,
          location: location.value,
        ),
      ),
    );

    isSubmitting.value = false;
    result.fold(
      (failure) => showSnackbar('Error', failure.message, TColors.error),
      (saved) {
        applyArrival(saved);
        Get.back();
        showSnackbar('Arrival', 'Pitch arrival recorded.', TColors.success);
      },
    );
  }

  Future<String?> _uploadLocalImage(String path) async {
    final result = await uploadImageUsecase.call(UploadImageParams(path: path));
    return result.fold((failure) {
      showSnackbar('Photo', failure.message, TColors.error);
      return null;
    }, (url) => url);
  }
}
