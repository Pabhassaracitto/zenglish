// GENERATED FILE - DO NOT EDIT MANUALLY
// ZenGlish localization facade supporting 26 languages.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Extension on [BuildContext] to easily access [AppLocalizations].
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Abstract base class for ZenGlish localizations.
abstract class AppLocalizations {
  AppLocalizations(this.localeName);

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ?? lookupAppLocalizations(const Locale('vi'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('bn'),
    Locale('bo'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('km'),
    Locale('ko'),
    Locale('lo'),
    Locale('mn'),
    Locale('mr'),
    Locale('my'),
    Locale('pt'),
    Locale('ru'),
    Locale('si'),
    Locale('ta'),
    Locale('te'),
    Locale('th'),
    Locale('vi'),
    Locale('zh'),
    Locale('zh', 'TW'),
  ];

  String get accuracy;
  String get aiFeedback;
  String get aiInterview;
  String get aiInterviewDescription;
  String get appSubtitle;
  String get appTitle;
  String get back;
  String get backToHome;
  String get backToMain;
  String get cancel;
  String get cefrLevel;
  String get complete;
  String get confirm;
  String get congratulations;
  String get continueText;
  String get dharmaSegment;
  String get errorOccurred;
  String get feedback;
  String get finishLesson;
  String get fluency;
  String get grammar;
  String get guidedStageTitle;
  String get hideIpa;
  String get home;
  String get inputStageTitle;
  String get language;
  String get lessonCompleted;
  String get loading;
  String get matchWords;
  String get meditationSegment;
  String get meditationStage;
  String get meditationTestTitle;
  String get meditator;
  String get monkMode;
  String get navigationError;
  String get nextPatternPractice;
  String get noConversation;
  String get noPatterns;
  String get noPractice;
  String get outputStageTitle;
  String get pageNotFound;
  String get paliKnowledge;
  String get paliSegment;
  String get paliTestTitle;
  String get patternStageTitle;
  String get patternViewStageTitle;
  String get placementResultTitle;
  String get placementTest;
  String get placementTestSubtitle;
  String get placementTestTitle;
  String get pronunciation;
  String get quickStart;
  String get retry;
  String get selectLanguage;
  String get settings;
  String get showIpa;
  String get silentMode;
  String get silentModeDesc;
  String get silentModeOff;
  String get silentModeOn;
  String get smartSuggestion;
  String get startInterview;
  String get startLearning;
  String get suggestion;
  String get systemDefault;
  String get turnOffSilentToRecord;
  String get venerableMonk;
  String get viewDetails;
  String get vocabTestTitle;
  String get vocabulary;
  String get welcomeBack;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar', 'bn', 'bo', 'de', 'en', 'es', 'fr', 'hi', 'id', 'it', 'ja', 'km', 'ko', 'lo', 'mn', 'mr', 'my', 'pt', 'ru', 'si', 'ta', 'te', 'th', 'vi', 'zh'
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  if (locale.languageCode == 'zh') {
    if (locale.countryCode == 'TW') {
      return AppLocalizationsZhTw();
    }
    return AppLocalizationsZh();
  }
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'bn': return AppLocalizationsBn();
    case 'bo': return AppLocalizationsBo();
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
    case 'hi': return AppLocalizationsHi();
    case 'id': return AppLocalizationsId();
    case 'it': return AppLocalizationsIt();
    case 'ja': return AppLocalizationsJa();
    case 'km': return AppLocalizationsKm();
    case 'ko': return AppLocalizationsKo();
    case 'lo': return AppLocalizationsLo();
    case 'mn': return AppLocalizationsMn();
    case 'mr': return AppLocalizationsMr();
    case 'my': return AppLocalizationsMy();
    case 'pt': return AppLocalizationsPt();
    case 'ru': return AppLocalizationsRu();
    case 'si': return AppLocalizationsSi();
    case 'ta': return AppLocalizationsTa();
    case 'te': return AppLocalizationsTe();
    case 'th': return AppLocalizationsTh();
    case 'vi': return AppLocalizationsVi();
    case 'zh': return AppLocalizationsZh();
  }
  return AppLocalizationsVi();
}

/// The translations for `ar`.
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([super.localeName = 'ar']);

  @override
  String get accuracy => 'الدقة';

  @override
  String get aiFeedback => 'تقييم الذكاء الاصطناعي';

  @override
  String get aiInterview => 'مقابلة الذكاء الاصطناعي';

  @override
  String get aiInterviewDescription => 'تدرب على إنجليزية الدارما والتأمل مع الذكاء الاصطناعي';

  @override
  String get appSubtitle => 'English for Wisdom & Meditation';

  @override
  String get appTitle => 'ZENGLISH - English for Wisdom & Meditation';

  @override
  String get back => 'رجوع';

  @override
  String get backToHome => 'العودة للرئيسية';

  @override
  String get backToMain => 'العودة للصفحة الرئيسية';

  @override
  String get cancel => 'إلغاء';

  @override
  String get cefrLevel => 'مستوى CEFR';

  @override
  String get complete => 'إكمال';

  @override
  String get confirm => 'تأكيد';

  @override
  String get congratulations => 'تهانينا على إتمام هذا الدرس بنجاح!';

  @override
  String get continueText => 'متابعة';

  @override
  String get dharmaSegment => 'Dharma';

  @override
  String get errorOccurred => 'حدث خطأ';

  @override
  String get feedback => 'التقييم';

  @override
  String get finishLesson => 'إنهاء الدرس';

  @override
  String get fluency => 'الطلاقة';

  @override
  String get grammar => 'القواعد';

  @override
  String get guidedStageTitle => 'المرحلة 1: الاستماع والتأمل';

  @override
  String get hideIpa => 'إخفاء رموز IPA';

  @override
  String get home => 'الرئيسية';

  @override
  String get inputStageTitle => 'المرحلة 2: المدخلات اللغوية';

  @override
  String get language => 'اللغة';

  @override
  String get lessonCompleted => 'اكتمل الدرس!';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get matchWords => 'مطابقة الكلمات ثلاثية اللغات';

  @override
  String get meditationSegment => 'Meditation';

  @override
  String get meditationStage => 'مرحلة التأمل';

  @override
  String get meditationTestTitle => '2. خبرة التأمل';

  @override
  String get meditator => 'ممارس التأمل';

  @override
  String get monkMode => 'وضع الراهب';

  @override
  String get navigationError => 'خطأ في التنقل';

  @override
  String get nextPatternPractice => 'التالي: مطابقة الكلمات ←';

  @override
  String get noConversation => 'لا توجد محادثة متاحة لهذا الدرس.';

  @override
  String get noPatterns => 'لا توجد تمارين أنماط.';

  @override
  String get noPractice => 'لا توجد خطوات ممارسة.';

  @override
  String get outputStageTitle => 'المرحلة 4: ممارسة النطق';

  @override
  String get pageNotFound => 'الصفحة غير موجودة';

  @override
  String get paliKnowledge => 'معرفة البالي';

  @override
  String get paliSegment => 'Pāli';

  @override
  String get paliTestTitle => '3. معرفة لغة البالي';

  @override
  String get patternStageTitle => 'المرحلة 3: الهيكل ومطابقة الكلمات';

  @override
  String get patternViewStageTitle => 'المرحلة 3أ: ملاحظة الهيكل';

  @override
  String get placementResultTitle => 'مسار التعلم المخصص لك';

  @override
  String get placementTest => 'اختبار تحديد المستوى';

  @override
  String get placementTestSubtitle => 'تحديد مستوى الإنجليزية ومرحلة التأمل ومعرفة البالي';

  @override
  String get placementTestTitle => 'تقييم الكفاءة الأولي';

  @override
  String get pronunciation => 'النطق';

  @override
  String get quickStart => 'بدء سريع';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get settings => 'الإعدادات';

  @override
  String get showIpa => 'إظهار رموز IPA';

  @override
  String get silentMode => 'الوضع الصامت';

  @override
  String get silentModeDesc => 'بدون تشغيل صوتي تلقائي. مناسب لبيئة الأديرة.';

  @override
  String get silentModeOff => 'الوضع الصامت معطل';

  @override
  String get silentModeOn => 'الوضع الصامت مفعل';

  @override
  String get smartSuggestion => 'اقتراحات ذكية';

  @override
  String get startInterview => 'بدء المقابلة';

  @override
  String get startLearning => 'بدء التعلم';

  @override
  String get suggestion => 'اقتراح للتحسين';

  @override
  String get systemDefault => 'حسب النظام';

  @override
  String get turnOffSilentToRecord => 'أوقف الوضع الصامت للتسجيل';

  @override
  String get venerableMonk => 'الراهب الجليل / السانغا';

  @override
  String get viewDetails => 'عرض التفاصيل';

  @override
  String get vocabTestTitle => '1. المفردات والقواعد';

  @override
  String get vocabulary => 'المفردات';

  @override
  String get welcomeBack => 'مرحباً بك';

}

/// The translations for `bn`.
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([super.localeName = 'bn']);

  @override
  String get accuracy => 'সঠিকতা';

  @override
  String get aiFeedback => 'AI মতামত';

  @override
  String get aiInterview => 'AI ইন্টারভিউ';

  @override
  String get aiInterviewDescription => 'AI এর সাথে ধর্ম এবং ধ্যান ইংরেজি অনুশীলন করুন';

  @override
  String get appSubtitle => 'English for Wisdom & Meditation';

  @override
  String get appTitle => 'ZENGLISH - English for Wisdom & Meditation';

  @override
  String get back => 'ফিরে যান';

  @override
  String get backToHome => 'হোমে ফিরে যান';

  @override
  String get backToMain => 'মূল পৃষ্ঠায় ফিরে যান';

  @override
  String get cancel => 'বাতিল';

  @override
  String get cefrLevel => 'CEFR স্তর';

  @override
  String get complete => 'সম্পূর্ণ';

  @override
  String get confirm => 'নিশ্চিত করুন';

  @override
  String get congratulations => 'এই পাঠটি সফলভাবে সম্পন্ন করার জন্য অভিনন্দন!';

  @override
  String get continueText => 'এগিয়ে যান';

  @override
  String get dharmaSegment => 'Dharma';

  @override
  String get errorOccurred => 'একটি ত্রুটি ঘটেছে';

  @override
  String get feedback => 'মতামত';

  @override
  String get finishLesson => 'পাঠ শেষ করুন';

  @override
  String get fluency => 'সাবলীলতা';

  @override
  String get grammar => 'ব্যাকরণ';

  @override
  String get guidedStageTitle => 'ধাপ ১: শুনুন এবং চিন্তা করুন';

  @override
  String get hideIpa => 'IPA লুকান';

  @override
  String get home => 'হোম';

  @override
  String get inputStageTitle => 'ধাপ ২: ভাষা ইনপুট';

  @override
  String get language => 'ভাষা';

  @override
  String get lessonCompleted => 'পাঠ সম্পন্ন হয়েছে!';

  @override
  String get loading => 'লোড হচ্ছে...';

  @override
  String get matchWords => 'ত্রিভাষিক শব্দ মেলানো';

  @override
  String get meditationSegment => 'Meditation';

  @override
  String get meditationStage => 'ধ্যানের পর্যায়';

  @override
  String get meditationTestTitle => '২. ধ্যান অভিজ্ঞতা';

  @override
  String get meditator => 'ধ্যানী';

  @override
  String get monkMode => 'ভিক্ষু মোড';

  @override
  String get navigationError => 'নেভিগেশন ত্রুটি';

  @override
  String get nextPatternPractice => 'পরবর্তী: শব্দ মেলানো →';

  @override
  String get noConversation => 'এই পাঠের জন্য কোনো কথোপকথন পাওয়া যায়নি।';

  @override
  String get noPatterns => 'কোনো প্যাটার্ন অনুশীলন উপলব্ধ নেই।';

  @override
  String get noPractice => 'কোনো অনুশীলনের ধাপ উপলব্ধ নেই।';

  @override
  String get outputStageTitle => 'ধাপ ৪: উচ্চারণ অনুশীলন';

  @override
  String get pageNotFound => 'পৃষ্ঠা পাওয়া যায়নি';

  @override
  String get paliKnowledge => 'পালি জ্ঞান';

  @override
  String get paliSegment => 'Pāli';

  @override
  String get paliTestTitle => '৩. পালি জ্ঞান';

  @override
  String get patternStageTitle => 'ধাপ ৩: গঠন এবং শব্দ মেলাও';

  @override
  String get patternViewStageTitle => 'ধাপ ৩a: গঠন পর্যবেক্ষণ করুন';

  @override
  String get placementResultTitle => 'আপনার জন্য কাস্টমাইজড শিক্ষার পথ';

  @override
  String get placementTest => 'লেভেল টেস্ট';

  @override
  String get placementTestSubtitle => 'ইংরেজি স্তর, ধ্যান পর্যায় এবং পালি জ্ঞান নির্ধারণ করুন';

  @override
  String get placementTestTitle => 'প্রাথমিক যোগ্যতা মূল্যায়ন';

  @override
  String get pronunciation => 'উচ্চারণ';

  @override
  String get quickStart => 'দ্রুত শুরু';

  @override
  String get retry => 'আবার চেষ্টা করুন';

  @override
  String get selectLanguage => 'ভাষা নির্বাচন করুন';

  @override
  String get settings => 'সেটিংস';

  @override
  String get showIpa => 'IPA দেখান';

  @override
  String get silentMode => 'নীরব মোড';

  @override
  String get silentModeDesc => 'কোন স্বয়ংক্রিয় অডিও নেই। আশ্রম বা বিহারের পরিবেশের জন্য উপযুক্ত।';

  @override
  String get silentModeOff => 'নীরব মোড বন্ধ আছে';

  @override
  String get silentModeOn => 'নীরব মোড চালু আছে';

  @override
  String get smartSuggestion => 'স্মার্ট পরামর্শ';

  @override
  String get startInterview => 'AI ইন্টারভিউ শুরু করুন';

  @override
  String get startLearning => 'শেখা শুরু করুন';

  @override
  String get suggestion => 'উন্নতির পরামর্শ';

  @override
  String get systemDefault => 'સિસ્ટમ ડિફૉલ્ટ / সিস্টেম ডিফল্ট';

  @override
  String get turnOffSilentToRecord => 'রেকর্ড করতে নীরব মোড বন্ধ করুন';

  @override
  String get venerableMonk => 'পূজনীয় ভিক্ষু / সংঘ';

  @override
  String get viewDetails => 'বিস্তারিত দেখুন';

  @override
  String get vocabTestTitle => '১. শব্দভাণ্ডার এবং ব্যাকরণ';

  @override
  String get vocabulary => 'শব্দভাণ্ডার';

  @override
  String get welcomeBack => 'স্বাগতম';

}

/// The translations for `bo`.
class AppLocalizationsBo extends AppLocalizations {
  AppLocalizationsBo([super.localeName = 'bo']);

  @override
  String get accuracy => 'དག་པོ།';

  @override
  String get aiFeedback => 'AI བསམ་འཆར།';

  @override
  String get aiInterview => 'AI དྲིས་ལན།';

  @override
  String get aiInterviewDescription => 'AI དང་ལྷանཅིག་ཆོས་ཆོས་དང་སྒོམ་རྒྱག་དབྱིན་ཡིག་སྦྱོང་བ།';

  @override
  String get appSubtitle => 'English for Wisdom & Meditation';

  @override
  String get appTitle => 'ZENGLISH - English for Wisdom & Meditation';

  @override
  String get back => 'ཕྱིར་ལོག';

  @override
  String get backToHome => 'གཙོ་ཤོག་ལ་ལོག་པ།';

  @override
  String get backToMain => 'དཀྱིལ་ཤོག་ལ་ལོག་པ།';

  @override
  String get cancel => 'རྩིས་མེད་བྱེད་པ།';

  @override
  String get cefrLevel => 'CEFR རིམ་པ།';

  @override
  String get complete => 'ལེགས་གྲུབ།';

  @override
  String get confirm => 'གཏན་འབེབས།';

  @override
  String get congratulations => 'སློབ་ཚན་འདི་ལེགས་གྲུབ་བྱུང་བར་བཀྲ་ཤིས་བདེ་ལེགས་ཞུ།!';

  @override
  String get continueText => 'མཁས་པར་བྱེད་པ།';

  @override
  String get dharmaSegment => 'Dharma';

  @override
  String get errorOccurred => 'ནོར་འཁྲུལ་བྱུང་བ།';

  @override
  String get feedback => 'བསམ་འཆར།';

  @override
  String get finishLesson => 'སློབ་ཚན་མཇུག་སྒྲིལ་བ།';

  @override
  String get fluency => 'བྱང་པོ།';

  @override
  String get grammar => 'བརྡ་ spྲོད།';

  @override
  String get guidedStageTitle => 'རིམ་པ་ ༡: ཉན་པ་དང་བསམ་པ།';

  @override
  String get hideIpa => 'IPA ཡိབ་པ།';

  @override
  String get home => 'གཙོ་ཤོག';

  @override
  String get inputStageTitle => 'རིམ་པ་ ༢: སྐད་ཡིག་ནང་འཇུག';

  @override
  String get language => 'སྐད་ཡིག';

  @override
  String get lessonCompleted => 'སློབ་ཚན་ལེགས་གྲུབ།!';

  @override
  String get loading => 'ཕབ་ལེན་བྱེད་བཞིན་པ།...';

  @override
  String get matchWords => 'སྐད་གསུམ་མིང་ཚིག་སྦྱོར་བ།';

  @override
  String get meditationSegment => 'Meditation';

  @override
  String get meditationStage => 'སྒོམ་གྱི་རིམ་པ།';

  @override
  String get meditationTestTitle => '༢. སྒོམ་གྱི་ ཉམས་མྱོང་།';

  @override
  String get meditator => 'སྒོམ་ཆེནཔ།';

