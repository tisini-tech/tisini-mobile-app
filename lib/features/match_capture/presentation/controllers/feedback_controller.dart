import 'package:get/get.dart';

class FeedbackController extends GetxController {
  static FeedbackController get instance => Get.find();

  final RxString manOfMatch = ''.obs;
  final RxString changesToApply = ''.obs;
  final RxBool confirmedCardsAndGoals = false.obs;
  final RxString comments = ''.obs;
  final RxBool isSubmitting = false.obs;
  /// Increment to force form rebuild (clears text fields after submit).
  final RxInt formKey = 0.obs;

  void setManOfMatch(String value) => manOfMatch.value = value;
  void setChangesToApply(String value) => changesToApply.value = value;
  void setConfirmedCardsAndGoals(bool value) => confirmedCardsAndGoals.value = value;
  void setComments(String value) => comments.value = value;

  void submitFeedback() {
    isSubmitting.value = true;
    // TODO: call API to save feedback
    Future.delayed(const Duration(milliseconds: 500), () {
      isSubmitting.value = false;
      manOfMatch.value = '';
      changesToApply.value = '';
      confirmedCardsAndGoals.value = false;
      comments.value = '';
      formKey.value++;
    });
  }
}
