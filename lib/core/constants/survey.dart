/// Delegate for survey form behaviour (answers, validation).
/// Implemented by [EngagementController] so question widgets stay decoupled.
abstract class SurveyFormDelegate {
  String? getAnswerString(Object questionIdOrKey);
  List<String>? getAnswerList(Object questionId);
  void setAnswer(Object questionIdOrKey, dynamic value);
  String? validateRequired(Question q);
  /// Used by widgets for input key (e.g. reset on submit). Default 0.
  int get surveyFormVersion => 0;
}

/// Survey question model for use in SurveyConstants.
class Question {
  final int id;
  final String question;
  final String type;
  final bool isRequired;
  final String? placeholder;
  final bool? multiline;
  final List<String>? options;
  final bool? multiple;
  final String? helpText;
  final int? maxSelections;
  final String? layout;
  final bool? other;
  final Map<String, dynamic>? conditional;
  final List<Map<String, String>>? fields;

  const Question({
    required this.id,
    required this.question,
    required this.type,
    required this.isRequired,
    this.placeholder,
    this.multiline,
    this.options,
    this.multiple,
    this.helpText,
    this.maxSelections,
    this.layout,
    this.other,
    this.conditional,
    this.fields,
  });
}

class SurveyConstants {
  /// Question id for Referral Code (used for persisting last value).
  static const int referralCodeQuestionId = 1;

  static const List<Question> surveyQuestions = [
    Question(
      id: 1,
      question: "Referral Code",
      type: "text",
      isRequired: false,
      placeholder: "Leave blank if you didn't receive one",
      multiline: false,
    ),
    Question(
      id: 2,
      question: "Gender",
      type: "choice",
      isRequired: true,
      options: ["Male", "Female", "Other", "Prefer not to say"],
      multiple: false,
    ),
    Question(
      id: 3,
      question: "Age bracket",
      type: "choice",
      isRequired: true,
      options: ["Under 18", "18-24", "25-34", "35-44", "45-54", "55+"],
      multiple: false,
    ),
    Question(
      id: 4,
      question: "Employment Status",
      type: "choice",
      isRequired: true,
      options: [
        "Self-employed",
        "Employee",
        "Student",
        "Unemployed",
        "Retired",
      ],
      multiple: false,
    ),
    Question(
      id: 5,
      question: "Was ticket fairly priced?",
      type: "choice",
      isRequired: true,
      options: ["Very fair", "Fair", "Neutral", "Unfair", "Very unfair"],
      multiple: false,
    ),
    Question(
      id: 6,
      question: "How did you purchase your ticket?",
      type: "choice",
      isRequired: true,
      options: [
        "Saved up to buy",
        "Paid cash when it was announced",
        "A friend/company bought for me",
        "Complimentary ticket",
      ],
      multiple: false,
      helpText: "Please select one option",
    ),
    Question(
      id: 7,
      question: "How satisfied with entry process?",
      type: "choice",
      isRequired: true,
      options: [
        "Very satisfied",
        "Satisfied",
        "Neutral",
        "Dissatisfied",
        "Very dissatisfied",
      ],
      multiple: false,
    ),
    Question(
      id: 8,
      question: "Was it value for money?",
      type: "choice",
      isRequired: true,
      options: [
        "Excellent value",
        "Good value",
        "Fair value",
        "Poor value",
        "Very poor value",
      ],
      multiple: false,
    ),
    Question(
      id: 9,
      question:
          "Is this event part of your Valentine's treat for your better half?",
      type: "choice",
      isRequired: true,
      options: ["Yes", "No"],
      multiple: false,
    ),
    Question(
      id: 10,
      question: "How satisfied with vendors?",
      type: "choice",
      isRequired: true,
      options: [
        "Very satisfied",
        "Satisfied",
        "Neutral",
        "Dissatisfied",
        "Very dissatisfied",
      ],
      multiple: false,
    ),
    Question(
      id: 11,
      question: "How did you travel to the HSBC Event?",
      type: "choice",
      isRequired: true,
      options: [
        "Drove but had parking challenges",
        "Drove and found parking easily",
        "Came with public vehicle (matatu/bus)",
        "Hailed a cab (Uber/Bolt/Taxi)",
        "Walked",
        "Boda boda",
      ],
      multiple: false,
    ),
    Question(
      id: 12,
      question: "What are your preferred weekend engagement activities?",
      type: "choice",
      isRequired: true,
      options: [
        "Netflix and Chill",
        "Concert",
        "Sherehe (Party)",
        "Family time",
        "Rugby",
        "Local football",
        "EPL football",
        "Church/Religious activities",
        "Sports betting",
        "Gaming",
        "Shopping",
        "Eating out",
      ],
      multiple: true,
      maxSelections: 3,
      layout: "grid",
      helpText: "Please select up to 3 options",
    ),
    Question(
      id: 13,
      question: "How did you get to know about the event?",
      type: "choice",
      isRequired: true,
      options: [
        "Social media",
        "Friend/Family",
        "Email",
        "Website",
        "Radio",
        "TV",
        "Newspaper",
        "BillBoards",
        "Other",
      ],
      multiple: true,
      layout: "grid",
      other: true,
    ),
    Question(
      id: 14,
      question: "Which rugby events have you attended in the last 1 year?",
      type: "choice",
      isRequired: true,
      options: [
        "Safari 7s",
        "Kenya Cup Game",
        "Driftwood 7s",
        "Prinsloo 7s",
        "Embu 7s",
        "Dala 7s",
        "Christie 7s",
        "Kabeberi 7s",
        "International Test Match",
        "School/University",
        "Other",
        "None",
      ],
      multiple: true,
      other: true,
      layout: "grid",
    ),
    Question(
      id: 15,
      question:
          "If you haven't attended any event, did HSBC meet your expectations?",
      type: "choice",
      isRequired: false,
      options: [
        "Exceeded expectations",
        "Met expectations",
        "Below expectations",
        "N/A - I attended",
      ],
      multiple: false,
      conditional: const {"dependsOn": 14, "value": "None"},
    ),
    Question(
      id: 16,
      question: "Which KRU channels do you follow?",
      type: "choice",
      isRequired: false,
      options: [
        "None",
        "Instagram",
        "WhatsApp",
        "Facebook",
        "TikTok",
        "X (Twitter)",
      ],
      multiple: true,
      layout: "grid",
    ),
    Question(
      id: 17,
      question: "What can be done better?",
      type: "text",
      isRequired: false,
      placeholder: "Please share your suggestions...",
      multiline: true,
    ),
    Question(
      id: 18,
      question: "Do you want to be informed about future events?",
      type: "contact",
      isRequired: false,
      fields: const [
        {
          "name": "phone",
          "label": "Phone Number",
          "type": "tel",
          "placeholder": "+254 XXX XXX XXX",
        },
        {
          "name": "email",
          "label": "Email Address",
          "type": "email",
          "placeholder": "your@email.com",
        },
      ],
    ),
  ];
}