  @override
  String get monkMode => 'དགེ་འདུན་པའི་རྣམ་པ།';

  @override
  String get navigationError => 'ལམ་སྟོན་ནོར་བ།';

  @override
  String get nextPatternPractice => 'རྗེས་མ།: མིང་ཚིག་སྦྱོར་བ། →';

  @override
  String get noConversation => 'སློབ་ཚན་འདིར་སྐད་ཆ་མེད།';

  @override
  String get noPatterns => 'ཚིག་གྲུབ་སྦྱོང་བརྡར་མེད།';

  @override
  String get noPractice => 'སྦྱོང་བརྡར་རིམ་པ་མེད།';

  @override
  String get outputStageTitle => 'རིམ་པ་ ༤: སྒྲ་གདངས་སྦྱོང་བརྡར།';

  @override
  String get pageNotFound => 'ཤོག་ལྷེ་མ་རྙེད།';

  @override
  String get paliKnowledge => 'Pāli ཤེས་བྱ།';

  @override
  String get paliSegment => 'Pāli';

  @override
  String get paliTestTitle => '༣. Pāli ཤེས་བྱ།';

  @override
  String get patternStageTitle => 'རིམ་པ་ ༣: ཚིག་གྲུབ་དང་མིང་ཚིག་སྦྱོར་བ།';

  @override
  String get patternViewStageTitle => 'རིམ་པ་ ༣a: ཚིག་གྲུབ་ལ་ལྟ་བ།';

  @override
  String get placementResultTitle => 'ཁྱེད་ཀྱི་སློབ་སྦྱོང་ལམ་བུ།';

  @override
  String get placementTest => 'གནས་ཚད་ཚོད་ལྟ།';

  @override
  String get placementTestSubtitle => 'དབྱིན་ཡིག་གནས་ཚད་དང་སྒོམ་སྒྲུབ་རིམ་པ། ပါལི་ཤེས་བྱ་ངེས་တན་བཟོ་བ།';

  @override
  String get placementTestTitle => 'ཐོག་མའི་ནུས་པ་བརྟག་བཤེར།';

  @override
  String get pronunciation => 'སྒྲ་གདངས།';

  @override
  String get quickStart => 'མགྱོགས་མྱུར་འགོ་འཛུགས།';

  @override
  String get retry => 'ཡང་བསྐྱར་བྱེད་པ།';

  @override
  String get selectLanguage => 'སྐད་ཡིག་འདེམས་པ།';

  @override
  String get settings => 'སྒྲིག་བཀོད།';

  @override
  String get showIpa => 'IPA སྟོན་པ།';

  @override
  String get silentMode => 'ཁུ་སིམ་རྣམ་པ།';

  @override
  String get silentModeDesc => 'རང་འགུལ་སྒྲ་མེད། དགོན་ပའི་ Tim ལ་འཚམ་པ།';

  @override
  String get silentModeOff => 'ཁུ་སིམ་རྣམ་པ་བཀག་ཡོད།';

  @override
  String get silentModeOn => 'ཁུ་སིམ་རྣམ་པ་སྤར་ཡོད།';

  @override
  String get smartSuggestion => 'རིག་ནུས་བསམ་འཆར།';

  @override
  String get startInterview => 'AI དྲིས་ལན་འགོ་འཛུགས།';

  @override
  String get startLearning => 'སློབ་སྦྱོང་འགོ་འཛུགས།';

  @override
  String get suggestion => 'ཡར་རྒྱས་བསམ་འཆར།';

  @override
  String get systemDefault => 'རྒྱུད་ཁོངས་སྔོན་སྒྲིག';

  @override
  String get turnOffSilentToRecord => 'སྒྲ་འཇུག་བྱེད་པར་ཁུ་སིམ་རྣམ་པ་གསོད་པ།';

  @override
  String get venerableMonk => 'དགེ་འདུན་པ། / བཙུན་པ།';

  @override
  String get viewDetails => 'ཞིབ་ཕྲ་ལྟ་བ།';

  @override
  String get vocabTestTitle => '༡. ཚིག་མཛོད་དང་བརྡ་ spྲོད།';

  @override
  String get vocabulary => 'ཚིག་མཛོད།';

  @override
  String get welcomeBack => 'ཕེབས་པར་དགའ་བསུ་ཞུ།';

}

/// The translations for `de`.
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([super.localeName = 'de']);

  @override
  String get accuracy => 'Genauigkeit';

  @override
  String get aiFeedback => 'KI-Feedback';

  @override
  String get aiInterview => 'AI Interview';

  @override
  String get aiInterviewDescription => 'Üben Sie Dharma- und Meditations-Englisch mit KI';

  @override
  String get appSubtitle => 'Englisch für Weisheit & Meditation';

  @override
  String get appTitle => 'ZENGLISH - Englisch für Weisheit & Meditation';

  @override
  String get back => 'Zurück';

  @override
  String get backToHome => 'Zurück zur Startseite';

  @override
  String get backToMain => 'Zurück zur Hauptseite';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get cefrLevel => 'CEFR-Niveau';

  @override
  String get complete => 'Abschließen';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get congratulations => 'Herzlichen Glückwunsch zum erfolgreichen Abschluss dieser Lektion!';

  @override
  String get continueText => 'Weiter';

  @override
  String get dharmaSegment => 'Dharma';

  @override
  String get errorOccurred => 'Ein Fehler ist aufgetreten';

  @override
  String get feedback => 'Feedback';

  @override
  String get finishLesson => 'Lektion beenden';

  @override
  String get fluency => 'Flüssigkeit';

  @override
  String get grammar => 'Grammatik';

  @override
  String get guidedStageTitle => 'Stufe 1: Zuhören & Reflektieren';

  @override
  String get hideIpa => 'IPA-Lautschrift ausblenden';

  @override
  String get home => 'Startseite';

  @override
  String get inputStageTitle => 'Stufe 2: Spracheingabe';

  @override
  String get language => 'Sprache';

  @override
  String get lessonCompleted => 'Lektion abgeschlossen!';

  @override
  String get loading => 'Laden...';

  @override
  String get matchWords => 'Dreisprachige Wortzuordnung';

  @override
  String get meditationSegment => 'Meditation';

  @override
  String get meditationStage => 'Meditationsstufe';

  @override
  String get meditationTestTitle => '2. Meditationserfahrung';

  @override
  String get meditator => 'Meditierender';

  @override
  String get monkMode => 'Mönch-Modus';

  @override
  String get navigationError => 'Navigationsfehler';

  @override
  String get nextPatternPractice => 'Weiter: Wortzuordnung →';

  @override
  String get noConversation => 'Keine Konversation für diese Lektion verfügbar.';

  @override
  String get noPatterns => 'Keine Musterübungen verfügbar.';

  @override
  String get noPractice => 'Keine Übungsschritte verfügbar.';

  @override
  String get outputStageTitle => 'Stufe 4: Aussprachepraxis';

  @override
  String get pageNotFound => 'Seite nicht gefunden';

  @override
  String get paliKnowledge => 'Pāli-Kenntnisse';

  @override
  String get paliSegment => 'Pāli';

  @override
  String get paliTestTitle => '3. Pāli-Kenntnisse';

  @override
  String get patternStageTitle => 'Stufe 3: Struktur & Wortzuordnung';

  @override
  String get patternViewStageTitle => 'Stufe 3a: Struktur beobachten';

  @override
  String get placementResultTitle => 'Ihr individueller Lernpfad';

  @override
  String get placementTest => 'Einstufungstest';

  @override
  String get placementTestSubtitle => 'Bestimmen Sie Englischstufe, Meditationsphase & Pāli-Kenntnisse';

  @override
  String get placementTestTitle => 'Erstbewertung der Fähigkeiten';

  @override
  String get pronunciation => 'Aussprache';

  @override
  String get quickStart => 'Schnellstart';

  @override
  String get retry => 'Wiederholen';

  @override
  String get selectLanguage => 'Sprache auswählen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get showIpa => 'IPA-Lautschrift anzeigen';

  @override
  String get silentMode => 'Lautlos-Modus';

  @override
  String get silentModeDesc => 'Keine automatische Audio-Wiedergabe. Geeignet für Klosterumgebungen.';

  @override
  String get silentModeOff => 'Lautlos-Modus ist AUS';

  @override
  String get silentModeOn => 'Lautlos-Modus ist AN';

  @override
  String get smartSuggestion => 'Intelligente Empfehlung';

  @override
  String get startInterview => 'AI Interview starten';

  @override
  String get startLearning => 'Lernen starten';

  @override
  String get suggestion => 'Verbesserungsvorschlag';

  @override
  String get systemDefault => 'Systemstandard';

  @override
  String get turnOffSilentToRecord => 'Lautlos-Modus ausschalten, um aufzunehmen';

  @override
  String get venerableMonk => 'Ehrwürdiger Mönch / Sangha';

  @override
  String get viewDetails => 'Details anzeigen';

  @override
  String get vocabTestTitle => '1. Wortschatz & Grammatik';

  @override
  String get vocabulary => 'Wortschatz';

  @override
  String get welcomeBack => 'Willkommen';

}

/// The translations for `en`.
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([super.localeName = 'en']);

  @override
  String get accuracy => 'Accuracy';

  @override
  String get aiFeedback => 'AI Feedback';

  @override
  String get aiInterview => 'AI Interview';

  @override
  String get aiInterviewDescription => 'Practice Dharma & Meditation English with AI';

  @override
  String get appSubtitle => 'English for Wisdom & Meditation';

  @override
  String get appTitle => 'ZENGLISH - English for Wisdom & Meditation';

  @override
  String get back => 'Back';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get backToMain => 'Back to Main';

  @override
  String get cancel => 'Cancel';

  @override
  String get cefrLevel => 'CEFR Level';

  @override
  String get complete => 'Complete';

  @override
  String get confirm => 'Confirm';

  @override
  String get congratulations => 'Congratulations on completing this lesson successfully!';

  @override
  String get continueText => 'Continue';

  @override
  String get dharmaSegment => 'Dharma';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get feedback => 'Feedback';

  @override
  String get finishLesson => 'Finish Lesson';

  @override
  String get fluency => 'Fluency';

  @override
  String get grammar => 'Grammar';

  @override
  String get guidedStageTitle => 'Stage 1: Listen & Reflect';

  @override
  String get hideIpa => 'Hide IPA Notation';

  @override
  String get home => 'Home';

  @override
  String get inputStageTitle => 'Stage 2: Language Input';

  @override
  String get language => 'Language';

  @override
  String get lessonCompleted => 'Lesson Completed!';

  @override
  String get loading => 'Loading...';

  @override
  String get matchWords => 'Tri-lingual Word Matching';

  @override
  String get meditationSegment => 'Meditation';

  @override
  String get meditationStage => 'Meditation Stage';

  @override
  String get meditationTestTitle => '2. Meditation Experience';

  @override
  String get meditator => 'Meditator';

  @override
  String get monkMode => 'Monk Mode';

  @override
  String get navigationError => 'Navigation Error';

  @override
  String get nextPatternPractice => 'Next: Word Match →';

  @override
  String get noConversation => 'No conversation available for this lesson.';

  @override
  String get noPatterns => 'No pattern practice available.';

  @override
  String get noPractice => 'No practice steps available.';

  @override
  String get outputStageTitle => 'Stage 4: Pronunciation Practice';

  @override
  String get pageNotFound => 'Page not found';

  @override
  String get paliKnowledge => 'Pāli Knowledge';

  @override
  String get paliSegment => 'Pāli';

  @override
  String get paliTestTitle => '3. Pāli Knowledge';

  @override
  String get patternStageTitle => 'Stage 3: Structure & Word Match';

  @override
  String get patternViewStageTitle => 'Stage 3a: Observe Structure';

  @override
  String get placementResultTitle => 'Your Customized Learning Path';

  @override
  String get placementTest => 'Placement Test';

  @override
  String get placementTestSubtitle => 'Determine English level, Meditation stage & Pāli knowledge';

  @override
  String get placementTestTitle => 'Initial Competency Assessment';

  @override
  String get pronunciation => 'Pronunciation';

  @override
  String get quickStart => 'Quick Start';

  @override
  String get retry => 'Retry';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get settings => 'Settings';

  @override
  String get showIpa => 'Show IPA Notation';

  @override
  String get silentMode => 'Silent Mode';

  @override
  String get silentModeDesc => 'No auto audio playback. Suitable for monastery environment.';

  @override
  String get silentModeOff => 'Silent Mode is OFF';

  @override
  String get silentModeOn => 'Silent Mode is ON';

  @override
  String get smartSuggestion => 'Smart Suggestion';

  @override
  String get startInterview => 'Start AI Interview';

  @override
  String get startLearning => 'Start Learning';

  @override
  String get suggestion => 'Improvement Suggestion';

  @override
  String get systemDefault => 'System Default';

  @override
  String get turnOffSilentToRecord => 'Turn off silent mode to record';

  @override
  String get venerableMonk => 'Venerable Monk / Sangha';

  @override
  String get viewDetails => 'View Details';

  @override
  String get vocabTestTitle => '1. Vocabulary & Grammar';

  @override
  String get vocabulary => 'Vocabulary';

  @override
  String get welcomeBack => 'Welcome';

}

/// The translations for `es`.
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([super.localeName = 'es']);

  @override
  String get accuracy => 'Precisión';

  @override
  String get aiFeedback => 'Evaluación de IA';

  @override
  String get aiInterview => 'Entrevista IA';

  @override
  String get aiInterviewDescription => 'Practica inglés de Dharma y meditación con IA';

  @override
  String get appSubtitle => 'Inglés para Sabiduría y Meditación';

  @override
  String get appTitle => 'ZENGLISH - Inglés para Sabiduría y Meditación';

  @override
  String get back => 'Volver';

  @override
  String get backToHome => 'Volver al inicio';

  @override
  String get backToMain => 'Volver a la página principal';

  @override
  String get cancel => 'Cancelar';

  @override
  String get cefrLevel => 'Nivel CEFR';

  @override
  String get complete => 'Completar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get congratulations => '¡Felicitaciones por completar con éxito esta lección!';

  @override
  String get continueText => 'Continuar';

  @override
  String get dharmaSegment => 'Dharma';

  @override
  String get errorOccurred => 'Ocurrió un error';

  @override
  String get feedback => 'Comentarios';

  @override
  String get finishLesson => 'Finalizar lección';

  @override
  String get fluency => 'Fluidez';

  @override
  String get grammar => 'Gramática';

  @override
  String get guidedStageTitle => 'Etapa 1: Escuchar y Reflexionar';

  @override
  String get hideIpa => 'Ocultar fonética IPA';

  @override
  String get home => 'Inicio';

  @override
  String get inputStageTitle => 'Etapa 2: Entrada del Lenguaje';

  @override
  String get language => 'Idioma';

  @override
  String get lessonCompleted => '¡Lección completada!';

  @override
  String get loading => 'Cargando...';

  @override
  String get matchWords => 'Emparejamiento trilingüe de palabras';

  @override
  String get meditationSegment => 'Meditation';

  @override
  String get meditationStage => 'Etapa de Meditación';

  @override
  String get meditationTestTitle => '2. Experiencia en Meditación';

  @override
  String get meditator => 'Meditador';

  @override
  String get monkMode => 'Modo Monje';

  @override
  String get navigationError => 'Error de navegación';

  @override
  String get nextPatternPractice => 'Siguiente: Emparejar palabras →';

  @override
  String get noConversation => 'No hay conversación disponible para esta lección.';

  @override
  String get noPatterns => 'No hay ejercicios de patrones.';

  @override
  String get noPractice => 'No hay pasos de práctica disponibles.';

  @override
  String get outputStageTitle => 'Etapa 4: Práctica de Pronunciación';

  @override
  String get pageNotFound => 'Página no encontrada';

  @override
  String get paliKnowledge => 'Conocimiento de Pāli';

  @override
  String get paliSegment => 'Pāli';

  @override
  String get paliTestTitle => '3. Conocimiento de Pāli';

  @override
  String get patternStageTitle => 'Etapa 3: Estructura y Emparejamiento';

  @override
  String get patternViewStageTitle => 'Etapa 3a: Observar Estructura';

  @override
  String get placementResultTitle => 'Tu ruta de aprendizaje personalizada';

  @override
  String get placementTest => 'Prueba de nivel';

  @override
  String get placementTestSubtitle => 'Determina nivel de inglés, etapa de meditación y conocimientos de Pāli';

  @override
  String get placementTestTitle => 'Evaluación inicial de competencias';

  @override
  String get pronunciation => 'Pronunciación';

  @override
  String get quickStart => 'Inicio rápido';

  @override
  String get retry => 'Reintentar';

  @override
  String get selectLanguage => 'Seleccionar idioma';

  @override
  String get settings => 'Configuración';

  @override
  String get showIpa => 'Mostrar fonética IPA';

  @override
  String get silentMode => 'Modo Silencioso';

  @override
  String get silentModeDesc => 'Sin reproducción automática de audio. Adecuado para el monasterio.';

  @override
  String get silentModeOff => 'Modo silencioso DESACTIVADO';

  @override
  String get silentModeOn => 'Modo silencioso ACTIVADO';

  @override
  String get smartSuggestion => 'Sugerencia inteligente';

  @override
  String get startInterview => 'Iniciar entrevista IA';

  @override
  String get startLearning => 'Comenzar a aprender';

  @override
  String get suggestion => 'Sugerencia de mejora';

  @override
  String get systemDefault => 'Predeterminado del sistema';

  @override
  String get turnOffSilentToRecord => 'Desactiva el modo silencioso para grabar';

  @override
  String get venerableMonk => 'Venerable Monje / Sangha';

  @override
  String get viewDetails => 'Ver detalles';

  @override
  String get vocabTestTitle => '1. Vocabulario y Gramática';

  @override
  String get vocabulary => 'Vocabulario';

  @override
  String get welcomeBack => 'Bienvenido';

}

