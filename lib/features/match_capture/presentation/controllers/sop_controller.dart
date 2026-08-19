import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tisini/core/constants/colors.dart';
import 'package:tisini/core/widgets/snackbar/snackbar.dart';
import 'package:tisini/features/fixtures/domain/entities/agent_fixture.dart';
import 'package:tisini/features/match_capture/data/models/sop_model.dart';
import 'package:tisini/features/match_capture/domain/entities/sop.dart';
import 'package:tisini/features/match_capture/domain/usecases/match_sop.dart';
import 'package:tisini/features/match_capture/presentation/pages/sop_form_screen.dart';
import 'package:tisini/features/match_capture/presentation/widgets/sop_image_source_sheet.dart';

enum SopImageTarget { homeLineup, awayLineup, refData }

class SopController extends GetxController {
  static SopController get instance => Get.find();

  final MatchSopUsecase getSopUsecase;
  final UploadImageUsecase uploadImageUsecase;
  final CreateSopUsecase createSopUsecase;
  final UpdateSopUsecase updateSopUsecase;

  SopController({
    required this.getSopUsecase,
    required this.uploadImageUsecase,
    required this.createSopUsecase,
    required this.updateSopUsecase,
  });

  final ImagePicker _imagePicker = ImagePicker();

  final Rx<AgentFixture?> fixture = Rx<AgentFixture?>(null);
  final Rxn<Sop> currentSop = Rxn<Sop>();
  final RxList<String> sopItems = <String>[].obs;
  final RxList<String> corrections = <String>[].obs;
  final RxString homeLineupImg = ''.obs;
  final RxString awayLineupImg = ''.obs;
  final RxString refDataImg = ''.obs;
  final Rxn<DateTime> homeLineupAt = Rxn<DateTime>();
  final Rxn<DateTime> awayLineupAt = Rxn<DateTime>();
  final Rxn<DateTime> refDataAt = Rxn<DateTime>();
  final RxMap<String, dynamic> refDataJson = <String, dynamic>{}.obs;
  final RxnString weather = RxnString();
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isPickingImage = false.obs;

  final sopInput = TextEditingController();
  final correctionInput = TextEditingController();
  final refDataInput = TextEditingController();

  String get homeTeamName => fixture.value?.team1Name ?? 'Home';
  String get awayTeamName => fixture.value?.team2Name ?? 'Away';