/// The translations for `fr`.
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([super.localeName = 'fr']);

  @override
  String get accuracy => 'Précision';

  @override
  String get aiFeedback => 'Évaluation de l\'IA';

  @override
  String get aiInterview => 'Entretien IA';

  @override
  String get aiInterviewDescription => 'Pratiquez l\'anglais du Dharma et de la méditation avec l\'IA';

  @override
  String get appSubtitle => 'Anglais pour la Sagesse & la Méditation';

  @override
  String get appTitle => 'ZENGLISH - Anglais pour la Sagesse & la Méditation';

  @override
  String get back => 'Retour';

  @override
  String get backToHome => 'Retour à l\'accueil';

  @override
  String get backToMain => 'Retour à la page principale';

  @override
  String get cancel => 'Annuler';

  @override
  String get cefrLevel => 'Niveau CEFR';

  @override
  String get complete => 'Terminer';

  @override
  String get confirm => 'Confirmer';

  @override
  String get congratulations => 'Félicitations pour avoir réussi cette leçon !';

  @override
  String get continueText => 'Continuer';

  @override
  String get dharmaSegment => 'Dharma';

  @override
  String get errorOccurred => 'Une erreur est survenue';

  @override
  String get feedback => 'Commentaires';

  @override
  String get finishLesson => 'Terminer la leçon';

  @override
  String get fluency => 'Fluidité';

  @override
  String get grammar => 'Grammaire';

  @override
  String get guidedStageTitle => 'Étape 1: Écouter & Réfléchir';

  @override
  String get hideIpa => 'Masquer les symboles IPA';

  @override
  String get home => 'Accueil';

  @override
  String get inputStageTitle => 'Étape 2: Entrée linguistique';

  @override
  String get language => 'Langue';

  @override
  String get lessonCompleted => 'Leçon terminée !';

  @override
  String get loading => 'Chargement...';

  @override
  String get matchWords => 'Association de mots trilingue';

  @override
  String get meditationSegment => 'Meditation';

  @override
  String get meditationStage => 'Stade de méditation';

  @override
  String get meditationTestTitle => '2. Expérience de méditation';

  @override
  String get meditator => 'Méditant';

  @override
  String get monkMode => 'Mode Moine';

  @override
  String get navigationError => 'Erreur de navigation';

  @override
  String get nextPatternPractice => 'Suivant: Associer les mots →';

  @override
  String get noConversation => 'Aucune conversation disponible pour cette leçon.';

  @override
  String get noPatterns => 'Aucun exercice de structure disponible.';

  @override
  String get noPractice => 'Aucune étape de pratique disponible.';

  @override
  String get outputStageTitle => 'Étape 4: Pratique de la prononciation';

  @override
  String get pageNotFound => 'Page non trouvée';

  @override
  String get paliKnowledge => 'Connaissances en Pāli';

  @override
  String get paliSegment => 'Pāli';

  @override
  String get paliTestTitle => '3. Connaissances en Pāli';

  @override
  String get patternStageTitle => 'Étape 3: Structure & Association de mots';

  @override
  String get patternViewStageTitle => 'Étape 3a: Observer la structure';

  @override
  String get placementResultTitle => 'Votre parcours d\'apprentissage personnalisé';

  @override
  String get placementTest => 'Test de niveau';

  @override
  String get placementTestSubtitle => 'Déterminez le niveau d\'anglais, le stade de méditation et les connaissances en Pāli';

  @override
  String get placementTestTitle => 'Évaluation initiale des compétences';

  @override
  String get pronunciation => 'Prononciation';

  @override
  String get quickStart => 'Démarrage rapide';

  @override
  String get retry => 'Réessayer';

  @override
  String get selectLanguage => 'Choisir la langue';

  @override
  String get settings => 'Paramètres';

  @override
  String get showIpa => 'Afficher les symboles IPA';

  @override
  String get silentMode => 'Mode Silencieux';

  @override
  String get silentModeDesc => 'Pas de lecture audio automatique. Adapté à l\'environnement monastique.';

  @override
  String get silentModeOff => 'Mode silencieux DÉSACTIVÉ';

  @override
  String get silentModeOn => 'Mode silencieux ACTIVÉ';

  @override
  String get smartSuggestion => 'Suggestion intelligente';

  @override
  String get startInterview => 'Démarrer l\'entretien IA';

  @override
  String get startLearning => 'Commencer l\'apprentissage';

  @override
  String get suggestion => 'Suggestion d\'amélioration';

  @override
  String get systemDefault => 'Par défaut du système';

  @override
  String get turnOffSilentToRecord => 'Désactivez le mode silencieux pour enregistrer';

  @override
  String get venerableMonk => 'Vénérable Moine / Sangha';

  @override
  String get viewDetails => 'Voir les détails';

  @override
  String get vocabTestTitle => '1. Vocabulaire & Grammaire';

  @override
  String get vocabulary => 'Vocabulaire';

  @override
  String get welcomeBack => 'Bienvenue';

}

/// The translations for `hi`.
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([super.localeName = 'hi']);

  @override
  String get accuracy => 'सटीकता';

  @override
  String get aiFeedback => 'AI प्रतिक्रिया';

  @override
  String get aiInterview => 'AI साक्षात्कार';

  @override
  String get aiInterviewDescription => 'एआई के साथ धर्म और ध्यान अंग्रेजी का अभ्यास करें';

  @override
  String get appSubtitle => 'English for Wisdom & Meditation';

  @override
  String get appTitle => 'ZENGLISH - English for Wisdom & Meditation';

  @override
  String get back => 'वापस';

  @override
  String get backToHome => 'होम पर जाएं';

  @override
  String get backToMain => 'मुख्य पृष्ठ पर जाएं';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get cefrLevel => 'CEFR स्तर';

  @override
  String get complete => 'पूर्ण';

  @override
  String get confirm => 'पुष्टि करें';

  @override
  String get congratulations => 'इस पाठ को सफलतापूर्वक पूरा करने पर बधाई!';

  @override
  String get continueText => 'आगे बढ़ें';

  @override
  String get dharmaSegment => 'Dharma';

  @override
  String get errorOccurred => 'एक त्रुटि हुई';

  @override
  String get feedback => 'प्रतिक्रिया';

  @override
  String get finishLesson => 'पाठ समाप्त करें';

  @override
  String get fluency => 'प्रवाह';

  @override
  String get grammar => 'व्याकरण';

  @override
  String get guidedStageTitle => 'चरण 1: सुनें और समझें';

  @override
  String get hideIpa => 'IPA छिपाएं';

  @override
  String get home => 'होम';

  @override
  String get inputStageTitle => 'चरण 2: भाषा इनपुट';

  @override
  String get language => 'भाषा';

  @override
  String get lessonCompleted => 'पाठ पूरा हुआ!';

  @override
  String get loading => 'लोड हो रहा है...';

  @override
  String get matchWords => 'त्रिभाषी शब्द मिलान';

  @override
  String get meditationSegment => 'Meditation';

  @override
  String get meditationStage => 'ध्यान का चरण';

  @override
  String get meditationTestTitle => '2. ध्यान का अनुभव';

  @override
  String get meditator => 'ध्यानी';

  @override
  String get monkMode => 'भिक्षु मोड';

  @override
  String get navigationError => 'नेविगेशन त्रुटि';

  @override
  String get nextPatternPractice => 'आगे: शब्द मिलान →';

  @override
  String get noConversation => 'इस पाठ के लिए कोई बातचीत उपलब्ध नहीं है।';

  @override
  String get noPatterns => 'कोई पैटर्न अभ्यास उपलब्ध नहीं है।';

  @override
  String get noPractice => 'कोई अभ्यास चरण उपलब्ध नहीं है।';

  @override
  String get outputStageTitle => 'चरण 4: उच्चारण अभ्यास';

  @override
  String get pageNotFound => 'पृष्ठ नहीं मिला';

  @override
  String get paliKnowledge => 'पालि ज्ञान';

  @override
  String get paliSegment => 'Pāli';

  @override
  String get paliTestTitle => '3. पालि ज्ञान';

  @override
  String get patternStageTitle => 'चरण 3: संरचना और शब्द मिलान';

  @override
  String get patternViewStageTitle => 'चरण 3a: संरचना देखें';

  @override
  String get placementResultTitle => 'आपका अनुकूलित सीखने का मार्ग';

  @override
  String get placementTest => 'स्तर मूल्यांकन';

  @override
  String get placementTestSubtitle => 'अंग्रेजी स्तर, ध्यान चरण और पालि ज्ञान निर्धारित करें';

  @override
  String get placementTestTitle => 'प्रारंभिक क्षमता मूल्यांकन';

  @override
  String get pronunciation => 'उच्चारण';

  @override
  String get quickStart => 'त्वरित प्रारंभ';

  @override
  String get retry => 'पुनः प्रयास करें';

  @override
  String get selectLanguage => 'भाषा चुनें';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get showIpa => 'IPA दिखाएं';

  @override
  String get silentMode => 'शांत मोड';

  @override
  String get silentModeDesc => 'स्वचालित ऑडियो नहीं। आश्रम/विहार वातावरण के लिए उपयुक्त।';

  @override
  String get silentModeOff => 'शांत मोड बंद है';

  @override
  String get silentModeOn => 'शांत मोड चालू है';

  @override
  String get smartSuggestion => 'स्मार्ट सुझाव';

  @override
  String get startInterview => 'AI साक्षात्कार शुरू करें';

  @override
  String get startLearning => 'सीखना शुरू करें';

  @override
  String get suggestion => 'सुधार का सुझाव';

  @override
  String get systemDefault => 'सिस्टम डिफ़ॉल्ट';

  @override
  String get turnOffSilentToRecord => 'रिकॉर्ड करने के लिए शांत मोड बंद करें';

  @override
  String get venerableMonk => 'पूज्य भिक्षु / संघ';

  @override
  String get viewDetails => 'विवरण देखें';

  @override
  String get vocabTestTitle => '1. शब्दावली और व्याकरण';

  @override
  String get vocabulary => 'शब्दावली';

  @override
  String get welcomeBack => 'स्वागत है';

}

/// The translations for `id`.
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([super.localeName = 'id']);

  @override
  String get accuracy => 'Akurasi';

  @override
  String get aiFeedback => 'Evaluasi AI';

  @override
  String get aiInterview => 'Wawancara AI';

  @override
  String get aiInterviewDescription => 'Latih Bahasa Inggris Dharma & Meditasi bersama AI';

  @override
  String get appSubtitle => 'Bahasa Inggris untuk Kebijaksanaan & Meditasi';

  @override
  String get appTitle => 'ZENGLISH - Bahasa Inggris untuk Kebijaksanaan & Meditasi';

  @override
  String get back => 'Kembali';

  @override
  String get backToHome => 'Kembali ke Beranda';

  @override
  String get backToMain => 'Kembali ke Halaman Utama';

  @override
  String get cancel => 'Batal';

  @override
  String get cefrLevel => 'Tingkat CEFR';

  @override
  String get complete => 'Selesai';

  @override
  String get confirm => 'Konfirmasi';

  @override
  String get congratulations => 'Selamat telah berhasil menyelesaikan pelajaran ini!';

  @override
  String get continueText => 'Lanjutkan';

  @override
  String get dharmaSegment => 'Dharma';

  @override
  String get errorOccurred => 'Terjadi kesalahan';

  @override
  String get feedback => 'Umpan Balik';

  @override
  String get finishLesson => 'Selesaikan Pelajaran';

  @override
  String get fluency => 'Kelancaran';

  @override
  String get grammar => 'Tata Bahasa';

  @override
  String get guidedStageTitle => 'Tahap 1: Mendengarkan & Merenung';

  @override
  String get hideIpa => 'Sembunyikan Transkripsi IPA';

  @override
  String get home => 'Beranda';

  @override
  String get inputStageTitle => 'Tahap 2: Input Bahasa';

  @override
  String get language => 'Bahasa';

  @override
  String get lessonCompleted => 'Pelajaran Selesai!';

  @override
  String get loading => 'Memuat...';

  @override
  String get matchWords => 'Pencocokan Kata Tiga Bahasa';

  @override
  String get meditationSegment => 'Meditation';

  @override
  String get meditationStage => 'Tahap Meditasi';

  @override
  String get meditationTestTitle => '2. Pengalaman Meditasi';

  @override
  String get meditator => 'Praktisi Meditasi';

  @override
  String get monkMode => 'Mode Anggota Sangha';

  @override
  String get navigationError => 'Kesalahan Navigasi';

  @override
  String get nextPatternPractice => 'Berikutnya: Cocokkan Kata →';

  @override
  String get noConversation => 'Tidak ada percakapan untuk pelajaran ini.';

  @override
  String get noPatterns => 'Tidak ada latihan pola kalimat.';

  @override
  String get noPractice => 'Tidak ada langkah latihan.';

  @override
  String get outputStageTitle => 'Tahap 4: Latihan Pengucapan';

  @override
  String get pageNotFound => 'Halaman tidak ditemukan';

  @override
  String get paliKnowledge => 'Pengetahuan Pāli';

  @override
  String get paliSegment => 'Pāli';

  @override
  String get paliTestTitle => '3. Pengetahuan Pāli';

  @override
  String get patternStageTitle => 'Tahap 3: Struktur & Pencocokan Kata';

  @override
  String get patternViewStageTitle => 'Tahap 3a: Amati Struktur';

  @override
  String get placementResultTitle => 'Jalur Pembelajaran yang Disesuaikan';

  @override
  String get placementTest => 'Tes Penempatan';

  @override
  String get placementTestSubtitle => 'Tentukan tingkat Bahasa Inggris, tahap Meditasi & pengetahuan Pāli';

  @override
  String get placementTestTitle => 'Evaluasi Kemampuan Awal';

  @override
  String get pronunciation => 'Pengucapan';

  @override
  String get quickStart => 'Mulai Cepat';

  @override
  String get retry => 'Coba Lagi';

  @override
  String get selectLanguage => 'Pilih Bahasa';

  @override
  String get settings => 'Pengaturan';

  @override
  String get showIpa => 'Tampilkan Transkripsi IPA';

  @override
  String get silentMode => 'Mode Hening';

  @override
  String get silentModeDesc => 'Tanpa pemutaran audio otomatis. Cocok untuk lingkungan vihara.';

  @override
  String get silentModeOff => 'Mode Hening NONAKTIF';

  @override
  String get silentModeOn => 'Mode Hening AKTIF';

  @override
  String get smartSuggestion => 'Saran Pintar';

  @override
  String get startInterview => 'Mulai Wawancara AI';

  @override
  String get startLearning => 'Mulai Belajar';

  @override
  String get suggestion => 'Saran Perbaikan';

  @override
  String get systemDefault => 'Default Sistem';

  @override
  String get turnOffSilentToRecord => 'Matikan mode hening untuk merekam';

  @override
  String get venerableMonk => 'Bikkhu yang Mulia / Sangha';

  @override
  String get viewDetails => 'Lihat Detail';

  @override
  String get vocabTestTitle => '1. Kosakata & Tata Bahasa';

  @override
  String get vocabulary => 'Kosakata';

  @override
  String get welcomeBack => 'Selamat Datang';

}

/// The translations for `it`.
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([super.localeName = 'it']);

  @override
  String get accuracy => 'Accuratezza';

  @override
  String get aiFeedback => 'Valutazione IA';

  @override
  String get aiInterview => 'Intervista IA';

  @override
  String get aiInterviewDescription => 'Esercitati nell\'inglese del Dharma e della meditazione con l\'IA';

  @override
  String get appSubtitle => 'Inglese per la Saggezza e la Meditazione';

  @override
  String get appTitle => 'ZENGLISH - Inglese per la Saggezza e la Meditazione';

  @override
  String get back => 'Indietro';

  @override
  String get backToHome => 'Torna alla home';

  @override
  String get backToMain => 'Torna alla pagina principale';

  @override
  String get cancel => 'Annulla';

  @override
  String get cefrLevel => 'Livello CEFR';

  @override
  String get complete => 'Completato';

  @override
  String get confirm => 'Conferma';

  @override
  String get congratulations => 'Congratulazioni per aver completato con successo questa lezione!';

  @override
  String get continueText => 'Continua';

  @override
  String get dharmaSegment => 'Dharma';

  @override
  String get errorOccurred => 'Si è verificato un errore';

  @override
  String get feedback => 'Feedback';

  @override
  String get finishLesson => 'Termina lezione';

  @override
  String get fluency => 'Fluidezza';

  @override
  String get grammar => 'Grammatica';

  @override
  String get guidedStageTitle => 'Fase 1: Ascolta e Rifletti';

  @override
  String get hideIpa => 'Nascondi trascrizione IPA';

  @override
  String get home => 'Home';

  @override
  String get inputStageTitle => 'Fase 2: Input Linguistico';

  @override
  String get language => 'Lingua';

  @override
  String get lessonCompleted => 'Lezione completata!';

  @override
  String get loading => 'Caricamento...';

  @override
  String get matchWords => 'Abbinamento parole trilingue';

  @override
  String get meditationSegment => 'Meditation';

  @override
  String get meditationStage => 'Fase di Meditazione';

  @override
  String get meditationTestTitle => '2. Esperienza di Meditazione';

  @override
  String get meditator => 'Meditatore';

  @override
  String get monkMode => 'Modalità Monaco';

  @override
  String get navigationError => 'Errore di navigazione';

  @override
  String get nextPatternPractice => 'Successivo: Abbinamento parole →';

  @override
  String get noConversation => 'Nessuna conversazione disponibile per questa lezione.';

  @override
  String get noPatterns => 'Nessuna esercitazione di strutture disponibile.';

  @override
  String get noPractice => 'Nessun passaggio di pratica disponibile.';

  @override
  String get outputStageTitle => 'Fase 4: Pratica della Pronuncia';

  @override
  String get pageNotFound => 'Pagina non trovata';

  @override
  String get paliKnowledge => 'Conoscenza del Pāli';

  @override
  String get paliSegment => 'Pāli';

  @override
  String get paliTestTitle => '3. Conoscenza del Pāli';

  @override
  String get patternStageTitle => 'Fase 3: Struttura e Abbinamento Parole';

  @override
  String get patternViewStageTitle => 'Fase 3a: Osserva la Struttura';

  @override
  String get placementResultTitle => 'Il tuo percorso di apprendimento personalizzato';

  @override
  String get placementTest => 'Test di livello';

  @override
  String get placementTestSubtitle => 'Determina livello di inglese, fase di meditazione e conoscenza del Pāli';

  @override
  String get placementTestTitle => 'Valutazione iniziale delle competenze';

  @override
  String get pronunciation => 'Pronuncia';

  @override
  String get quickStart => 'Avvio rapido';

  @override
  String get retry => 'Riprova';

  @override
  String get selectLanguage => 'Seleziona lingua';

  @override
  String get settings => 'Impostazioni';

  @override
  String get showIpa => 'Mostra trascrizione IPA';

  @override
  String get silentMode => 'Modalità Silenziosa';

  @override
  String get silentModeDesc => 'Nessuna riproduzione audio automatica. Adatto per l\'ambiente del monastero.';

  @override
  String get silentModeOff => 'Modalità silenziosa DISATTIVA';

  @override
  String get silentModeOn => 'Modalità silenziosa ATTIVA';

  @override
  String get smartSuggestion => 'Suggerimento intelligente';

  @override
  String get startInterview => 'Avvia intervista IA';

  @override
  String get startLearning => 'Inizia ad imparare';

  @override
  String get suggestion => 'Suggerimento di miglioramento';

  @override
  String get systemDefault => 'Predefinito di sistema';

  @override
  String get turnOffSilentToRecord => 'Disattiva la modalità silenziosa per registrare';

  @override
  String get venerableMonk => 'Venerabile Monaco / Sangha';

  @override
  String get viewDetails => 'Visualizza dettagli';

  @override
  String get vocabTestTitle => '1. Vocabolario e Grammatica';

  @override
  String get vocabulary => 'Vocabolario';

  @override
  String get welcomeBack => 'Benvenuto';

}

/// The translations for `ja`.
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([super.localeName = 'ja']);

  @override
  String get accuracy => '正確さ';

  @override
  String get aiFeedback => 'AI の評価';

  @override
  String get aiInterview => 'AI インタビュー';

  @override
  String get aiInterviewDescription => 'AI と一緒に仏法と瞑想の英語を練習する';

  @override
  String get appSubtitle => '智慧と瞑想の英語';

  @override
  String get appTitle => 'ZENGLISH - 智慧と瞑想の英語';

  @override
  String get back => '戻る';

  @override
  String get backToHome => 'ホームに戻る';

  @override
  String get backToMain => 'メインページに戻る';

  @override
  String get cancel => 'キャンセル';

  @override
  String get cefrLevel => 'CEFR レベル';

  @override
  String get complete => '完了';

  @override
  String get confirm => '確認';

  @override
  String get congratulations => 'このレッスンの修了おめでとうございます！';

  @override
  String get continueText => '次へ';

  @override
  String get dharmaSegment => 'Dharma';

  @override
  String get errorOccurred => 'エラーが発生しました';

  @override
  String get feedback => 'フィードバック';

  @override
  String get finishLesson => 'レッスンを終了';

  @override
  String get fluency => '流暢さ';

  @override
  String get grammar => '文法';

  @override
  String get guidedStageTitle => 'ステージ 1: 傾聴と観察';

  @override
  String get hideIpa => 'IPA 発音記号を非表示';

  @override
  String get home => 'ホーム';

  @override
  String get inputStageTitle => 'ステージ 2: 言語インプット';

  @override
  String get language => '言語';

  @override
  String get lessonCompleted => 'レッスン完了！';

  @override
  String get loading => '読み込み中...';

  @override
  String get matchWords => '3言語単語マッチング';

  @override
  String get meditationSegment => 'Meditation';

  @override
  String get meditationStage => '瞑想の段階';

  @override
  String get meditationTestTitle => '2. 瞑想の lived 経験';

  @override
  String get meditator => '瞑想者';

  @override
  String get monkMode => '僧伽モード';

  @override
  String get navigationError => 'ナビゲーションエラー';

  @override
  String get nextPatternPractice => '次へ: 単語マッチング →';

  @override
  String get noConversation => 'このレッスンには会話がありません。';

  @override
  String get noPatterns => '構文練習はありません。';

  @override
  String get noPractice => '練習ステップはありません。';

  @override
  String get outputStageTitle => 'ステージ 4: 発音練習';

  @override
  String get pageNotFound => 'ページが見つかりません';

  @override
  String get paliKnowledge => 'パーリ語レベル';

  @override
  String get paliSegment => 'Pāli';

  @override
  String get paliTestTitle => '3. パーリ語の知識';

  @override
  String get patternStageTitle => 'ステージ 3: 構文と単語マッチング';

  @override
  String get patternViewStageTitle => 'ステージ 3a: 構造の観察';

  @override
  String get placementResultTitle => 'あなた専用の学習プラン';

  @override
  String get placementTest => 'レベル判定テスト';

  @override
  String get placementTestSubtitle => '英語レベル、瞑想段階、パーリ語の知識を判定';

  @override
  String get placementTestTitle => '初期能力評価';

  @override
  String get pronunciation => '発音';

  @override
  String get quickStart => 'クイックスタート';

  @override
  String get retry => '再試行';

  @override
  String get selectLanguage => '言語を選択';

  @override
  String get settings => '設定';

  @override
  String get showIpa => 'IPA 発音記号を表示';

  @override
  String get silentMode => '消音モード';

  @override
  String get silentModeDesc => '自動音声再生を行いません。寺院・禅堂に最適です。';

  @override
  String get silentModeOff => '消音モード OFF';

  @override
  String get silentModeOn => '消音モード ON';

  @override
  String get smartSuggestion => 'スマート学習提案';

  @override
  String get startInterview => 'AI インタビューを開始';

  @override
  String get startLearning => '学習を始める';

  @override
  String get suggestion => '改善の提案';

  @override
  String get systemDefault => 'システム設定に従う';

  @override
  String get turnOffSilentToRecord => '録音するには消音モードを解除してください';

  @override
  String get venerableMonk => 'ご尊者 / 僧伽';

  @override
  String get viewDetails => '詳細を見る';

  @override
  String get vocabTestTitle => '1. 語彙と文法';

  @override
  String get vocabulary => '語彙';

  @override
  String get welcomeBack => 'ようこそ';

}

/// The translations for `km`.
class AppLocalizationsKm extends AppLocalizations {
  AppLocalizationsKm([super.localeName = 'km']);

  @override
  String get accuracy => 'ភាពត្រឹមត្រូវ';

  @override
  String get aiFeedback => 'ការវាយតម្លៃពី AI';

  @override
  String get aiInterview => 'កិច្ចសម្ភាសន៍ AI';

  @override
  String get aiInterviewDescription => 'ហ្វឹកហាត់ភាសាអង់គ្លេសព្រះធម៌ និងភាវនាជាមួយ AI';

  @override
  String get appSubtitle => 'English for Wisdom & Meditation';

  @override
  String get appTitle => 'ZENGLISH - English for Wisdom & Meditation';

  @override
  String get back => 'ត្រឡប់ក្រោយ';

  @override
  String get backToHome => 'ត្រឡប់ទៅទំព័រដើម';

  @override
  String get backToMain => 'ត្រឡប់ទៅទំព័រចម្បង';

  @override
  String get cancel => 'បោះបង់';

  @override
  String get cefrLevel => 'កម្រិត CEFR';

  @override
  String get complete => 'បរិបូណ៌';

  @override
  String get confirm => 'បញ្ជាក់';

  @override
  String get congratulations => 'អបអរសាទរដែលបានបញ្ចប់មេរៀននេះដោយជោគជ័យ!';

  @override
  String get continueText => 'បន្ត';

  @override
  String get dharmaSegment => 'Dharma';

  @override
  String get errorOccurred => 'មានកំហុសកើតឡើង';

  @override
  String get feedback => 'ការវាយតម្លៃ';

  @override
  String get finishLesson => 'បញ្ចប់មេរៀន';

  @override
  String get fluency => 'ភាពរលូន';

  @override
  String get grammar => 'វេយ្យាករណ៍';

  @override
  String get guidedStageTitle => 'វគ្គ ១: ស្តាប់ និងពិចារណា';

  @override
  String get hideIpa => 'លាក់សញ្ញា IPA';

  @override
  String get home => 'ទំព័រដើម';

  @override
  String get inputStageTitle => 'វគ្គ ២: ការទទួលភាសា';

  @override
  String get language => 'ភាសា';

  @override
  String get lessonCompleted => 'មេរៀនត្រូវបានបញ្ចប់!';

  @override
  String get loading => 'កំពុងផ្ទុក...';

  @override
  String get matchWords => 'ការផ្គូផ្គងពាក្យបីភាសា';

  @override
  String get meditationSegment => 'Meditation';

  @override
  String get meditationStage => 'ដំណាក់កាលភាវនា';

  @override
  String get meditationTestTitle => '២. បទពិសោធន៍ភាវនា';

  @override
  String get meditator => 'អ្នកប្រតិបត្តិភាវនា';

  @override
  String get monkMode => 'របៀបព្រះសង្ឃ';

  @override
  String get navigationError => 'កំហុសក្នុងការរុករក';

  @override
  String get nextPatternPractice => 'បន្ទាប់: ផ្គូផ្គងពាក្យ →';

  @override
  String get noConversation => 'គ្មានកិច្ចសន្ទនាសម្រាប់មេរៀននេះទេ។';

  @override
  String get noPatterns => 'គ្មានការហ្វឹកហាត់លំនាំគំរូទេ។';

  @override
  String get noPractice => 'គ្មានជំហានហ្វឹកហាត់ទេ។';

  @override
  String get outputStageTitle => 'វគ្គ ៤: ការហ្វឹកហាត់បញ្ចេញសំឡេង';

  @override
  String get pageNotFound => 'រកមិនឃើញទំព័រ';

  @override
  String get paliKnowledge => 'ចំណេះដឹងបាលី';

  @override
  String get paliSegment => 'Pāli';

  @override
  String get paliTestTitle => '៣. ចំណេះដឹងបាលី';

  @override
  String get patternStageTitle => 'វគ្គ ៣: រចនាសម្ព័ន្ធ និងផ្គូផ្គងពាក្យ';

  @override
  String get patternViewStageTitle => 'វគ្គ ៣a: សង្កេតរចនាសម្ព័ន្ធ';

  @override
  String get placementResultTitle => 'ផ្លូវសិក្សាជាក់លាក់សម្រាប់អ្នក';

  @override
  String get placementTest => 'ការតេស្តវាស់កម្រិត';

  @override
  String get placementTestSubtitle => 'កំណត់កម្រិតភាសាអង់គ្លេស ដំណាក់កាលភាវនា និងចំណេះដឹងបាលី';

  @override
  String get placementTestTitle => 'ការវាយតម្លៃសមត្ថភាពដំបូង';

  @override
  String get pronunciation => 'ការបញ្ចេញសំឡេង';

  @override
  String get quickStart => 'ចាប់ផ្តើមរហ័ស';

  @override
  String get retry => 'ព្យាយាមម្តងទៀត';

  @override
  String get selectLanguage => 'ជ្រើសរើសភាសា';

  @override
  String get settings => 'ការកំណត់';

  @override
  String get showIpa => 'បង្ហាញសញ្ញា IPA';

  @override
  String get silentMode => 'របៀបស្ងាត់';

  @override
  String get silentModeDesc => 'គ្មានសំឡេងស្វ័យប្រវត្តិ។ ស័ក្តិសមសម្រាប់បរិស្ថានវត្តអារាម។';

  @override
  String get silentModeOff => 'របៀបស្ងាត់ បិទ';

  @override
  String get silentModeOn => 'របៀបស្ងាត់ បើក';

  @override
  String get smartSuggestion => 'ការណែនាំឆ្លាតវៃ';

  @override
  String get startInterview => 'ចាប់ផ្តើមកិច្ចសម្ភាសន៍ AI';

  @override
  String get startLearning => 'ចាប់ផ្តើមរៀន';

  @override
  String get suggestion => 'ការណែនាំកែលម្អ';

  @override
  String get systemDefault => 'តាមប្រព័ន្ធ';

  @override
  String get turnOffSilentToRecord => 'បិទរបៀបស្ងាត់ដើម្បីថតសំឡេង';

  @override
  String get venerableMonk => 'ព្រះសង្ឃ / ព្រះសង្ឃរតនៈ';

  @override
  String get viewDetails => 'មើលលម្អិត';

  @override
  String get vocabTestTitle => '១. ពាក្យសព្ទ និងវេយ្យាករណ៍';

  @override
  String get vocabulary => 'ពាក្យសព្ទ';

  @override
  String get welcomeBack => 'សូមស្វាគមន៍';

}

/// The translations for `ko`.
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([super.localeName = 'ko']);

  @override
  String get accuracy => '정확도';

  @override
  String get aiFeedback => 'AI 평가';

  @override
  String get aiInterview => 'AI 인터뷰';

  @override
  String get aiInterviewDescription => 'AI와 함께 법문 및 명상 영어를 연습하세요';

  @override
  String get appSubtitle => '지혜와 명상을 위한 영어';

  @override
  String get appTitle => 'ZENGLISH - 지혜와 명상을 위한 영어';

  @override
  String get back => '뒤로';

  @override
  String get backToHome => '홈으로 이동';

  @override
  String get backToMain => '메인 페이지로 이동';

  @override
  String get cancel => '취소';

  @override
  String get cefrLevel => 'CEFR 레벨';

  @override
  String get complete => '완료';

  @override
  String get confirm => '확인';

  @override
  String get congratulations => '이번 수업을 성공적으로 마친 것을 축하합니다!';

  @override
  String get continueText => '계속하기';

  @override
  String get dharmaSegment => 'Dharma';

  @override
  String get errorOccurred => '오류가 발생했습니다';

  @override
  String get feedback => '피드백';

  @override
  String get finishLesson => '수업 완료';

  @override
  String get fluency => '유창성';

  @override
  String get grammar => '문법';

  @override
  String get guidedStageTitle => '1단계: 경청과 관조';

  @override
  String get hideIpa => 'IPA 발음기호 숨기기';

  @override
  String get home => '홈';

  @override
  String get inputStageTitle => '2단계: 언어 입력';

  @override
  String get language => '언어';

  @override
  String get lessonCompleted => '수업 완료!';

  @override
  String get loading => '로딩 중...';

  @override
  String get matchWords => '3개 국어 단어 연결';

  @override
  String get meditationSegment => 'Meditation';

  @override
  String get meditationStage => '명상 단계';

  @override
  String get meditationTestTitle => '2. 명상 경험';

  @override
  String get meditator => '명상가';

  @override
  String get monkMode => '승가 모드';

  @override
  String get navigationError => '탐색 오류';

  @override
  String get nextPatternPractice => '다음: 단어 연결 →';

  @override
  String get noConversation => '이 수업에는 대화가 없습니다.';

  @override
  String get noPatterns => '구문 연습이 없습니다.';

  @override
  String get noPractice => '연습 단계가 없습니다.';

  @override
  String get outputStageTitle => '4단계: 발음 연습';

  @override
  String get pageNotFound => '페이지를 찾을 수 없습니다';

  @override
  String get paliKnowledge => '빠알리어 수준';

  @override
  String get paliSegment => 'Pāli';

  @override
  String get paliTestTitle => '3. 빠알리어 지식';

  @override
  String get patternStageTitle => '3단계: 구문 및 단어 매칭';

  @override
  String get patternViewStageTitle => '3a단계: 구문 관찰';

  @override
  String get placementResultTitle => '맞춤형 학습 경로';

  @override
  String get placementTest => '레벨 테스트';

  @override
  String get placementTestSubtitle => '영어 수준, 명상 단계 및 빠알리어 지식을 측정합니다';

  @override
  String get placementTestTitle => '초기 역량 평가';

  @override
  String get pronunciation => '발음';

  @override
  String get quickStart => '빠른 시작';

  @override
  String get retry => '다시 시도';

  @override
  String get selectLanguage => '언어 선택';

  @override
  String get settings => '설정';

  @override
  String get showIpa => 'IPA 발음기호 표시';

  @override
  String get silentMode => '묵언/정적 모드';

  @override
  String get silentModeDesc => '자동 음성을 재생하지 않습니다. 선원 및 사찰 환경에 적합합니다.';

  @override
  String get silentModeOff => '묵언 모드 꺼짐';

  @override
  String get silentModeOn => '묵언 모드 켜짐';

  @override
  String get smartSuggestion => '스마트 학습 추천';

  @override
  String get startInterview => 'AI 인터뷰 시작';

  @override
  String get startLearning => '학습 시작';

  @override
  String get suggestion => '개선 제안';

  @override
  String get systemDefault => '시스템 기본값';

  @override
  String get turnOffSilentToRecord => '녹음하려면 묵언 모드를 끄세요';

  @override
  String get venerableMonk => '스님 / 승가';

  @override
  String get viewDetails => '자세히 보기';

  @override
  String get vocabTestTitle => '1. 어휘 및 문법';

  @override
  String get vocabulary => '어휘';

  @override
  String get welcomeBack => '환영합니다';

}

/// The translations for `lo`.
class AppLocalizationsLo extends AppLocalizations {
  AppLocalizationsLo([super.localeName = 'lo']);

  @override
  String get accuracy => 'ຄວາມຖືກຕ້ອງ';