  bool get isEditing => (currentSop.value?.id ?? 0) > 0;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is AgentFixture) {
      fixture.value = args;
    } else if (args is Map && args['fixture'] is AgentFixture) {
      fixture.value = args['fixture'] as AgentFixture;
    }
    getSop();
  }

  @override
  void onClose() {
    sopInput.dispose();
    correctionInput.dispose();
    refDataInput.dispose();
    super.onClose();
  }

  void applySop(Sop sop) {
    currentSop.value = sop;
    sopItems.assignAll(sop.sop);
    corrections.assignAll(sop.corrections);
    homeLineupImg.value = sop.homeLineupImg;
    awayLineupImg.value = sop.awayLineupImg;
    refDataImg.value = sop.refDataImg;
    homeLineupAt.value = sop.homeLineupAt;
    awayLineupAt.value = sop.awayLineupAt;
    refDataAt.value = sop.refDataAt;
    refDataJson.assignAll(Map<String, dynamic>.from(sop.refDataJson));
    refDataInput.text = _refDataText(sop.refDataJson);
    weather.value = SopWeather.values.contains(sop.weather) ? sop.weather : null;
  }

  void prepareForm() {
    final sop = currentSop.value;
    if (sop != null && sop.hasContent) {
      applySop(sop);
    } else {
      resetForm();
    }
  }

  void resetForm() {
    sopItems.clear();
    corrections.clear();
    homeLineupImg.value = '';
    awayLineupImg.value = '';
    refDataImg.value = '';
    homeLineupAt.value = null;
    awayLineupAt.value = null;
    refDataAt.value = null;
    refDataJson.clear();
    weather.value = null;
    sopInput.clear();
    correctionInput.clear();
    refDataInput.clear();
  }

  Future<void> openForm() async {
    prepareForm();
    await Get.to(() => const SopFormScreen(), fullscreenDialog: true);
    await getSop();
  }

  void addSopItem() {
    final value = sopInput.text.trim();
    if (value.isEmpty) return;
    sopItems.add(value);
    sopInput.clear();
  }

  void removeSopItem(int index) {
    if (index < 0 || index >= sopItems.length) return;
    sopItems.removeAt(index);
  }

  void addCorrection() {
    final value = correctionInput.text.trim();
    if (value.isEmpty) return;
    corrections.add(value);
    correctionInput.clear();
  }

  void removeCorrection(int index) {
    if (index < 0 || index >= corrections.length) return;
    corrections.removeAt(index);
  }

  Future<void> pickImage(BuildContext context, SopImageTarget target) async {
    if (isPickingImage.value) return;

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

      final path = picked.path;
      final now = DateTime.now();
      _setImage(target, path, now);

      final uploaded = await _uploadLocalImage(path);
      if (uploaded == null) return;
      _setImage(target, uploaded, now);
    } catch (e) {
      showSnackbar('Photo', 'Could not pick image. Try again.', TColors.error);
    } finally {
      isPickingImage.value = false;
    }
  }

  void clearHomeLineup() {
    homeLineupImg.value = '';
    homeLineupAt.value = null;
  }

  void clearAwayLineup() {
    awayLineupImg.value = '';
    awayLineupAt.value = null;
  }

  void clearRefData() {
    refDataImg.value = '';
    refDataAt.value = null;
  }

  void setRefDataJson(String raw) {
    try {
      refDataJson.assignAll(raw.trim().isEmpty ? {} : {'notes': raw.trim()});
    } catch (_) {
      refDataJson.assignAll({});
    }
  }

  Sop buildSop() {
    final existing = currentSop.value;
    return Sop(
      id: existing?.id ?? 0,
      match: existing?.match ?? fixture.value?.id ?? 0,
      sop: List<String>.from(sopItems),
      homeLineupImg: homeLineupImg.value,
      awayLineupImg: awayLineupImg.value,
      refDataImg: refDataImg.value,
      refDataJson: Map<String, dynamic>.from(refDataJson),
      homeLineupAt: homeLineupAt.value,
      awayLineupAt: awayLineupAt.value,
      refDataAt: refDataAt.value,
      corrections: List<String>.from(corrections),
      weather: weather.value ?? '',
      createdBy: existing?.createdBy ?? 0,
      dateCreated: existing?.dateCreated,
      dateUpdated: existing?.dateUpdated,
    );
  }

  Map<String, dynamic> buildPayload() =>
      SopModel.fromEntity(buildSop()).toCreateJson();

  Future<void> submitSop() async {
    final fixtureId = fixture.value?.id.toString() ?? '';
    if (fixtureId.isEmpty) {
      showSnackbar('Error', 'No fixture selected.', TColors.error);
      return;
    }

    isSubmitting.value = true;
    setRefDataJson(refDataInput.text);

    final ready = await _ensureImagesUploaded();
    if (!ready) {
      isSubmitting.value = false;
      return;
    }

    final editing = isEditing;
    final sop = buildSop();
    final result = editing
        ? await updateSopUsecase.call(
            UpdateSopParams(
              fixtureId: fixtureId,
              sopId: sop.id.toString(),
              sop: sop,
            ),
          )
        : await createSopUsecase.call(
            CreateSopParams(fixtureId: fixtureId, sop: sop),
          );

    isSubmitting.value = false;
    result.fold(
      (failure) => showSnackbar('Error', failure.message, TColors.error),
      (saved) {
        applySop(saved);
        Get.back();
        showSnackbar(
          'SOP',
          editing ? 'Sheet of play updated.' : 'Sheet of play saved.',
          TColors.success,
        );
      },
    );
  }

  void _setImage(SopImageTarget target, String path, DateTime at) {
    switch (target) {
      case SopImageTarget.homeLineup:
        homeLineupImg.value = path;
        homeLineupAt.value = at;
      case SopImageTarget.awayLineup:
        awayLineupImg.value = path;
        awayLineupAt.value = at;
      case SopImageTarget.refData:
        refDataImg.value = path;
        refDataAt.value = at;
    }
  }

  Future<String?> _uploadLocalImage(String path) async {
    final result = await uploadImageUsecase.call(
      UploadImageParams(path: path),
    );
    return result.fold((failure) {
      showSnackbar('Photo', failure.message, TColors.error);
      return null;
    }, (url) => url);
  }

  Future<bool> _ensureImagesUploaded() async {
    Future<bool> uploadField(RxString field) async {
      final value = field.value.trim();
      if (value.isEmpty || sopIsNetworkImage(value)) return true;

      final url = await _uploadLocalImage(value);
      if (url == null) return false;
      field.value = url;
      return true;
    }

    return await uploadField(homeLineupImg) &&
        await uploadField(awayLineupImg) &&
        await uploadField(refDataImg);
  }

  Future<void> getSop() async {
    final fixtureId = fixture.value?.id.toString() ?? '';
    if (fixtureId.isEmpty) return;

    isLoading.value = true;
    final result = await getSopUsecase.call(
      MatchSopParams(fixtureId: fixtureId),
    );
    isLoading.value = false;

    result.fold(
      (failure) => showSnackbar('Error', failure.message, TColors.error),
      applySop,
    );
  }

  String _refDataText(Map<String, dynamic> json) {
    if (json.isEmpty) return '';
    final notes = json['notes'];
    if (notes is String) return notes;
    return json.entries.map((e) => '${e.key}: ${e.value}').join('\n');
  }
}

bool sopIsNetworkImage(String path) {
  final value = path.trim().toLowerCase();
  return value.startsWith('http://') || value.startsWith('https://');
}

bool sopHasImage(String path) {
  if (path.trim().isEmpty) return false;
  if (sopIsNetworkImage(path)) return true;
  return File(path).existsSync();
}

bool sopImagePathExists(String path) => sopHasImage(path);

Widget sopImageWidget(String path, {BoxFit fit = BoxFit.cover}) {
  if (sopIsNetworkImage(path)) {
    return Image.network(
      path,
      fit: fit,
      errorBuilder: (_, _, _) => const Icon(
        Icons.broken_image_outlined,
        color: TColors.textSecondary,
      ),
    );
  }
  return Image.file(File(path), fit: fit);
}