  @override
  String get aiFeedback => 'ຄໍາປະເມີນຈາກ AI';

  @override
  String get aiInterview => 'ການສໍາພາດ AI';

  @override
  String get aiInterviewDescription => 'ຝຶກຝົນພາສາອັງກິດພຣະທໍາ ແລະ ວິປັດສະນາກັບ AI';

  @override
  String get appSubtitle => 'English for Wisdom & Meditation';

  @override
  String get appTitle => 'ZENGLISH - English for Wisdom & Meditation';

  @override
  String get back => 'ກັບຄືນ';

  @override
  String get backToHome => 'ກັບຄືນໜ້າຫຼັກ';

  @override
  String get backToMain => 'ກັບໜ້າຕົ້ນ';

  @override
  String get cancel => 'ຍົກເລີກ';

  @override
  String get cefrLevel => 'ລະດັບ CEFR';

  @override
  String get complete => 'ສໍາເລັດ';

  @override
  String get confirm => 'ຢືນຢັນ';

  @override
  String get congratulations => 'ຂໍສະແດງຄວາມຍິນດີທີ່ຮຽນຈົບບົດນີ້ຢ່າງສໍາເລັດຜົນ!';

  @override
  String get continueText => 'ສືບຕໍ່';

  @override
  String get dharmaSegment => 'Dharma';

  @override
  String get errorOccurred => 'ເກີດຂໍ້ຜິດພາດ';

  @override
  String get feedback => 'ຄໍາຕອບຮັບ';

  @override
  String get finishLesson => 'ຈົບບົດຮຽນ';

  @override
  String get fluency => 'ຄວາມແຄ່ອງແຄ້ວ';

  @override
  String get grammar => 'ໄວຍາກອນ';

  @override
  String get guidedStageTitle => 'ໄລຍະ ໑: ຟັງ ແລະ ພິຈາລະນາ';

  @override
  String get hideIpa => 'ເຊື່ອງສັນຍາລັກ IPA';

  @override
  String get home => 'ໜ້າຫຼັກ';

  @override
  String get inputStageTitle => 'ໄລຍະ ໖: ຮັບຂໍ້ມູນພາສາ';

  @override
  String get language => 'ພາສາ';

  @override
  String get lessonCompleted => 'ບົດຮຽນສໍາເລັດ!';

  @override
  String get loading => 'ກໍາລັງໂຫຼດ...';

  @override
  String get matchWords => 'ການຈັບຄູ່ຄໍາສັບ ໓ ພາສາ';

  @override
  String get meditationSegment => 'Meditation';

  @override
  String get meditationStage => 'ໄລຍະການທໍາສະມາທິ';

  @override
  String get meditationTestTitle => '໖. ປະສົບການທໍາສະມາທິ';

  @override
  String get meditator => 'ຜູ້ປະຕິບັດທໍາ';

  @override
  String get monkMode => 'ໂໝດພຣະສົງ';

  @override
  String get navigationError => 'ຂໍ້ຜິດພາດໃນການນໍາທາງ';

  @override
  String get nextPatternPractice => 'ຕໍ່ໄປ: ຈັບຄູ່ຄໍາສັບ →';

  @override
  String get noConversation => 'ບໍ່ມີການສົນທະນາສໍາລັບບົດຮຽນນີ້.';

  @override
  String get noPatterns => 'ບໍ່ມີແບບຢ່າງການຝຶກ.';

  @override
  String get noPractice => 'ບໍ່ມີຂັ້ນຕອນການຝຶກ.';

  @override
  String get outputStageTitle => 'ໄລຍະ ໔: ຝຶກອອກສຽງ';

  @override
  String get pageNotFound => 'ບໍ່ພົບໜ້າ';

  @override
  String get paliKnowledge => 'ຄວາມຮູ້ປາລີ';

  @override
  String get paliSegment => 'Pāli';

  @override
  String get paliTestTitle => '໓. ຄວາມຮູ້ປາລີ';

  @override
  String get patternStageTitle => 'ໄລຍະ ໓: ໂຄງສ້າງ ແລະ ຈັບຄູ່ຄໍາສັບ';

  @override
  String get patternViewStageTitle => 'ໄລຍະ ໓a: ສັງເກດໂຄງສ້າງ';

  @override
  String get placementResultTitle => 'ເສັ້ນທາງການຮຽນຮູ້ສະເພາະທ່ານ';

  @override
  String get placementTest => 'ການທົດສອບລະດັບ';

  @override
  String get placementTestSubtitle => 'ກໍານົດລະດັບພາສາອັງກິດ, ໄລຍະການທໍາສະມາທິ ແລະ ຄວາມຮູ້ປາລີ';

  @override
  String get placementTestTitle => 'ການປະເມີນຄວາມສາມາດເບື້ອງຕົ້ນ';

  @override
  String get pronunciation => 'ການອອກສຽງ';

  @override
  String get quickStart => 'ເລີ່ມຕົ້ນໄວ';

  @override
  String get retry => 'ລອງໃໝ່';

  @override
  String get selectLanguage => 'ເລືອກພາສາ';

  @override
  String get settings => 'ການຕັ້ງຄ່າ';

  @override
  String get showIpa => 'ສະແດງສັນຍາລັກ IPA';

  @override
  String get silentMode => 'ໂໝດງຽບ';

  @override
  String get silentModeDesc => 'ບໍ່ມີສຽງອັດໂຕໂນມັດ. ເໝາະກັບສະພາບແວດລ້ອມວັດອາຣາມ.';

  @override
  String get silentModeOff => 'ໂໝດງຽບ ປິດຢູ່';

  @override
  String get silentModeOn => 'ໂໝດງຽບ ເປີດຢູ່';

  @override
  String get smartSuggestion => 'ຄໍາແນະນໍາອັດສະລິຍະ';

  @override
  String get startInterview => 'ເລີ່ມການສໍາພາດ AI';

  @override
  String get startLearning => 'ເລີ່ມຮຽນ';

  @override
  String get suggestion => 'ຄໍາແນະນໍາໃນການປັບປຸງ';

  @override
  String get systemDefault => 'ຕາມລະບົບ';

  @override
  String get turnOffSilentToRecord => 'ປິດໂໝດງຽບເພື່ອອັດສຽງ';

  @override
  String get venerableMonk => 'ພຣະສົງ / ສັງຄະ';

  @override
  String get viewDetails => 'ເບິ່ງລາຍລະອຽດ';

  @override
  String get vocabTestTitle => '໑. ຄໍາສັບ ແລະ ໄວຍາກອນ';

  @override
  String get vocabulary => 'ຄໍາສັບ';

  @override
  String get welcomeBack => 'ຍິນດີຕ້ອນຮັບ';

}

/// The translations for `mn`.
class AppLocalizationsMn extends AppLocalizations {
  AppLocalizationsMn([super.localeName = 'mn']);

  @override
  String get accuracy => 'Нарийвчлал';

  @override
  String get aiFeedback => 'AI Үнэлгээ';

  @override
  String get aiInterview => 'AI Ярилцлага';

  @override
  String get aiInterviewDescription => 'Дхарма болон Бясалгалын англи хэлийг AI-тай дадлагажуулах';

  @override
  String get appSubtitle => 'English for Wisdom & Meditation';

  @override
  String get appTitle => 'ZENGLISH - English for Wisdom & Meditation';

  @override
  String get back => 'Буцах';

  @override
  String get backToHome => 'Нүүр хуудас руу буцах';

  @override
  String get backToMain => 'Үндсэн хуудас руу буцах';

  @override
  String get cancel => 'Цуцлах';

  @override
  String get cefrLevel => 'CEFR Түвшин';

  @override
  String get complete => 'Дуусгах';

  @override
  String get confirm => 'Баталгаажуулах';

  @override
  String get congratulations => 'Энэхүү хичээлийг амжилттай дуусгасанд баяр хүргэе!';

  @override
  String get continueText => 'Үргэлжлүүлэх';

  @override
  String get dharmaSegment => 'Dharma';

  @override
  String get errorOccurred => 'Алдаа гарлаа';

  @override
  String get feedback => 'Сэтгэгдэл';

  @override
  String get finishLesson => 'Хичээл дуусгах';

  @override
  String get fluency => 'Төрөлхийн мэт яриа';

  @override
  String get grammar => 'Хэлний дүрэм';

  @override
  String get guidedStageTitle => '1-р шат: Сонсох ба Эргэцүүлэх';

  @override
  String get hideIpa => 'IPA дуудлагын тэмдэглэгээг нуух';

  @override
  String get home => 'Нүүр';

  @override
  String get inputStageTitle => '2-р шат: Хэлний оруулалт';

  @override
  String get language => 'Хэл';

  @override
  String get lessonCompleted => 'Хичээл дууслаа!';

  @override
  String get loading => 'Ачаалж байна...';

  @override
  String get matchWords => 'Гурван хэлний үг холбох';

  @override
  String get meditationSegment => 'Meditation';

  @override
  String get meditationStage => 'Бясалгалын үе шат';

  @override
  String get meditationTestTitle => '2. Бясалгалын туршлага';

  @override
  String get meditator => 'Бясалгалч';

  @override
  String get monkMode => 'Хуврагийн горим';

  @override
  String get navigationError => 'Навигацийн алдаа';

  @override
  String get nextPatternPractice => 'Дараах: Үг холбох →';

  @override
  String get noConversation => 'Энэ хичээлд харилцан яриа байхгүй байна.';

  @override
  String get noPatterns => 'Загвар дадлага байхгүй байна.';

  @override
  String get noPractice => 'Дадлага хийх алхам байхгүй байна.';

  @override
  String get outputStageTitle => '4-р шат: Дуудлагын дадлага';

  @override
  String get pageNotFound => 'Хуудас олдсонгүй';

  @override
  String get paliKnowledge => 'Пали хэлний мэдлэг';

  @override
  String get paliSegment => 'Pāli';

  @override
  String get paliTestTitle => '3. Пали хэлний мэдлэг';

  @override
  String get patternStageTitle => '3-р шат: Бүтэц ба Үг холбох';

  @override
  String get patternViewStageTitle => '3a-р шат: Бүтцийг ажиглах';

  @override
  String get placementResultTitle => 'Танд зориулсан суралцах замнал';

  @override
  String get placementTest => 'Түвшин тогтоох тест';

  @override
  String get placementTestSubtitle => 'Англи хэлний түвшин, бясалгалын үе шат ба Пали хэлний мэдлэгийг тодорхойлох';

  @override
  String get placementTestTitle => 'Анхны чадварын үнэлгээ';

  @override
  String get pronunciation => 'Дуудлага';

  @override
  String get quickStart => 'Түргэн эхлэх';

  @override
  String get retry => 'Дахин оролдох';

  @override
  String get selectLanguage => 'Хэл сонгох';

  @override
  String get settings => 'Тохиргоо';

  @override
  String get showIpa => 'IPA дуудлагын тэмдэглэгээг харуулах';

  @override
  String get silentMode => 'Аниргүй горим';

  @override
  String get silentModeDesc => 'Автомат аудио тоглуулахгүй. Хүрээ хийдийн орчинд тохиромжтой.';

  @override
  String get silentModeOff => 'Аниргүй горим ИДЭВХГҮЙ';

  @override
  String get silentModeOn => 'Аниргүй горим ИДЭВХЖСЭН';

  @override
  String get smartSuggestion => 'Ухаалаг зөвлөмж';

  @override
  String get startInterview => 'AI ярилцлага эхлүүлэх';

  @override
  String get startLearning => 'Суралцаж эхлэх';

  @override
  String get suggestion => 'Сайжруулах зөвлөмж';

  @override
  String get systemDefault => 'Системийн үндсэн';

  @override
  String get turnOffSilentToRecord => 'Дуу бичихийн тулд аниргүй горимыг унтраана уу';

  @override
  String get venerableMonk => 'Хүндэт хувраг / Хуврагийн баг';

  @override
  String get viewDetails => 'Дэлгэрэнгүй үзэх';

  @override
  String get vocabTestTitle => '1. Үгийн сан ба Дүрэм';

  @override
  String get vocabulary => 'Үгийн сан';

  @override
  String get welcomeBack => 'Тавтай морилно уу';

}

/// The translations for `mr`.
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([super.localeName = 'mr']);

  @override
  String get accuracy => 'अचूकता';

  @override
  String get aiFeedback => 'AI मूल्यमापन';

  @override
  String get aiInterview => 'AI मुलाखत';

  @override
  String get aiInterviewDescription => 'AI सोबत धम्म आणि ध्यान इंग्रजीचा सराव करा';

  @override
  String get appSubtitle => 'English for Wisdom & Meditation';

  @override
  String get appTitle => 'ZENGLISH - English for Wisdom & Meditation';

  @override
  String get back => 'मागे';

  @override
  String get backToHome => 'मुख्य पृष्ठावर जा';

  @override
  String get backToMain => 'मुख्य पानावर जा';

  @override
  String get cancel => 'रद्द करा';

  @override
  String get cefrLevel => 'CEFR स्तर';

  @override
  String get complete => 'पूर्ण';

  @override
  String get confirm => 'निश्चित करा';

  @override
  String get congratulations => 'हा पाठ यशस्वीरित्या पूर्ण केल्याबद्दल अभिनंदन!';

  @override
  String get continueText => 'पुढे जा';

  @override
  String get dharmaSegment => 'Dharma';

  @override
  String get errorOccurred => 'त्रुटी आली';

  @override
  String get feedback => 'प्रतिक्रिया';

  @override
  String get finishLesson => 'पाठ पूर्ण करा';

  @override
  String get fluency => 'प्रवाह';

  @override
  String get grammar => 'व्याकरण';

  @override
  String get guidedStageTitle => 'टप्पा १: ऐका आणि चिंतन करा';

  @override
  String get hideIpa => 'IPA लपवा';

  @override
  String get home => 'होम';

  @override
  String get inputStageTitle => 'टप्पा २: भाषा इनपुट';

  @override
  String get language => 'भाषा';

  @override
  String get lessonCompleted => 'पाठ पूर्ण झाला!';

  @override
  String get loading => 'लोड होत आहे...';

  @override
  String get matchWords => 'त्रिभाषिक शब्द जुळणी';

  @override
  String get meditationSegment => 'Meditation';

  @override
  String get meditationStage => 'ध्यानाचा टप्पा';

  @override
  String get meditationTestTitle => '२. ध्यानाचा अनुभव';

  @override
  String get meditator => 'ध्यानसाधक';

  @override
  String get monkMode => 'भिक्षू मोड';

  @override
  String get navigationError => 'नेव्हिगेशन त्रुटी';

  @override
  String get nextPatternPractice => 'पुढील: शब्द जुळणी →';

  @override
  String get noConversation => 'या पाठासाठी संभाषण उपलब्ध नाही.';

  @override
  String get noPatterns => 'अभ्यास रचना उपलब्ध नाही.';

  @override
  String get noPractice => 'अभ्यास पायऱ्या उपलब्ध नाहीत.';

  @override
  String get outputStageTitle => 'टप्पा ४: उच्चारण सराव';

  @override
  String get pageNotFound => 'पृष्ठ सापडले नाही';

  @override
  String get paliKnowledge => 'पाली ज्ञान';

  @override
  String get paliSegment => 'Pāli';

  @override
  String get paliTestTitle => '३. पाली ज्ञान';

  @override
  String get patternStageTitle => 'टप्पा ३: रचना आणि शब्द जुळणी';

  @override
  String get patternViewStageTitle => 'टप्पा ३a: रचना पहा';

  @override
  String get placementResultTitle => 'तुमचा सानुकूलित शिकण्याचा मार्ग';

  @override
  String get placementTest => 'स्तर चाचणी';

  @override
  String get placementTestSubtitle => 'इंग्रजी स्तर, ध्यान टप्पा आणि पाली ज्ञान निश्चित करा';

  @override
  String get placementTestTitle => 'प्रारंभिक क्षमता मूल्यमापन';

  @override
  String get pronunciation => 'उच्चार';

  @override
  String get quickStart => 'जलद सुरुवात';

  @override
  String get retry => 'पुन्हा प्रयत्न करा';

  @override
  String get selectLanguage => 'भाषा निवडा';

  @override
  String get settings => 'सेटिंग्ज';

  @override
  String get showIpa => 'IPA दाखवा';

  @override
  String get silentMode => 'शांत मोड';

  @override
  String get silentModeDesc => 'स्वयंचलित ऑडिओ नाही. विहार वातावरणासाठी योग्य.';

  @override
  String get silentModeOff => 'शांत मोड बंद आहे';

  @override
  String get silentModeOn => 'शांत मोड चालू आहे';

  @override
  String get smartSuggestion => 'स्मार्ट सल्ला';

  @override
  String get startInterview => 'AI मुलाखत सुरू करा';

  @override
  String get startLearning => 'शिकणे सुरू करा';

  @override
  String get suggestion => 'सुधारणेचा सल्ला';

  @override
  String get systemDefault => 'सिस्टम डीफॉल्ट';

  @override
  String get turnOffSilentToRecord => 'रेकॉर्ड करण्यासाठी शांत मोड बंद करा';

  @override
  String get venerableMonk => 'पूज्य भिक्षू / संघ';

  @override
  String get viewDetails => 'तपशील पहा';

  @override
  String get vocabTestTitle => '१. शब्दसंग्रह आणि व्याकरण';

  @override
  String get vocabulary => 'शब्दसंग्रह';

  @override
  String get welcomeBack => 'स्वागत आहे';

}

/// The translations for `my`.
class AppLocalizationsMy extends AppLocalizations {
  AppLocalizationsMy([super.localeName = 'my']);

  @override
  String get accuracy => 'မှန်ကန်မှု';

  @override
  String get aiFeedback => 'AI သုံးသပ်ချက်';

  @override
  String get aiInterview => 'AI အင်တာဗျူး';

  @override
  String get aiInterviewDescription => 'AI ဖြင့် တရားဓမ္မနှင့် ကမ္မဋ္ဌာန်း အင်္ဂလိပ်စာ လေ့ကျင့်ပါ';

  @override
  String get appSubtitle => 'English for Wisdom & Meditation';

  @override
  String get appTitle => 'ZENGLISH - English for Wisdom & Meditation';

  @override
  String get back => 'နောက်သို့';

  @override
  String get backToHome => 'ပင်မစာမျက်နှာသို့';

  @override
  String get backToMain => 'အဓိကစာမျက်နှာသို့';

  @override
  String get cancel => 'ပယ်ဖျက်ပါ';

  @override
  String get cefrLevel => 'CEFR အဆင့်';

  @override
  String get complete => 'ပြီးဆုံးပါပြီ';

  @override
  String get confirm => 'အတည်ပြုပါ';

  @override
  String get congratulations => 'ဤသင်ခန်းစာကို အောင်မြင်စွာ ပြီးမြောက်သည့်အတွက် ဂုဏ်ယူပါသည်။';

  @override
  String get continueText => 'ဆက်လက်လုပ်ဆောင်ရန်';

  @override
  String get dharmaSegment => 'Dharma';

  @override
  String get errorOccurred => 'အမှားတစ်ခု ဖြစ်ပွားခဲ့သည်';

  @override
  String get feedback => 'အကြံပြုချက်';

  @override
  String get finishLesson => 'သင်ခန်းစာ ပြီးဆုံးရန်';

  @override
  String get fluency => 'ကျွမ်းကျင်မှု';

  @override
  String get grammar => 'သဒ္ဒါ';

  @override
  String get guidedStageTitle => 'အဆင့် ၁- နားထောင်ပြီး ဆင်ခြင်ပါ';

  @override
  String get hideIpa => 'IPA အသံထွက် ဝှက်ထားပါ';

  @override
  String get home => 'ပင်မစာမျက်နှာ';

  @override
  String get inputStageTitle => 'အဆင့် ၂- ဘာသာစကား လေ့လာပါ';

  @override
  String get language => 'ဘာသာစကား';

  @override
  String get lessonCompleted => 'သင်ခန်းစာ ပြီးဆုံးပါပြီ။';

  @override
  String get loading => 'ရယူနေသည်...';

  @override
  String get matchWords => 'သုံးဘာသာ စကားလုံး တွဲစပ်ခြင်း';

  @override
  String get meditationSegment => 'Meditation';

  @override
  String get meditationStage => 'တရားအားထုတ်မှု အဆင့်';

  @override
  String get meditationTestTitle => '၂။ တရားအားထုတ်မှု အတွေ့အကြုံ';

  @override
  String get meditator => 'တရားအားထုတ်သူ';

  @override
  String get monkMode => 'သံဃာတော် မုဒ်';

  @override
  String get navigationError => 'လမ်းညွှန်မှု အမှား';

  @override
  String get nextPatternPractice => 'နောက်သို့- စကားလုံး တွဲစပ်ခြင်း →';

  @override
  String get noConversation => 'ဤသင်ခန်းစာအတွက် စကားပြော မရှိသေးပါ။';

  @override
  String get noPatterns => 'ပုံစံ လေ့ကျင့်ခန်း မရှိသေးပါ။';

  @override
  String get noPractice => 'လေ့ကျင့်ခန်း အဆင့်များ မရှိသေးပါ။';

  @override
  String get outputStageTitle => 'အဆင့် ၄- အသံထွက် လေ့ကျင့်ပါ';

  @override
  String get pageNotFound => 'စာမျက်နှာ မတွေ့ပါ';

  @override
  String get paliKnowledge => 'ပါဠိဗဟုသုတ';

  @override
  String get paliSegment => 'Pāli';

  @override
  String get paliTestTitle => '၃။ ပါဠိဗဟုသုတ';

  @override
  String get patternStageTitle => 'အဆင့် ၃- ဝါကျဖွဲ့စည်းပုံနှင့် စကားလုံးတွဲစပ်ပါ';

  @override
  String get patternViewStageTitle => 'အဆင့် ၃က- ဖွဲ့စည်းပုံကို လေ့လာပါ';

  @override
  String get placementResultTitle => 'သင့်အတွက် သီးသန့် သင်ယူမှုလမ်းကြောင်း';

  @override
  String get placementTest => 'အဆင့်စစ်ဆေးမှု';

  @override
  String get placementTestSubtitle => 'အင်္ဂလိပ်စာအဆင့်၊ တရားအားထုတ်မှုအဆင့်နှင့် ပါဠိဗဟုသုတကို သတ်မှတ်ပါ';

  @override
  String get placementTestTitle => 'စတင်စွမ်းရည် အကဲဖြတ်မှု';

  @override
  String get pronunciation => 'အသံထွက်';

  @override
  String get quickStart => 'အမြန်စတင်ရန်';

  @override
  String get retry => 'ပြန်လည်ကြိုးစားပါ';

  @override
  String get selectLanguage => 'ဘာသာစကား ရွေးချယ်ပါ';

  @override
  String get settings => 'ဆက်တင်များ';

  @override
  String get showIpa => 'IPA အသံထွက် ပြသပါ';

  @override
  String get silentMode => 'တိတ်ဆိတ်မုဒ်';

  @override
  String get silentModeDesc => 'အလိုအလျောက် အသံမထွက်ပါ။ ကျောင်းတိုက်/ရိပ်သာဝန်းကျင်နှင့် သင့်တော်သည်။';

  @override
  String get silentModeOff => 'တိတ်ဆိတ်မုဒ် ပိတ်ထားသည်';

  @override
  String get silentModeOn => 'တိတ်ဆိတ်မုဒ် ဖွင့်ထားသည်';

  @override
  String get smartSuggestion => 'ဉာဏ်ရည်ထက်မြက်သော အကြံပြုချက်';

  @override
  String get startInterview => 'AI အင်တာဗျူး စတင်ရန်';

  @override
  String get startLearning => 'သင်ယူမှု စတင်ရန်';

  @override
  String get suggestion => 'ပြုပြင်ရန် အကြံပြုချက်';

  @override
  String get systemDefault => 'စနစ်မူလအတိုင်း';

  @override
  String get turnOffSilentToRecord => 'အသံသွင်းရန် တိတ်ဆိတ်မုဒ်ကို ပိတ်ပါ';

  @override
  String get venerableMonk => 'ဆရာတော် / သံဃာတော်';

  @override
  String get viewDetails => 'အသေးစိတ်ကြည့်ရန်';

  @override
  String get vocabTestTitle => '၁။ ဝေါဟာရနှင့် သဒ္ဒါ';

  @override
  String get vocabulary => 'ဝေါဟာရ';

  @override
  String get welcomeBack => 'ကြိုဆိုပါသည်';

}

/// The translations for `pt`.
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([super.localeName = 'pt']);

  @override
  String get accuracy => 'Precisão';

  @override
  String get aiFeedback => 'Avaliação da IA';

  @override
  String get aiInterview => 'Entrevista de IA';

  @override
  String get aiInterviewDescription => 'Pratique inglês do Dharma e meditação com IA';

  @override
  String get appSubtitle => 'Inglês para Sabedoria e Meditação';

  @override
  String get appTitle => 'ZENGLISH - Inglês para Sabedoria e Meditação';

  @override
  String get back => 'Voltar';

  @override
  String get backToHome => 'Voltar ao Início';

  @override
  String get backToMain => 'Voltar à Página Principal';

  @override
  String get cancel => 'Cancelar';

  @override
  String get cefrLevel => 'Nível CEFR';

  @override
  String get complete => 'Concluir';

  @override
  String get confirm => 'Confirmar';

  @override
  String get congratulations => 'Parabéns por concluir esta lição com sucesso!';

  @override
  String get continueText => 'Continuar';

  @override
  String get dharmaSegment => 'Dharma';

  @override
  String get errorOccurred => 'Ocorreu um erro';

  @override
  String get feedback => 'Avaliação';

  @override
  String get finishLesson => 'Concluir Lição';

  @override
  String get fluency => 'Fluidez';

  @override
  String get grammar => 'Gramática';

  @override
  String get guidedStageTitle => 'Etapa 1: Ouvir e Refletir';

  @override
  String get hideIpa => 'Ocultar Notação IPA';

  @override
  String get home => 'Início';

  @override
  String get inputStageTitle => 'Etapa 2: Entrada de Linguagem';

  @override
  String get language => 'Idioma';

  @override
  String get lessonCompleted => 'Lição Concluída!';

  @override
  String get loading => 'Carregando...';

  @override
  String get matchWords => 'Associação de palavras trilíngue';

  @override
  String get meditationSegment => 'Meditation';

  @override
  String get meditationStage => 'Estágio de Meditação';

  @override
  String get meditationTestTitle => '2. Experiência de Meditação';

  @override
  String get meditator => 'Meditador';

  @override
  String get monkMode => 'Modo Monge';

  @override
  String get navigationError => 'Erro de Navegação';

  @override
  String get nextPatternPractice => 'Próximo: Associar Palavras →';

  @override
  String get noConversation => 'Nenhuma conversa disponível para esta lição.';

  @override
  String get noPatterns => 'Sem exercícios de estrutura.';

  @override
  String get noPractice => 'Sem etapas de prática.';

  @override
  String get outputStageTitle => 'Etapa 4: Prática de Pronúncia';

  @override
  String get pageNotFound => 'Página não encontrada';

  @override
  String get paliKnowledge => 'Conhecimento de Pāli';

  @override
  String get paliSegment => 'Pāli';

  @override
  String get paliTestTitle => '3. Conhecimento de Pāli';

  @override
  String get patternStageTitle => 'Etapa 3: Estrutura e Associação de Palavras';

  @override
  String get patternViewStageTitle => 'Etapa 3a: Observar Estrutura';

  @override
  String get placementResultTitle => 'Seu Caminho de Aprendizado Personalizado';

  @override
  String get placementTest => 'Teste de Nível';

  @override
  String get placementTestSubtitle => 'Determine nível de inglês, estágio de meditação e conhecimentos de Pāli';

  @override
  String get placementTestTitle => 'Avaliação Inicial de Competências';

  @override
  String get pronunciation => 'Pronúncia';

  @override
  String get quickStart => 'Início Rápido';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get selectLanguage => 'Selecionar Idioma';

  @override
  String get settings => 'Configurações';

  @override
  String get showIpa => 'Mostrar Notação IPA';

  @override
  String get silentMode => 'Modo Silencioso';

  @override
  String get silentModeDesc => 'Sem reprodução automática de áudio. Adequado para ambiente monástico.';

  @override
  String get silentModeOff => 'Modo Silencioso DESLIGADO';

  @override
  String get silentModeOn => 'Modo Silencioso LIGADO';

  @override
  String get smartSuggestion => 'Sugestão Inteligente';

  @override
  String get startInterview => 'Iniciar Entrevista de IA';

  @override
  String get startLearning => 'Começar a Aprender';

  @override
  String get suggestion => 'Sugestão de Melhoria';

  @override
  String get systemDefault => 'Padrão do Sistema';

  @override
  String get turnOffSilentToRecord => 'Desligue o modo silencioso para gravar';

  @override
  String get venerableMonk => 'Venerável Monge / Sangha';

  @override
  String get viewDetails => 'Ver Detalhes';

  @override
  String get vocabTestTitle => '1. Vocabulário e Gramática';

  @override
  String get vocabulary => 'Vocabulário';

  @override
  String get welcomeBack => 'Bem-vindo';

}

/// The translations for `ru`.
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([super.localeName = 'ru']);

  @override
  String get accuracy => 'Точность';

  @override
  String get aiFeedback => 'Оценка ИИ';

  @override
  String get aiInterview => 'ИИ Интервью';

  @override
  String get aiInterviewDescription => 'Практикуйте английский язык Дхармы и медитации с ИИ';

  @override
  String get appSubtitle => 'Английский для Мудрости и Медитации';

  @override
  String get appTitle => 'ZENGLISH - Английский для Мудрости и Медитации';

  @override
  String get back => 'Назад';

  @override
  String get backToHome => 'На главную';

  @override
  String get backToMain => 'На главную страницу';

  @override
  String get cancel => 'Отмена';

  @override
  String get cefrLevel => 'Уровень CEFR';

  @override
  String get complete => 'Завершить';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get congratulations => 'Поздравляем с успешным завершением урока!';

  @override
  String get continueText => 'Продолжить';

  @override
  String get dharmaSegment => 'Dharma';

  @override
  String get errorOccurred => 'Произошла ошибка';

  @override
  String get feedback => 'Отзыв';

  @override
  String get finishLesson => 'Завершить урок';

  @override
  String get fluency => 'Беглость';

  @override
  String get grammar => 'Грамматика';

  @override
  String get guidedStageTitle => 'Этап 1: Слушание и размышление';

  @override
  String get hideIpa => 'Скрыть транскрипцию IPA';

  @override
  String get home => 'Главная';

  @override
  String get inputStageTitle => 'Этап 2: Восприятие языка';

  @override
  String get language => 'Язык';

  @override
  String get lessonCompleted => 'Урок завершен!';

  @override
  String get loading => 'Загрузка...';

  @override
  String get matchWords => 'Трехязычное сопоставление слов';

  @override
  String get meditationSegment => 'Meditation';

  @override
  String get meditationStage => 'Этап медитации';

  @override
  String get meditationTestTitle => '2. Опыт медитации';

  @override
  String get meditator => 'Практикующий медитацию';

  @override
  String get monkMode => 'Режим Монаха';

  @override
  String get navigationError => 'Ошибка навигации';

  @override
  String get nextPatternPractice => 'Далее: Сопоставление слов →';

  @override
  String get noConversation => 'Для этого урока нет диалогов.';

  @override
  String get noPatterns => 'Упражнения на конструкции отсутствуют.';

  @override
  String get noPractice => 'Практические шаги отсутствуют.';

  @override
  String get outputStageTitle => 'Этап 4: Практика произношения';

  @override
  String get pageNotFound => 'Страница не найдена';

  @override
  String get paliKnowledge => 'Уровень Пали';

  @override
  String get paliSegment => 'Pāli';

  @override
  String get paliTestTitle => '3. Знание Пали';

  @override
  String get patternStageTitle => 'Этап 3: Структура и сопоставление слов';

  @override
  String get patternViewStageTitle => 'Этап 3a: Наблюдение структуры';

  @override
  String get placementResultTitle => 'Ваш персональный план обучения';

  @override
  String get placementTest => 'Тест на уровень';

  @override
  String get placementTestSubtitle => 'Определите уровень английского, этап медитации и знания Пали';

  @override
  String get placementTestTitle => 'Первичная оценка навыков';

  @override
  String get pronunciation => 'Произношение';

  @override
  String get quickStart => 'Быстрый старт';

  @override
  String get retry => 'Повторить';

  @override
  String get selectLanguage => 'Выберите язык';

  @override
  String get settings => 'Настройки';

  @override
  String get showIpa => 'Показать транскрипцию IPA';

  @override
  String get silentMode => 'Беззвучный режим';

  @override
  String get silentModeDesc => 'Без автовоспроизведения звука. Подходит для монастырской среды.';

  @override
  String get silentModeOff => 'Беззвучный режим ВЫКЛ';

  @override
  String get silentModeOn => 'Беззвучный режим ВКЛ';

  @override
  String get smartSuggestion => 'Умная рекомендация';

  @override
  String get startInterview => 'Начать ИИ интервью';

  @override
  String get startLearning => 'Начать обучение';

  @override
  String get suggestion => 'Рекомендация по улучшению';

  @override
  String get systemDefault => 'По умолчанию';

  @override
  String get turnOffSilentToRecord => 'Отключите беззвучный режим для записи';

  @override
  String get venerableMonk => 'Досточтимый Монах / Сангха';

  @override
  String get viewDetails => 'Подробнее';

  @override
  String get vocabTestTitle => '1. Словарный запас и грамматика';

  @override
  String get vocabulary => 'Словарный запас';

  @override
  String get welcomeBack => 'Добро пожаловать';

}

/// The translations for `si`.
class AppLocalizationsSi extends AppLocalizations {
  AppLocalizationsSi([super.localeName = 'si']);

  @override
  String get accuracy => 'නිවැරදිබව';

  @override
  String get aiFeedback => 'AI ප්‍රතිචාර';

  @override
  String get aiInterview => 'AI සම්මුඛ සාකච්ඡාව';

  @override
  String get aiInterviewDescription => 'AI සමඟ ධර්ම සහ භාවනා ඉංග්‍රීසි පුහුණු වන්න';

  @override
  String get appSubtitle => 'English for Wisdom & Meditation';

  @override
  String get appTitle => 'ZENGLISH - English for Wisdom & Meditation';

  @override
  String get back => 'ආපසු';

  @override
  String get backToHome => 'මුල් පිටුවට';

  @override
  String get backToMain => 'ප්‍රධාන පිටුවට';

  @override
  String get cancel => 'අවසාන කරන්න';

  @override
  String get cefrLevel => 'CEFR මට්ටම';

  @override
  String get complete => 'සම්පූර්ණයි';

  @override
  String get confirm => 'තහවුරු කරන්න';

  @override
  String get congratulations => 'මෙම පාඩම සාර්ථකව අවසන් කිරීම ගැන සුභ පැතුම්!';

  @override
  String get continueText => 'ඉදිරියට';

  @override
  String get dharmaSegment => 'Dharma';

  @override
  String get errorOccurred => 'දෝෂයක් සිදු විය';

  @override
  String get feedback => 'ප්‍රතිචාර';

  @override
  String get finishLesson => 'පාඩම අවසන් කරන්න';

  @override
  String get fluency => 'ප්‍රවාහය';

  @override
  String get grammar => 'ව්‍යාකරණ';

  @override
  String get guidedStageTitle => 'අදියර 1: ශ්‍රවණය සහ අවබෝධය';

  @override
  String get hideIpa => 'IPA ශබ්ද සංකේත සඟවන්න';

  @override
  String get home => 'මුල් පිටුව';

  @override
  String get inputStageTitle => 'අදියර 2: භාෂා ඇතුළත් කිරීම';

  @override
  String get language => 'භාෂාව';

  @override
  String get lessonCompleted => 'පාඩම සම්පූර්ණයි!';

  @override
  String get loading => 'පූරණය වෙමින්...';

  @override
  String get matchWords => 'තෙභාෂා වචන ගැලපීම';

  @override
  String get meditationSegment => 'Meditation';

  @override
  String get meditationStage => 'භාවනා අදියර';

  @override
  String get meditationTestTitle => '2. භාවනා අත්දැකීම්';

  @override
  String get meditator => 'භාවනානුයෝගී';

  @override
  String get monkMode => 'සංඝ මාදිලිය';

  @override
  String get navigationError => 'සංචාලන දෝෂයකි';

  @override
  String get nextPatternPractice => 'ඊළඟ: වචන ගැලපීම →';

  @override
  String get noConversation => 'මෙම පාඩම සඳහා සංවාද නොමැත.';

  @override
  String get noPatterns => 'රූප රටා පුහුණුව නොමැත.';

  @override
  String get noPractice => 'පුහුණු පියවර නොමැත.';

  @override
  String get outputStageTitle => 'අදියර 4: උච්චාරණ පුහුණුව';

  @override
  String get pageNotFound => 'පිටුව හමු නොවීය';

  @override
  String get paliKnowledge => 'පාලි දැනුම';

  @override
  String get paliSegment => 'Pāli';

  @override
  String get paliTestTitle => '3. පාලි දැනුම';

  @override
  String get patternStageTitle => 'අදියර 3: ව්‍යුහය සහ වචන ගැලපීම';

  @override
  String get patternViewStageTitle => 'අදියර 3a: ව්‍යුහය නිරීක්ෂණය';

  @override
  String get placementResultTitle => 'ඔබට ගැලපෙන ඉගෙනුම් මඟ';

  @override
  String get placementTest => 'මට්ටම් පරීක්ෂණය';

  @override
  String get placementTestSubtitle => 'ඉංග්‍රීසි, භාවනා සහ පාලි දැනුම මට්ටම තීරණය කරන්න';

  @override
  String get placementTestTitle => 'ආරම්භක පරීක්ෂණය';

  @override
  String get pronunciation => 'උච්චාරණය';

  @override
  String get quickStart => 'ඉක්මන් ආරම්භය';

  @override
  String get retry => 'නැවත උත්සාහ කරන්න';

  @override
  String get selectLanguage => 'භාෂාව තෝරන්න';

  @override
  String get settings => 'සැකසුම්';

  @override
  String get showIpa => 'IPA ශබ්ද සංකේත පෙන්වන්න';

  @override
  String get silentMode => 'නිශ්ශබ්ද මාදිලිය';

  @override
  String get silentModeDesc => 'ස්වයංක්‍රීය ශ්‍රව්‍ය නැත. ආරණ්‍ය සේනාසන සඳහා සුදුසුයි.';

  @override
  String get silentModeOff => 'නිශ්ශබ්ද මාදිලිය අක්‍රියයි';

  @override
  String get silentModeOn => 'නිශ්ශබ්ද මාදිලිය ක්‍රියාත්මකයි';

  @override
  String get smartSuggestion => 'බුද්ධිමත් උපදෙස්';

  @override
  String get startInterview => 'AI සාකච්ඡාව ආරම්භ කරන්න';

  @override
  String get startLearning => 'ඉගෙනීම ආරම්භ කරන්න';

  @override
  String get suggestion => 'වැඩිදියුණු කිරීමේ යෝජනා';

  @override
  String get systemDefault => 'පද්ධතිමය මුල් සැකසුම';

  @override
  String get turnOffSilentToRecord => 'හඬ පටිගත කිරීමට නිශ්ශබ්ද මාදිලිය අක්‍රිය කරන්න';

  @override
  String get venerableMonk => 'ගරු සංඝරත්නය';

  @override
  String get viewDetails => 'විස්තර බලන්න';

  @override
  String get vocabTestTitle => '1. වචන මාලාව සහ ව්‍යාකරණ';

  @override
  String get vocabulary => 'වචන මාලාව';

  @override
  String get welcomeBack => 'සාදරයෙන් පිළිගනිමු';

}

/// The translations for `ta`.
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([super.localeName = 'ta']);

  @override
  String get accuracy => 'துல்லியம்';

  @override
  String get aiFeedback => 'AI மதிப்பீடு';

  @override
  String get aiInterview => 'AI நேர்காணல்';

  @override
  String get aiInterviewDescription => 'AI உடன் தர்மம் மற்றும் தியான ஆங்கிலத்தைப் பயிற்சி செய்யுங்கள்';

  @override
  String get appSubtitle => 'English for Wisdom & Meditation';

  @override
  String get appTitle => 'ZENGLISH - English for Wisdom & Meditation';

  @override
  String get back => 'பின்செல்';

  @override
  String get backToHome => 'முகப்பிற்குச் செல்';

  @override
  String get backToMain => 'முதன்மைப் பக்கத்திற்குச் செல்';

  @override
  String get cancel => 'ரத்து செய்';

  @override
  String get cefrLevel => 'CEFR நிலை';

  @override
  String get complete => 'நிறைவு';

  @override
  String get confirm => 'உறுதிப்படுத்து';

  @override
  String get congratulations => 'இந்தப் பாடத்தை வெற்றிகரமாக முடித்ததற்கு வாழ்த்துகள்!';

  @override
  String get continueText => 'தொடரவும்';

  @override
  String get dharmaSegment => 'Dharma';

  @override
  String get errorOccurred => 'ஒரு பிழை ஏற்பட்டது';

  @override
  String get feedback => 'கருத்துரைகள்';

  @override
  String get finishLesson => 'பாடம் முடிக்கவும்';

  @override
  String get fluency => 'சொல்லாற்றல்';

  @override
  String get grammar => 'இலக்கணம்';

  @override
  String get guidedStageTitle => 'நிலை 1: கவனியுங்கள் & சிந்தியுங்கள்';

  @override
  String get hideIpa => 'IPA குறியீட்டை மறை';

  @override
  String get home => 'முகப்பு';

  @override
  String get inputStageTitle => 'நிலை 2: மொழி உள்ளீடு';

  @override
  String get language => 'மொழி';

  @override
  String get lessonCompleted => 'பாடம் முடிந்தது!';

  @override
  String get loading => 'ஏற்றப்படுகிறது...';

  @override
  String get matchWords => 'மும்மொழி சொல் பொருத்தம்';

  @override
  String get meditationSegment => 'Meditation';

  @override
  String get meditationStage => 'தியான நிலை';

  @override
  String get meditationTestTitle => '2. தியான அனுபவம்';

  @override
  String get meditator => 'தியான சாதகர்';

  @override
  String get monkMode => 'துறவி பயன்முறை';

  @override
  String get navigationError => 'வழிசெலுத்தல் பிழை';

  @override
  String get nextPatternPractice => 'அடுத்து: சொல் பொருத்தம் →';

  @override
  String get noConversation => 'இந்தப் பாடத்திற்கு உரையாடல் எதுவும் இல்லை.';

  @override
  String get noPatterns => 'மாதிரிப் பயிற்சிகள் எதுவும் இல்லை.';

  @override
  String get noPractice => 'பயிற்சிப் படிகள் எதுவும் இல்லை.';

  @override
  String get outputStageTitle => 'நிலை 4: உச்சரிப்பு பயிற்சி';

  @override
  String get pageNotFound => 'பக்கம் காணப்படவில்லை';

  @override
  String get paliKnowledge => 'பாளி அறிவு';

  @override
  String get paliSegment => 'Pāli';

  @override
  String get paliTestTitle => '3. பாளி அறிவு';

  @override
  String get patternStageTitle => 'நிலை 3: அமைப்பு & சொல் பொருத்தம்';

  @override
  String get patternViewStageTitle => 'நிலை 3a: அமைப்பைக் கவனியுங்கள்';

  @override
  String get placementResultTitle => 'உங்களுக்கான தனிப்பயனாக்கப்பட்ட கற்றல் பாதை';

  @override
  String get placementTest => 'தகுதித் தேர்வு';

  @override
  String get placementTestSubtitle => 'ஆங்கில நிலை, தியான நிலை மற்றும் பாளி அறிவை நிர்ணயிக்கவும்';

  @override
  String get placementTestTitle => 'ஆரம்ப திறன் மதிப்பீடு';

  @override
  String get pronunciation => 'உச்சரிப்பு';

  @override
  String get quickStart => 'விரைவுத் தொடக்கம்';

  @override
  String get retry => 'மீண்டும் முயற்சிக்கவும்';

  @override
  String get selectLanguage => 'மொழியைத் தேர்ந்தெடுக்கவும்';

  @override
  String get settings => 'அமைப்புகள்';

  @override
  String get showIpa => 'IPA குறியீட்டைக் காட்டு';

  @override
  String get silentMode => 'அமைதி பயன்முறை';

  @override
  String get silentModeDesc => 'தானியங்கி ஒலி கிடையாது. ஆசிரம சூழலுக்கு ஏற்றது.';

  @override
  String get silentModeOff => 'அமைதி பயன்முறை முடங்கியுள்ளது';

  @override
  String get silentModeOn => 'அமைதி பயன்முறை இயங்குகிறது';

  @override
  String get smartSuggestion => 'புத்திசாலித்தனமான பரிந்துரை';

  @override
  String get startInterview => 'AI நேர்காணலைத் தொடங்கு';

  @override
  String get startLearning => 'கற்றலைத் தொடங்கு';

  @override
  String get suggestion => 'மேம்பாட்டுப் பரிந்துரை';

  @override
  String get systemDefault => 'அமைப்பின் இயல்புநிலை';

  @override
  String get turnOffSilentToRecord => 'பதிவு செய்ய அமைதி பயன்முறையை முடக்கவும்';

  @override
  String get venerableMonk => 'வணக்கத்திற்குரிய துறவி / சங்கம்';

  @override
  String get viewDetails => 'விவரங்களைக் காண்க';

  @override
  String get vocabTestTitle => '1. சொல்வளம் & இலக்கணம்';

  @override
  String get vocabulary => 'சொல்வளம்';

  @override
  String get welcomeBack => 'நல்வரவு';

}

/// The translations for `te`.
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([super.localeName = 'te']);

  @override
  String get accuracy => 'ఖచ్చితత్వం';

  @override
  String get aiFeedback => 'AI మూల్యాంకనం';

  @override
  String get aiInterview => 'AI ఇంటర్వ్యూ';

  @override
  String get aiInterviewDescription => 'AI తో ధర్మం మరియు ధ్యాన ఇంగ్లీష్ సాధన చేయండి';

  @override
  String get appSubtitle => 'English for Wisdom & Meditation';

  @override
  String get appTitle => 'ZENGLISH - English for Wisdom & Meditation';

  @override
  String get back => 'వెనుకకు';

  @override
  String get backToHome => 'హోమ్‌కి వెళ్ళండి';

  @override
  String get backToMain => 'ప్రధాన పేజీకి వెళ్ళండి';

  @override
  String get cancel => 'రద్దు చేయి';

  @override
  String get cefrLevel => 'CEFR స్థాయి';

  @override
  String get complete => 'పూర్తయింది';

  @override
  String get confirm => 'నిర్ధారించండి';

  @override
  String get congratulations => 'ఈ పాఠాన్ని విజయవంతంగా పూర్తి చేసినందుకు అభినందనలు!';

  @override
  String get continueText => 'కొనసాగించండి';

  @override
  String get dharmaSegment => 'Dharma';

  @override
  String get errorOccurred => 'ఒక లోపం సంభవించింది';

  @override
  String get feedback => 'అభిప్రాయం';

  @override
  String get finishLesson => 'పాఠం ముగించు';

  @override
  String get fluency => 'ధారాళత';

  @override
  String get grammar => 'వ్యాకరణం';

  @override
  String get guidedStageTitle => 'దశ 1: వినండి & ఆలోచించండి';

  @override
  String get hideIpa => 'IPA దాచు';

  @override
  String get home => 'హోమ్';

  @override
  String get inputStageTitle => 'దశ 2: భాషా ఇన్పుట్';

  @override
  String get language => 'భాష';

  @override
  String get lessonCompleted => 'పాఠం పూర్తయింది!';

  @override
  String get loading => 'లోడ్ అవుతోంది...';

  @override
  String get matchWords => 'త్రిభాషా పదాల జతపరచడం';

  @override
  String get meditationSegment => 'Meditation';

  @override
  String get meditationStage => 'ధ్యాన దశ';

  @override
  String get meditationTestTitle => '2. ధ్యాన అనుభవం';

  @override
  String get meditator => 'ధ్యాన సాధకుడు';

  @override
  String get monkMode => 'భిక్షువు మోడ్';

  @override
  String get navigationError => 'నేవిగేషన్ లోపం';

  @override
  String get nextPatternPractice => 'తరువాత: పదాల జతపరచడం →';

  @override
  String get noConversation => 'ఈ పాఠానికి సంభాషణలు అందుబాటులో లేవు.';

  @override
  String get noPatterns => 'మాదిరి సాధన అందుబాటులో లేదు.';

  @override
  String get noPractice => 'సాధన దశలు అందుబాటులో లేవు.';

  @override
  String get outputStageTitle => 'దశ 4: ఉచ్చారణ సాధన';

  @override
  String get pageNotFound => 'పేజీ కనుగొనబడలేదు';

  @override
  String get paliKnowledge => 'పాలి జ్ఞానం';

  @override
  String get paliSegment => 'Pāli';

  @override
  String get paliTestTitle => '3. పాలి జ్ఞానం';

  @override
  String get patternStageTitle => 'దశ 3: నిర్మాణం & పదాల జతపరచడం';

  @override
  String get patternViewStageTitle => 'దశ 3a: నిర్మాణాన్ని పరిశీలించండి';

  @override
  String get placementResultTitle => 'మీ కోసం అనుకూలీకరించిన నేర్చుకునే మార్గం';

  @override
  String get placementTest => 'స్థాయి పరీక్ష';

  @override
  String get placementTestSubtitle => 'ఇంగ్లీష్ స్థాయి, ధ్యాన దశ మరియు పాలి జ్ఞానాన్ని నిర్ణయించండి';

  @override
  String get placementTestTitle => 'ప్రారంభ సామర్థ్య మూల్యాంకనం';

  @override
  String get pronunciation => 'ఉచ్చారణ';

  @override
  String get quickStart => 'త్వరిత ప్రారంభం';

  @override
  String get retry => 'మళ్ళీ ప్రయత్నించండి';

  @override
  String get selectLanguage => 'భాషను ఎంచుకోండి';

  @override
  String get settings => 'సెట్టింగ్‌లు';

  @override
  String get showIpa => 'IPA చూపించు';

  @override
  String get silentMode => 'నిశ్శబ్ద మోడ్';

  @override
  String get silentModeDesc => 'ఆటో ఆడియో ప్లేబ్యాక్ లేదు. ఆశ్రమ వాతావరణానికి తగినది.';

  @override
  String get silentModeOff => 'నిశ్శబ్ద మోడ్ ఆఫ్‌లో ఉంది';

  @override
  String get silentModeOn => 'నిశ్శబ్ద మోడ్ ఆన్‌లో ఉంది';

  @override
  String get smartSuggestion => 'స్మార్ట్ సూచన';

  @override
  String get startInterview => 'AI ఇంటర్వ్యూ ప్రారంభించండి';

  @override
  String get startLearning => 'నేర్చుకోవడం ప్రారంభించండి';

  @override
  String get suggestion => 'మెరుగుదల సూచన';

  @override
  String get systemDefault => 'సిస్టమ్ డిఫాల్ట్';

  @override
  String get turnOffSilentToRecord => 'రికార్డ్ చేయడానికి నిశ్శబ్ద మోడ్‌ను ఆఫ్ చేయండి';

  @override
  String get venerableMonk => 'పూజ్యనీయ భిక్షువు / సంఘం';

  @override
  String get viewDetails => 'వివరాలను చూడండి';

  @override
  String get vocabTestTitle => '1. పదజాలం & వ్యాకరణం';

  @override
  String get vocabulary => 'పదజాలం';

  @override
  String get welcomeBack => 'స్వాగతం';

}

/// The translations for `th`.
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([super.localeName = 'th']);

  @override
  String get accuracy => 'ความถูกต้อง';

  @override
  String get aiFeedback => 'การประเมินจาก AI';

  @override
  String get aiInterview => 'สัมภาษณ์ AI';

  @override
  String get aiInterviewDescription => 'ฝึกฝนภาษาอังกฤษพระธรรมและสมาธิกับ AI';

  @override
  String get appSubtitle => 'ภาษาอังกฤษเพื่อปัญญาและการปฏิบัติธรรม';

  @override
  String get appTitle => 'ZENGLISH - ภาษาอังกฤษเพื่อปัญญาและการปฏิบัติธรรม';

  @override
  String get back => 'ย้อนกลับ';

  @override
  String get backToHome => 'กลับหน้าแรก';

  @override
  String get backToMain => 'กลับหน้าหลัก';

  @override
  String get cancel => 'ยกเลิก';

  @override
  String get cefrLevel => 'ระดับ CEFR';

  @override
  String get complete => 'เสร็จสิ้น';

  @override
  String get confirm => 'ยืนยัน';

  @override
  String get congratulations => 'ขอแสดงความยินดีที่คุณเรียนจบบทเรียนนี้อย่างยอดเยี่ยม!';

  @override
  String get continueText => 'ดำเนินต่อ';

  @override
  String get dharmaSegment => 'Dharma';

  @override
  String get errorOccurred => 'เกิดข้อผิดพลาด';

  @override
  String get feedback => 'ข้อเสนอแนะ';

  @override
  String get finishLesson => 'จบบทเรียน';

  @override
  String get fluency => 'ความคล่องแคล่ว';

  @override
  String get grammar => 'ไวยากรณ์';

  @override
  String get guidedStageTitle => 'ระยะที่ 1: ฟังและพิจารณา';

  @override
  String get hideIpa => 'ซ่อนสัญลักษณ์ IPA';

  @override
  String get home => 'หน้าแรก';

  @override
  String get inputStageTitle => 'ระยะที่ 2: การรับข้อมูลภาษา';

  @override
  String get language => 'ภาษา';

  @override
  String get lessonCompleted => 'จบบทเรียนแล้ว!';

  @override
  String get loading => 'กำลังโหลด...';

  @override
  String get matchWords => 'การจับคู่คำสามภาษา';

  @override
  String get meditationSegment => 'Meditation';

  @override
  String get meditationStage => 'ขั้นการปฏิบัติธรรม';

  @override
  String get meditationTestTitle => '2. ประสบการณ์การปฏิบัติธรรม';

  @override
  String get meditator => 'ผู้ปฏิบัติธรรม';

  @override
  String get monkMode => 'โหมดพระสงฆ์';

  @override
  String get navigationError => 'ข้อผิดพลาดในการนำทาง';

  @override
  String get nextPatternPractice => 'ถัดไป: จับคู่คำ →';

  @override
  String get noConversation => 'ไม่มีบทสนทนาสำหรับบทเรียนนี้';

  @override
  String get noPatterns => 'ไม่มีแบบฝึกหัดรูปประโยค';

  @override
  String get noPractice => 'ไม่มีขั้นตอนการฝึกฝน';

  @override
  String get outputStageTitle => 'ระยะที่ 4: ฝึกฝนการออกเสียง';

  @override
  String get pageNotFound => 'ไม่พบหน้านี้';

  @override
  String get paliKnowledge => 'ความรู้ภาษาบาลี';

  @override
  String get paliSegment => 'Pāli';

  @override
  String get paliTestTitle => '3. ความรู้ภาษาบาลี';

  @override
  String get patternStageTitle => 'ระยะที่ 3: โครงสร้างและการจับคู่คำ';

  @override
  String get patternViewStageTitle => 'ระยะที่ 3a: สังเกตโครงสร้าง';

  @override
  String get placementResultTitle => 'เส้นทางการเรียนรู้เฉพาะคุณ';

  @override
  String get placementTest => 'แบบทดสอบวัดระดับ';

  @override
  String get placementTestSubtitle => 'ระบุระดับภาษาอังกฤษ ขั้นการปฏิบัติธรรม และความรู้บาลี';

  @override
  String get placementTestTitle => 'การประเมินความสามารถเบื้องต้น';

  @override
  String get pronunciation => 'การออกเสียง';

  @override
  String get quickStart => 'เริ่มต้นอย่างรวดเร็ว';

  @override
  String get retry => 'ลองอีกครั้ง';

  @override
  String get selectLanguage => 'เลือกภาษา';

  @override
  String get settings => 'ตั้งค่า';

  @override
  String get showIpa => 'แสดงสัญลักษณ์ IPA';

  @override
  String get silentMode => 'โหมดเงียบ';

  @override
  String get silentModeDesc => 'ไม่มีเสียงเล่นอัตโนมัติ เหมาะสำหรับบรรยากาศวัดและสำนักปฏิบัติธรรม';

  @override
  String get silentModeOff => 'ปิดโหมดเงียบ';

  @override
  String get silentModeOn => 'เปิดโหมดเงียบ';

  @override
  String get smartSuggestion => 'คำแนะนำอัจฉริยะ';

  @override
  String get startInterview => 'เริ่มการสัมภาษณ์ AI';

  @override
  String get startLearning => 'เริ่มการเรียนรู้';

  @override
  String get suggestion => 'คำแนะนำในการปรับปรุง';

  @override
  String get systemDefault => 'ตามระบบ';

  @override
  String get turnOffSilentToRecord => 'ปิดโหมดเงียบเพื่อบันทึกเสียง';

  @override
  String get venerableMonk => 'พระคุณเจ้า / พระสงฆ์';

  @override
  String get viewDetails => 'ดูรายละเอียด';

  @override
  String get vocabTestTitle => '1. คำศัพท์และไวยากรณ์';

  @override
  String get vocabulary => 'คำศัพท์';

  @override
  String get welcomeBack => 'ยินดีต้อนรับ';

}

/// The translations for `vi`.
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([super.localeName = 'vi']);

  @override
  String get accuracy => 'Độ chính xác';

  @override
  String get aiFeedback => 'Nhận xét từ AI';

  @override
  String get aiInterview => 'AI Interview';

  @override
  String get aiInterviewDescription => 'Luyện nói Tiếng Anh Phật Pháp với Trí Tuệ Nhân Tạo';

  @override
  String get appSubtitle => 'English for Wisdom & Meditation';

  @override
  String get appTitle => 'ZENGLISH - English for Wisdom & Meditation';

  @override
  String get back => 'Quay lại';

  @override
  String get backToHome => 'Về trang chủ';

  @override
  String get backToMain => 'Về trang chính';

  @override
  String get cancel => 'Hủy';

  @override
  String get cefrLevel => 'Trình độ CEFR';

  @override
  String get complete => 'Hoàn thành';

  @override
  String get confirm => 'Xác nhận';

  @override
  String get congratulations => 'Chúc mừng bạn đã hoàn thành xuất sắc bài học này!';

  @override
  String get continueText => 'Tiếp tục';

  @override
  String get dharmaSegment => 'Dharma';

  @override
  String get errorOccurred => 'Có lỗi xảy ra';

  @override
  String get feedback => 'Đánh giá & Phản hồi';

  @override
  String get finishLesson => 'Hoàn thành bài học';

  @override
  String get fluency => 'Độ trôi chảy';

  @override
  String get grammar => 'Ngữ pháp';

  @override
  String get guidedStageTitle => 'Giai đoạn 1: Lắng nghe & Cảm nhận';

  @override
  String get hideIpa => 'Ẩn ký âm IPA';

  @override
  String get home => 'Trang chủ';

  @override
  String get inputStageTitle => 'Giai đoạn 2: Tiếp thu Ngôn ngữ';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get lessonCompleted => 'Bài học hoàn thành!';

  @override
  String get loading => 'Đang tải...';

  @override
  String get matchWords => 'Nối từ Tam ngữ';

  @override
  String get meditationSegment => 'Meditation';

  @override
  String get meditationStage => 'Giai đoạn Thiền';

  @override
  String get meditationTestTitle => '2. Kinh nghiệm Thiền định';

  @override
  String get meditator => 'Thiền sinh';

  @override
  String get monkMode => 'Chế độ Tăng sĩ';

  @override
  String get navigationError => 'Lỗi điều hướng';

  @override
  String get nextPatternPractice => 'Tiếp theo: Nối Từ →';

  @override
  String get noConversation => 'Chưa có hội thoại cho bài học này.';

  @override
  String get noPatterns => 'Chưa có mẫu câu.';

  @override
  String get noPractice => 'Chưa có bước luyện tập.';

  @override
  String get outputStageTitle => 'Giai đoạn 4: Thực hành Phát âm';

  @override
  String get pageNotFound => 'Trang không tồn tại';

  @override
  String get paliKnowledge => 'Trình độ Pāli';

  @override
  String get paliSegment => 'Pāli';

  @override
  String get paliTestTitle => '3. Kiến thức Pāli';

  @override
  String get patternStageTitle => 'Giai đoạn 3: Cấu trúc & Nối từ';

  @override
  String get patternViewStageTitle => 'Giai đoạn 3a: Quan sát Cấu trúc';

  @override
  String get placementResultTitle => 'Lộ trình Học tập Dành cho Bạn';

  @override
  String get placementTest => 'Kiểm tra trình độ';

  @override
  String get placementTestSubtitle => 'Xác định trình độ Tiếng Anh, Thiền định và Kiến thức Pāli';

  @override
  String get placementTestTitle => 'Đánh giá Năng lực Ban đầu';

  @override
  String get pronunciation => 'Phát âm';

  @override
  String get quickStart => 'Bắt đầu nhanh';

  @override
  String get retry => 'Thử lại';

  @override
  String get selectLanguage => 'Chọn ngôn ngữ';

  @override
  String get settings => 'Cài đặt';

  @override
  String get showIpa => 'Hiển thị ký âm IPA';

  @override
  String get silentMode => 'Chế độ Im lặng';

  @override
  String get silentModeDesc => 'Không phát âm thanh tự động. Phù hợp cho môi trường thiền viện.';

  @override
  String get silentModeOff => 'Chế độ im lặng đang TẮT';

  @override
  String get silentModeOn => 'Chế độ im lặng đang BẬT';

  @override
  String get smartSuggestion => 'Gợi ý học tập';

  @override
  String get startInterview => 'Bắt đầu phỏng vấn AI';

  @override
  String get startLearning => 'Bắt đầu Học tập';

  @override
  String get suggestion => 'Gợi ý cải thiện';

  @override
  String get systemDefault => 'Theo hệ thống';

  @override
  String get turnOffSilentToRecord => 'Tắt im lặng để ghi âm';

  @override
  String get venerableMonk => 'Sư thầy / Tăng sĩ';

  @override
  String get viewDetails => 'Xem chi tiết';

  @override
  String get vocabTestTitle => '1. Trình độ Từ vựng & Ngữ pháp';

  @override
  String get vocabulary => 'Từ vựng';

  @override
  String get welcomeBack => 'Kính chào';

}

/// The translations for `zh`.
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([super.localeName = 'zh']);

  @override
  String get accuracy => '准确度';

  @override
  String get aiFeedback => 'AI 评价';

  @override
  String get aiInterview => 'AI 访谈';

  @override
  String get aiInterviewDescription => '使用人工智能练习佛法与禅修英语';

  @override
  String get appSubtitle => '智慧与禅修英语';

  @override
  String get appTitle => 'ZENGLISH - 智慧与禅修英语';

  @override
  String get back => '返回';

  @override
  String get backToHome => '返回首页';

  @override
  String get backToMain => '返回主页';

  @override
  String get cancel => '取消';

  @override
  String get cefrLevel => 'CEFR 等级';

  @override
  String get complete => '完成';

  @override
  String get confirm => '确认';

  @override
  String get congratulations => '恭喜您圆满完成本课学习！';

  @override
  String get continueText => '继续';

  @override
  String get dharmaSegment => 'Dharma';

  @override
  String get errorOccurred => '发生错误';

  @override
  String get feedback => '反馈';

  @override
  String get finishLesson => '完成课程';

  @override
  String get fluency => '流畅度';

  @override
  String get grammar => '语法';

  @override
  String get guidedStageTitle => '第一阶段：倾听与体悟';

  @override
  String get hideIpa => '隐藏 IPA 音标';

  @override
  String get home => '首页';

  @override
  String get inputStageTitle => '第二阶段：语言输入';

  @override
  String get language => '语言';

  @override
  String get lessonCompleted => '课程完成！';

  @override
  String get loading => '加载中...';

  @override
  String get matchWords => '三语连线配对';

  @override
  String get meditationSegment => 'Meditation';

  @override
  String get meditationStage => '禅修阶段';

  @override
  String get meditationTestTitle => '2. 禅修经验';

  @override
  String get meditator => '禅修者';

  @override
  String get monkMode => '僧伽模式';

  @override
  String get navigationError => '导航错误';

  @override
  String get nextPatternPractice => '下一步：配对练习 →';

  @override
  String get noConversation => '本课暂无对话。';

  @override
  String get noPatterns => '暂无句型练习。';

  @override
  String get noPractice => '暂无练习步骤。';

  @override
  String get outputStageTitle => '第四阶段：发音练习';

  @override
  String get pageNotFound => '页面不存在';

  @override
  String get paliKnowledge => '巴利语水平';

  @override
  String get paliSegment => 'Pāli';

  @override
  String get paliTestTitle => '3. 巴利语知识';

  @override
  String get patternStageTitle => '第三阶段：句型与配对';

  @override
  String get patternViewStageTitle => '第三a阶段：观察结构';

  @override
  String get placementResultTitle => '为您定制的学习路径';

  @override
  String get placementTest => '分级测试';

  @override
  String get placementTestSubtitle => '确定英语水平、禅修阶段与巴利语知识';

  @override
  String get placementTestTitle => '初始能力评估';

  @override
  String get pronunciation => '发音';

  @override
  String get quickStart => '快速开始';

  @override
  String get retry => '重试';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get settings => '设置';

  @override
  String get showIpa => '显示 IPA 音标';

  @override
  String get silentMode => '静音模式';

  @override
  String get silentModeDesc => '不自动播放音频，适合寺院与禅修环境。';

  @override
  String get silentModeOff => '静音模式已关闭';

  @override
  String get silentModeOn => '静音模式已开启';

  @override
  String get smartSuggestion => '智能学习建议';

  @override
  String get startInterview => '开始 AI 访谈';

  @override
  String get startLearning => '开始学习';

  @override
  String get suggestion => '改进建议';

  @override
  String get systemDefault => '跟随系统';

  @override
  String get turnOffSilentToRecord => '关闭静音模式以录音';

  @override
  String get venerableMonk => '尊者 / 僧伽';

  @override
  String get viewDetails => '查看详情';

  @override
  String get vocabTestTitle => '1. 词汇与语法';

  @override
  String get vocabulary => '词汇';

  @override
  String get welcomeBack => '欢迎';

}

/// The translations for `zh_TW`.
class AppLocalizationsZhTw extends AppLocalizations {
  AppLocalizationsZhTw([super.localeName = 'zh_TW']);

  @override
  String get accuracy => '準確度';

  @override
  String get aiFeedback => 'AI 評價';

  @override
  String get aiInterview => 'AI 訪談';

  @override
  String get aiInterviewDescription => '使用人工智慧練習佛法與禪修英語';

  @override
  String get appSubtitle => '智慧與禪修英語';

  @override
  String get appTitle => 'ZENGLISH - 智慧與禪修英語';

  @override
  String get back => '返回';

  @override
  String get backToHome => '返回首頁';

  @override
  String get backToMain => '返回主頁';

  @override
  String get cancel => '取消';

  @override
  String get cefrLevel => 'CEFR 等級';

  @override
  String get complete => '完成';

  @override
  String get confirm => '確認';

  @override
  String get congratulations => '恭喜您圓滿完成本課學習！';

  @override
  String get continueText => '繼續';

  @override
  String get dharmaSegment => 'Dharma';

  @override
  String get errorOccurred => '發生錯誤';

  @override
  String get feedback => '反饋';

  @override
  String get finishLesson => '完成課程';

  @override
  String get fluency => '流暢度';

  @override
  String get grammar => '語法';

  @override
  String get guidedStageTitle => '第一階段：傾聽與體悟';

  @override
  String get hideIpa => '隱藏 IPA 音標';

  @override
  String get home => '首頁';

  @override
  String get inputStageTitle => '第二階段：語言輸入';

  @override
  String get language => '語言';

  @override
  String get lessonCompleted => '課程完成！';

  @override
  String get loading => '載入中...';

  @override
  String get matchWords => '三語連線配對';

  @override
  String get meditationSegment => 'Meditation';

  @override
  String get meditationStage => '禪修階段';

  @override
  String get meditationTestTitle => '2. 禪修經驗';

  @override
  String get meditator => '禪修者';

  @override
  String get monkMode => '僧伽模式';

  @override
  String get navigationError => '導航錯誤';

  @override
  String get nextPatternPractice => '下一步：配對練習 →';

  @override
  String get noConversation => '本課暫無對話。';

  @override
  String get noPatterns => '暫無句型練習。';

  @override
  String get noPractice => '暫無練習步驟。';

  @override
  String get outputStageTitle => '第四階段：發音練習';

  @override
  String get pageNotFound => '頁面不存在';

  @override
  String get paliKnowledge => '巴利語水平';

  @override
  String get paliSegment => 'Pāli';

  @override
  String get paliTestTitle => '3. 巴利語知識';

  @override
  String get patternStageTitle => '第三階段：句型與配對';

  @override
  String get patternViewStageTitle => '第三a階段：觀察結構';

  @override
  String get placementResultTitle => '為您定製的學習路徑';

  @override
  String get placementTest => '分級測試';

  @override
  String get placementTestSubtitle => '確定英語水平、禪修階段與巴利語知識';

  @override
  String get placementTestTitle => '初始能力評估';

  @override
  String get pronunciation => '發音';

  @override
  String get quickStart => '快速開始';

  @override
  String get retry => '重試';

  @override
  String get selectLanguage => '選擇語言';

  @override
  String get settings => '設定';

  @override
  String get showIpa => '顯示 IPA 音標';

  @override
  String get silentMode => '靜音模式';

  @override
  String get silentModeDesc => '不自動播放音訊，適合寺院與禪修環境。';

  @override
  String get silentModeOff => '靜音模式已關閉';

  @override
  String get silentModeOn => '靜音模式已開啟';

  @override
  String get smartSuggestion => '智能學習建議';

  @override
  String get startInterview => '開始 AI 訪談';

  @override
  String get startLearning => '開始學習';

  @override
  String get suggestion => '改進建議';

  @override
  String get systemDefault => '跟隨系統';

  @override
  String get turnOffSilentToRecord => '關閉靜音模式以錄音';

  @override
  String get venerableMonk => '尊者 / 僧伽';

  @override
  String get viewDetails => '檢視詳情';

  @override
  String get vocabTestTitle => '1. 詞彙與語法';

  @override
  String get vocabulary => '詞彙';

  @override
  String get welcomeBack => '歡迎';

}
