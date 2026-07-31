import 'package:flutter/widgets.dart';

abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale);

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('vi', 'VN'),
    Locale('en', 'US'),
    Locale('zh'),
    Locale('zh', 'TW'),
    Locale('si'),
    Locale('hi'),
    Locale('my'),
    Locale('ar'),
    Locale('bn'),
    Locale('bo'),
    Locale('de'),
    Locale('es'),
    Locale('fr'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('km'),
    Locale('ko'),
    Locale('lo'),
    Locale('mn'),
    Locale('mr'),
    Locale('pt'),
    Locale('ru'),
    Locale('ta'),
    Locale('te'),
    Locale('th'),
  ];

  String get appTitle;
  String get appSubtitle;
  String get systemDefault;
  String get selectLanguage;
  String get language;
  String get home;
  String get back;
  String get continueText;
  String get retry;
  String get complete;
  String get finishLesson;
  String get backToHome;
  String get backToMain;
  String get navigationError;
  String get pageNotFound;
  String get errorOccurred;
  String get loading;
  String get welcomeBack;
  String get meditator;
  String get venerableMonk;
  String get quickStart;
  String get aiInterview;
  String get aiInterviewDescription;
  String get startInterview;
  String get smartSuggestion;
  String get placementTest;
  String get placementTestTitle;
  String get placementTestSubtitle;
  String get vocabTestTitle;
  String get meditationTestTitle;
  String get paliTestTitle;
  String get placementResultTitle;
  String get cefrLevel;
  String get meditationStage;
  String get paliKnowledge;
  String get startLearning;
  String get silentMode;
  String get silentModeOn;
  String get silentModeOff;
  String get silentModeDesc;
  String get turnOffSilentToRecord;
  String get guidedStageTitle;
  String get inputStageTitle;
  String get patternStageTitle;
  String get outputStageTitle;
  String get patternViewStageTitle;
  String get lessonCompleted;
  String get congratulations;
  String get noConversation;
  String get noPatterns;
  String get noPractice;
  String get matchWords;
  String get nextPatternPractice;
  String get viewDetails;
  String get dharmaSegment;
  String get meditationSegment;
  String get paliSegment;
  String get vocabulary;
  String get grammar;
  String get pronunciation;
  String get feedback;
  String get aiFeedback;
  String get accuracy;
  String get fluency;
  String get suggestion;
  String get cancel;
  String get confirm;
  String get settings;
  String get showIpa;
  String get hideIpa;
  String get monkMode;
}

extension LocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this) ?? _AppLocalizationsVi();
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return Future.value(_lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) {
    final languageCode = locale.languageCode;
    return ['vi', 'en', 'zh', 'si', 'hi', 'my', 'ar', 'bn', 'bo', 'de', 'es', 'fr', 'id', 'it', 'ja', 'km', 'ko', 'lo', 'mn', 'mr', 'pt', 'ru', 'ta', 'te', 'th'].contains(languageCode);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations _lookupAppLocalizations(Locale locale) {
  if (locale.languageCode == 'zh') {
    if (locale.countryCode == 'TW' || locale.scriptCode == 'Hant') {
      return _AppLocalizationsZhTw();
    }
    return _AppLocalizationsZh();
  }

  switch (locale.languageCode) {
    case 'vi': return _AppLocalizationsVi();
    case 'en': return _AppLocalizationsEn();
    case 'zh': return _AppLocalizationsZh();
    case 'si': return _AppLocalizationsSi();
    case 'hi': return _AppLocalizationsHi();
    case 'my': return _AppLocalizationsMy();
    case 'ar': return _AppLocalizationsAr();
    case 'bn': return _AppLocalizationsBn();
    case 'bo': return _AppLocalizationsBo();
    case 'de': return _AppLocalizationsDe();
    case 'es': return _AppLocalizationsEs();
    case 'fr': return _AppLocalizationsFr();
    case 'id': return _AppLocalizationsId();
    case 'it': return _AppLocalizationsIt();
    case 'ja': return _AppLocalizationsJa();
    case 'km': return _AppLocalizationsKm();
    case 'ko': return _AppLocalizationsKo();
    case 'lo': return _AppLocalizationsLo();
    case 'mn': return _AppLocalizationsMn();
    case 'mr': return _AppLocalizationsMr();
    case 'pt': return _AppLocalizationsPt();
    case 'ru': return _AppLocalizationsRu();
    case 'ta': return _AppLocalizationsTa();
    case 'te': return _AppLocalizationsTe();
    case 'th': return _AppLocalizationsTh();
    default: return _AppLocalizationsVi();
  }
}

// ── Vi ──
class _AppLocalizationsVi extends AppLocalizations {
  _AppLocalizationsVi() : super('vi');
  @override String get appTitle => "ZENGLISH - English for Wisdom & Meditation";
  @override String get appSubtitle => "English for Wisdom & Meditation";
  @override String get systemDefault => "Theo hệ thống";
  @override String get selectLanguage => "Chọn ngôn ngữ";
  @override String get language => "Ngôn ngữ";
  @override String get home => "Trang chủ";
  @override String get back => "Quay lại";
  @override String get continueText => "Tiếp tục";
  @override String get retry => "Thử lại";
  @override String get complete => "Hoàn thành";
  @override String get finishLesson => "Hoàn thành bài học";
  @override String get backToHome => "Về trang chủ";
  @override String get backToMain => "Về trang chính";
  @override String get navigationError => "Lỗi điều hướng";
  @override String get pageNotFound => "Trang không tồn tại";
  @override String get errorOccurred => "Có lỗi xảy ra";
  @override String get loading => "Đang tải...";
  @override String get welcomeBack => "Kính chào";
  @override String get meditator => "Thiền sinh";
  @override String get venerableMonk => "Sư thầy / Tăng sĩ";
  @override String get quickStart => "Bắt đầu nhanh";
  @override String get aiInterview => "AI Interview";
  @override String get aiInterviewDescription => "Luyện nói Tiếng Anh Phật Pháp với Trí Tuệ Nhân Tạo";
  @override String get startInterview => "Bắt đầu phỏng vấn AI";
  @override String get smartSuggestion => "Gợi ý học tập";
  @override String get placementTest => "Kiểm tra trình độ";
  @override String get placementTestTitle => "Đánh giá Năng lực Ban đầu";
  @override String get placementTestSubtitle => "Xác định trình độ Tiếng Anh, Thiền định và Kiến thức Pāli";
  @override String get vocabTestTitle => "1. Trình độ Từ vựng & Ngữ pháp";
  @override String get meditationTestTitle => "2. Kinh nghiệm Thiền định";
  @override String get paliTestTitle => "3. Kiến thức Pāli";
  @override String get placementResultTitle => "Lộ trình Học tập Dành cho Bạn";
  @override String get cefrLevel => "Trình độ CEFR";
  @override String get meditationStage => "Giai đoạn Thiền";
  @override String get paliKnowledge => "Trình độ Pāli";
  @override String get startLearning => "Bắt đầu Học tập";
  @override String get silentMode => "Chế độ Im lặng";
  @override String get silentModeOn => "Chế độ im lặng đang BẬT";
  @override String get silentModeOff => "Chế độ im lặng đang TẮT";
  @override String get silentModeDesc => "Không phát âm thanh tự động. Phù hợp cho môi trường thiền viện.";
  @override String get turnOffSilentToRecord => "Tắt im lặng để ghi âm";
  @override String get guidedStageTitle => "Giai đoạn 1: Lắng nghe & Cảm nhận";
  @override String get inputStageTitle => "Giai đoạn 2: Tiếp thu Ngôn ngữ";
  @override String get patternStageTitle => "Giai đoạn 3: Cấu trúc & Nối từ";
  @override String get outputStageTitle => "Giai đoạn 4: Thực hành Phát âm";
  @override String get patternViewStageTitle => "Giai đoạn 3a: Quan sát Cấu trúc";
  @override String get lessonCompleted => "Bài học hoàn thành!";
  @override String get congratulations => "Chúc mừng bạn đã hoàn thành xuất sắc bài học này!";
  @override String get noConversation => "Chưa có hội thoại cho bài học này.";
  @override String get noPatterns => "Chưa có mẫu câu.";
  @override String get noPractice => "Chưa có bước luyện tập.";
  @override String get matchWords => "Nối từ Tam ngữ";
  @override String get nextPatternPractice => "Tiếp theo: Nối Từ →";
  @override String get viewDetails => "Xem chi tiết";
  @override String get dharmaSegment => "Dharma";
  @override String get meditationSegment => "Meditation";
  @override String get paliSegment => "Pāli";
  @override String get vocabulary => "Từ vựng";
  @override String get grammar => "Ngữ pháp";
  @override String get pronunciation => "Phát âm";
  @override String get feedback => "Đánh giá & Phản hồi";
  @override String get aiFeedback => "Nhận xét từ AI";
  @override String get accuracy => "Độ chính xác";
  @override String get fluency => "Độ trôi chảy";
  @override String get suggestion => "Gợi ý cải thiện";
  @override String get cancel => "Hủy";
  @override String get confirm => "Xác nhận";
  @override String get settings => "Cài đặt";
  @override String get showIpa => "Hiển thị ký âm IPA";
  @override String get hideIpa => "Ẩn ký âm IPA";
  @override String get monkMode => "Chế độ Tăng sĩ";
}

// ── En ──
class _AppLocalizationsEn extends AppLocalizations {
  _AppLocalizationsEn() : super('en');
  @override String get appTitle => "ZENGLISH - English for Wisdom & Meditation";
  @override String get appSubtitle => "English for Wisdom & Meditation";
  @override String get systemDefault => "System Default";
  @override String get selectLanguage => "Select Language";
  @override String get language => "Language";
  @override String get home => "Home";
  @override String get back => "Back";
  @override String get continueText => "Continue";
  @override String get retry => "Retry";
  @override String get complete => "Complete";
  @override String get finishLesson => "Finish Lesson";
  @override String get backToHome => "Back to Home";
  @override String get backToMain => "Back to Main";
  @override String get navigationError => "Navigation Error";
  @override String get pageNotFound => "Page not found";
  @override String get errorOccurred => "An error occurred";
  @override String get loading => "Loading...";
  @override String get welcomeBack => "Welcome";
  @override String get meditator => "Meditator";
  @override String get venerableMonk => "Venerable Monk / Sangha";
  @override String get quickStart => "Quick Start";
  @override String get aiInterview => "AI Interview";
  @override String get aiInterviewDescription => "Practice Dharma & Meditation English with AI";
  @override String get startInterview => "Start AI Interview";
  @override String get smartSuggestion => "Smart Suggestion";
  @override String get placementTest => "Placement Test";
  @override String get placementTestTitle => "Initial Competency Assessment";
  @override String get placementTestSubtitle => "Determine English level, Meditation stage & Pāli knowledge";
  @override String get vocabTestTitle => "1. Vocabulary & Grammar";
  @override String get meditationTestTitle => "2. Meditation Experience";
  @override String get paliTestTitle => "3. Pāli Knowledge";
  @override String get placementResultTitle => "Your Customized Learning Path";
  @override String get cefrLevel => "CEFR Level";
  @override String get meditationStage => "Meditation Stage";
  @override String get paliKnowledge => "Pāli Knowledge";
  @override String get startLearning => "Start Learning";
  @override String get silentMode => "Silent Mode";
  @override String get silentModeOn => "Silent Mode is ON";
  @override String get silentModeOff => "Silent Mode is OFF";
  @override String get silentModeDesc => "No auto audio playback. Suitable for monastery environment.";
  @override String get turnOffSilentToRecord => "Turn off silent mode to record";
  @override String get guidedStageTitle => "Stage 1: Listen & Reflect";
  @override String get inputStageTitle => "Stage 2: Language Input";
  @override String get patternStageTitle => "Stage 3: Structure & Word Match";
  @override String get outputStageTitle => "Stage 4: Pronunciation Practice";
  @override String get patternViewStageTitle => "Stage 3a: Observe Structure";
  @override String get lessonCompleted => "Lesson Completed!";
  @override String get congratulations => "Congratulations on completing this lesson successfully!";
  @override String get noConversation => "No conversation available for this lesson.";
  @override String get noPatterns => "No pattern practice available.";
  @override String get noPractice => "No practice steps available.";
  @override String get matchWords => "Tri-lingual Word Matching";
  @override String get nextPatternPractice => "Next: Word Match →";
  @override String get viewDetails => "View Details";
  @override String get dharmaSegment => "Dharma";
  @override String get meditationSegment => "Meditation";
  @override String get paliSegment => "Pāli";
  @override String get vocabulary => "Vocabulary";
  @override String get grammar => "Grammar";
  @override String get pronunciation => "Pronunciation";
  @override String get feedback => "Feedback";
  @override String get aiFeedback => "AI Feedback";
  @override String get accuracy => "Accuracy";
  @override String get fluency => "Fluency";
  @override String get suggestion => "Improvement Suggestion";
  @override String get cancel => "Cancel";
  @override String get confirm => "Confirm";
  @override String get settings => "Settings";
  @override String get showIpa => "Show IPA Notation";
  @override String get hideIpa => "Hide IPA Notation";
  @override String get monkMode => "Monk Mode";
}

// ── Zh ──
class _AppLocalizationsZh extends AppLocalizations {
  _AppLocalizationsZh() : super('zh');
  @override String get appTitle => "ZENGLISH - 智慧与禅修英语";
  @override String get appSubtitle => "智慧与禅修英语";
  @override String get systemDefault => "跟随系统";
  @override String get selectLanguage => "选择语言";
  @override String get language => "语言";
  @override String get home => "首页";
  @override String get back => "返回";
  @override String get continueText => "继续";
  @override String get retry => "重试";
  @override String get complete => "完成";
  @override String get finishLesson => "完成课程";
  @override String get backToHome => "返回首页";
  @override String get backToMain => "返回主页";
  @override String get navigationError => "导航错误";
  @override String get pageNotFound => "页面不存在";
  @override String get errorOccurred => "发生错误";
  @override String get loading => "加载中...";
  @override String get welcomeBack => "欢迎";
  @override String get meditator => "禅修者";
  @override String get venerableMonk => "尊者 / 僧伽";
  @override String get quickStart => "快速开始";
  @override String get aiInterview => "AI 访谈";
  @override String get aiInterviewDescription => "使用人工智慧练习佛法与禅修英语";
  @override String get startInterview => "开始 AI 访谈";
  @override String get smartSuggestion => "智能学习建议";
  @override String get placementTest => "分级测试";
  @override String get placementTestTitle => "初始能力评估";
  @override String get placementTestSubtitle => "确定英语水平、禅修阶段与巴利语知识";
  @override String get vocabTestTitle => "1. 词汇与语法";
  @override String get meditationTestTitle => "2. 禅修经验";
  @override String get paliTestTitle => "3. 巴利语知识";
  @override String get placementResultTitle => "为您定制的学习路径";
  @override String get cefrLevel => "CEFR 等级";
  @override String get meditationStage => "禅修阶段";
  @override String get paliKnowledge => "巴利语水平";
  @override String get startLearning => "开始学习";
  @override String get silentMode => "静音模式";
  @override String get silentModeOn => "静音模式已开启";
  @override String get silentModeOff => "静音模式已关闭";
  @override String get silentModeDesc => "不自动播放音频，适合寺院与禅修环境。";
  @override String get turnOffSilentToRecord => "关闭静音模式以录音";
  @override String get guidedStageTitle => "第一阶段：倾听与体悟";
  @override String get inputStageTitle => "第二阶段：语言输入";
  @override String get patternStageTitle => "第三阶段：句型与配对";
  @override String get outputStageTitle => "第四阶段：发音练习";
  @override String get patternViewStageTitle => "第三a阶段：观察结构";
  @override String get lessonCompleted => "课程完成！";
  @override String get congratulations => "恭喜您圆满完成本课学习！";
  @override String get noConversation => "本课暂无对话。";
  @override String get noPatterns => "暂无句型练习。";
  @override String get noPractice => "暂无练习步骤。";
  @override String get matchWords => "三语连线配对";
  @override String get nextPatternPractice => "下一步：配对练习 →";
  @override String get viewDetails => "查看详情";
  @override String get dharmaSegment => "Dharma";
  @override String get meditationSegment => "Meditation";
  @override String get paliSegment => "Pāli";
  @override String get vocabulary => "词汇";
  @override String get grammar => "语法";
  @override String get pronunciation => "发音";
  @override String get feedback => "反馈";
  @override String get aiFeedback => "AI 评价";
  @override String get accuracy => "准确度";
  @override String get fluency => "流畅度";
  @override String get suggestion => "改进建议";
  @override String get cancel => "取消";
  @override String get confirm => "确认";
  @override String get settings => "设置";
  @override String get showIpa => "显示 IPA 音标";
  @override String get hideIpa => "隐藏 IPA 音标";
  @override String get monkMode => "僧伽模式";
}

// ── Zh TW ──
class _AppLocalizationsZhTw extends AppLocalizations {
  _AppLocalizationsZhTw() : super('zh_TW');
  @override String get appTitle => "ZENGLISH - 智慧與禪修英語";
  @override String get appSubtitle => "智慧與禪修英語";
  @override String get systemDefault => "跟隨系統";
  @override String get selectLanguage => "選擇語言";
  @override String get language => "語言";
  @override String get home => "首頁";
  @override String get back => "返回";
  @override String get continueText => "繼續";
  @override String get retry => "重試";
  @override String get complete => "完成";
  @override String get finishLesson => "完成課程";
  @override String get backToHome => "返回首頁";
  @override String get backToMain => "返回主頁";
  @override String get navigationError => "導航錯誤";
  @override String get pageNotFound => "頁面不存在";
  @override String get errorOccurred => "發生錯誤";
  @override String get loading => "載入中...";
  @override String get welcomeBack => "歡迎";
  @override String get meditator => "禪修者";
  @override String get venerableMonk => "尊者 / 僧伽";
  @override String get quickStart => "快速開始";
  @override String get aiInterview => "AI 訪談";
  @override String get aiInterviewDescription => "使用人工智慧練習佛法與禪修英語";
  @override String get startInterview => "開始 AI 訪談";
  @override String get smartSuggestion => "智能學習建議";
  @override String get placementTest => "分級測試";
  @override String get placementTestTitle => "初始能力評估";
  @override String get placementTestSubtitle => "確定英語水平、禪修階段與巴利語知識";
  @override String get vocabTestTitle => "1. 詞彙與語法";
  @override String get meditationTestTitle => "2. 禪修經驗";
  @override String get paliTestTitle => "3. 巴利語知識";
  @override String get placementResultTitle => "為您定製的學習路徑";
  @override String get cefrLevel => "CEFR 等級";
  @override String get meditationStage => "禪修階段";
  @override String get paliKnowledge => "巴利語水平";
  @override String get startLearning => "開始學習";
  @override String get silentMode => "靜音模式";
  @override String get silentModeOn => "靜音模式已開啟";
  @override String get silentModeOff => "靜音模式已關閉";
  @override String get silentModeDesc => "不自動播放音訊，適合寺院與禪修環境。";
  @override String get turnOffSilentToRecord => "關閉靜音模式以錄音";
  @override String get guidedStageTitle => "第一階段：傾聽與體悟";
  @override String get inputStageTitle => "第二階段：語言輸入";
  @override String get patternStageTitle => "第三階段：句型與配對";
  @override String get outputStageTitle => "第四階段：發音練習";
  @override String get patternViewStageTitle => "第三a階段：觀察結構";
  @override String get lessonCompleted => "課程完成！";
  @override String get congratulations => "恭喜您圓滿完成本課學習！";
  @override String get noConversation => "本課暫無對話。";
  @override String get noPatterns => "暫無句型練習。";
  @override String get noPractice => "暫無練習步驟。";
  @override String get matchWords => "三語連線配對";
  @override String get nextPatternPractice => "下一步：配對練習 →";
  @override String get viewDetails => "檢視詳情";
  @override String get dharmaSegment => "Dharma";
  @override String get meditationSegment => "Meditation";
  @override String get paliSegment => "Pāli";
  @override String get vocabulary => "詞彙";
  @override String get grammar => "語法";
  @override String get pronunciation => "發音";
  @override String get feedback => "反饋";
  @override String get aiFeedback => "AI 評價";
  @override String get accuracy => "準確度";
  @override String get fluency => "流暢度";
  @override String get suggestion => "改進建議";
  @override String get cancel => "取消";
  @override String get confirm => "確認";
  @override String get settings => "設定";
  @override String get showIpa => "顯示 IPA 音標";
  @override String get hideIpa => "隱藏 IPA 音標";
  @override String get monkMode => "僧伽模式";
}

// ── Si ──
class _AppLocalizationsSi extends _AppLocalizationsEn {
  _AppLocalizationsSi() : super();
  @override String get systemDefault => "පද්ධතිමය මුල් සැකසුම";
  @override String get selectLanguage => "භාෂාව තෝරන්න";
  @override String get language => "භාෂාව";
  @override String get home => "මුල් පිටුව";
  @override String get back => "ආපසු";
  @override String get continueText => "ඉදිරියට";
  @override String get retry => "නැවත උත්සාහ කරන්න";
  @override String get complete => "සම්පූර්ණයි";
  @override String get finishLesson => "පාඩම අවසන් කරන්න";
  @override String get backToHome => "මුල් පිටුවට";
  @override String get welcomeBack => "සාදරයෙන් පිළිගනිමු";
  @override String get meditator => "භාවනානුයෝගී";
  @override String get venerableMonk => "ගරු සංඝරත්නය";
  @override String get quickStart => "ඉක්මන් ආරම්භය";
  @override String get aiInterview => "AI සම්මුඛ සාකච්ඡාව";
  @override String get startLearning => "ඉගෙනීම ආරම්භ කරන්න";
  @override String get silentMode => "නිශ්ශබ්ද මාදිලිය";
  @override String get lessonCompleted => "පාඩම සම්පූර්ණයි!";
  @override String get settings => "සැකසුම්";
}

// ── Hi ──
class _AppLocalizationsHi extends _AppLocalizationsEn {
  _AppLocalizationsHi() : super();
  @override String get systemDefault => "सिस्टम डिफ़ॉल्ट";
  @override String get selectLanguage => "भाषा चुनें";
  @override String get language => "भाषा";
  @override String get home => "होम";
  @override String get back => "वापस";
  @override String get continueText => "आगे बढ़ें";
  @override String get retry => "पुनः प्रयास करें";
  @override String get complete => "पूर्ण";
  @override String get welcomeBack => "स्वागत है";
  @override String get meditator => "ध्यानी";
  @override String get venerableMonk => "पूज्य भिक्षु / संघ";
  @override String get startLearning => "सीखना शुरू करें";
  @override String get silentMode => "शांत मोड";
  @override String get lessonCompleted => "पाठ पूरा हुआ!";
  @override String get settings => "सेटिंग्स";
}

// ── My ──
class _AppLocalizationsMy extends _AppLocalizationsEn {
  _AppLocalizationsMy() : super();
  @override String get systemDefault => "စနစ်မူလအတိုင်း";
  @override String get selectLanguage => "ဘာသာစကား ရွေးချယ်ပါ";
  @override String get language => "ဘာသာစကား";
  @override String get home => "ပင်မစာမျက်နှာ";
  @override String get back => "နောက်သို့";
  @override String get continueText => "ဆက်လက်လုပ်ဆောင်ရန်";
  @override String get welcomeBack => "ကြိုဆိုပါသည်";
  @override String get meditator => "တရားအားထုတ်သူ";
  @override String get venerableMonk => "ဆရာတော် / သံဃာတော်";
  @override String get startLearning => "သင်ယူမှု စတင်ရန်";
  @override String get silentMode => "တိတ်ဆိတ်မုဒ်";
  @override String get lessonCompleted => "သင်ခန်းစာ ပြီးဆုံးပါပြီ။";
  @override String get settings => "ဆက်တင်များ";
}

// ── Ar ──
class _AppLocalizationsAr extends _AppLocalizationsEn {
  _AppLocalizationsAr() : super();
  @override String get systemDefault => "حسب النظام";
  @override String get selectLanguage => "اختر اللغة";
  @override String get language => "اللغة";
  @override String get home => "الرئيسية";
  @override String get back => "رجوع";
  @override String get continueText => "متابعة";
  @override String get welcomeBack => "مرحباً بك";
  @override String get startLearning => "بدء التعلم";
  @override String get silentMode => "الوضع الصامت";
  @override String get lessonCompleted => "اكتمل الدرس!";
  @override String get settings => "الإعدادات";
}

// ── Bn ──
class _AppLocalizationsBn extends _AppLocalizationsEn {
  _AppLocalizationsBn() : super();
  @override String get systemDefault => "સિસ્ટમ ડિફૉલ્ટ";
  @override String get selectLanguage => "ভাষা নির্বাচন করুন";
  @override String get language => "ভাষা";
  @override String get home => "হোম";
  @override String get back => "ফিরে যান";
  @override String get continueText => "এগিয়ে যান";
  @override String get welcomeBack => "স্বাগতম";
  @override String get startLearning => "শেখা শুরু করুন";
  @override String get settings => "সেটিংস";
}

// ── Bo ──
class _AppLocalizationsBo extends _AppLocalizationsEn {
  _AppLocalizationsBo() : super();
  @override String get systemDefault => "རྒྱུད་ཁོངས་སྔོན་སྒྲིག";
  @override String get selectLanguage => "སྐད་ཡིག་འདེམས་པ།";
  @override String get language => "སྐད་ཡིག";
  @override String get home => "གཙོ་ཤོག";
  @override String get back => "ཕྱིར་ལོག";
  @override String get continueText => "མཁས་པར་བྱེད་པ།";
  @override String get welcomeBack => "ཕེབས་པར་དགའ་བསུ་ཞུ།";
  @override String get settings => "སྒྲིག་བཀོད།";
}

// ── De ──
class _AppLocalizationsDe extends _AppLocalizationsEn {
  _AppLocalizationsDe() : super();
  @override String get systemDefault => "Systemstandard";
  @override String get selectLanguage => "Sprache auswählen";
  @override String get language => "Sprache";
  @override String get home => "Startseite";
  @override String get back => "Zurück";
  @override String get continueText => "Weiter";
  @override String get welcomeBack => "Willkommen";
  @override String get startLearning => "Lernen starten";
  @override String get silentMode => "Lautlos-Modus";
  @override String get settings => "Einstellungen";
}

// ── Es ──
class _AppLocalizationsEs extends _AppLocalizationsEn {
  _AppLocalizationsEs() : super();
  @override String get systemDefault => "Predeterminado del sistema";
  @override String get selectLanguage => "Seleccionar idioma";
  @override String get language => "Idioma";
  @override String get home => "Inicio";
  @override String get back => "Volver";
  @override String get continueText => "Continuar";
  @override String get welcomeBack => "Bienvenido";
  @override String get startLearning => "Comenzar a aprender";
  @override String get silentMode => "Modo Silencioso";
  @override String get settings => "Configuración";
}

// ── Fr ──
class _AppLocalizationsFr extends _AppLocalizationsEn {
  _AppLocalizationsFr() : super();
  @override String get systemDefault => "Par défaut du système";
  @override String get selectLanguage => "Choisir la langue";
  @override String get language => "Langue";
  @override String get home => "Accueil";
  @override String get back => "Retour";
  @override String get continueText => "Continuer";
  @override String get welcomeBack => "Bienvenue";
  @override String get startLearning => "Commencer l'apprentissage";
  @override String get silentMode => "Mode Silencieux";
  @override String get settings => "Paramètres";
}

// ── Id ──
class _AppLocalizationsId extends _AppLocalizationsEn {
  _AppLocalizationsId() : super();
  @override String get systemDefault => "Default Sistem";
  @override String get selectLanguage => "Pilih Bahasa";
  @override String get language => "Bahasa";
  @override String get home => "Beranda";
  @override String get back => "Kembali";
  @override String get continueText => "Lanjutkan";
  @override String get welcomeBack => "Selamat Datang";
  @override String get startLearning => "Mulai Belajar";
  @override String get silentMode => "Mode Hening";
  @override String get settings => "Pengaturan";
}

// ── It ──
class _AppLocalizationsIt extends _AppLocalizationsEn {
  _AppLocalizationsIt() : super();
  @override String get systemDefault => "Predefinito di sistema";
  @override String get selectLanguage => "Seleziona lingua";
  @override String get language => "Lingua";
  @override String get home => "Home";
  @override String get back => "Indietro";
  @override String get continueText => "Continua";
  @override String get welcomeBack => "Benvenuto";
  @override String get startLearning => "Inizia ad imparare";
  @override String get silentMode => "Modalità Silenziosa";
  @override String get settings => "Impostazioni";
}

// ── Ja ──
class _AppLocalizationsJa extends _AppLocalizationsEn {
  _AppLocalizationsJa() : super();
  @override String get systemDefault => "システム設定に従う";
  @override String get selectLanguage => "言語を選択";
  @override String get language => "言語";
  @override String get home => "ホーム";
  @override String get back => "戻る";
  @override String get continueText => "次へ";
  @override String get welcomeBack => "ようこそ";
  @override String get startLearning => "学習を始める";
  @override String get silentMode => "消音モード";
  @override String get settings => "設定";
}

// ── Km ──
class _AppLocalizationsKm extends _AppLocalizationsEn {
  _AppLocalizationsKm() : super();
  @override String get systemDefault => "តាមប្រព័ន្ធ";
  @override String get selectLanguage => "ជ្រើសរើសភាសា";
  @override String get language => "ភាសា";
  @override String get home => "ទំព័រដើម";
  @override String get back => "ត្រឡប់ក្រោយ";
  @override String get continueText => "បន្ត";
  @override String get welcomeBack => "សូមស្វាគមន៍";
  @override String get startLearning => "ចាប់ផ្តើមរៀន";
  @override String get silentMode => "របៀបស្ងាត់";
  @override String get settings => "ការកំណត់";
}

// ── Ko ──
class _AppLocalizationsKo extends _AppLocalizationsEn {
  _AppLocalizationsKo() : super();
  @override String get systemDefault => "시스템 기본값";
  @override String get selectLanguage => "언어 선택";
  @override String get language => "언어";
  @override String get home => "홈";
  @override String get back => "뒤로";
  @override String get continueText => "계속하기";
  @override String get welcomeBack => "환영합니다";
  @override String get startLearning => "학습 시작";
  @override String get silentMode => "묵언/정적 모드";
  @override String get settings => "설정";
}

// ── Lo ──
class _AppLocalizationsLo extends _AppLocalizationsEn {
  _AppLocalizationsLo() : super();
  @override String get systemDefault => "ຕາມລະບົບ";
  @override String get selectLanguage => "ເລືອກພາສາ";
  @override String get language => "ພາສາ";
  @override String get home => "ໜ້າຫຼັກ";
  @override String get back => "ກັບຄືນ";
  @override String get continueText => "ສືບຕໍ່";
  @override String get welcomeBack => "ຍິນດີຕ້ອນຮັບ";
  @override String get startLearning => "ເລີ່ມຮຽນ";
  @override String get silentMode => "ໂໝດງຽບ";
  @override String get settings => "ການຕັ້ງຄ່າ";
}

// ── Mn ──
class _AppLocalizationsMn extends _AppLocalizationsEn {
  _AppLocalizationsMn() : super();
  @override String get systemDefault => "Системийн үндсэн";
  @override String get selectLanguage => "Хэл сонгох";
  @override String get language => "Хэл";
  @override String get home => "Нүүр";
  @override String get back => "Буцах";
  @override String get continueText => "Үргэлжлүүлэх";
  @override String get welcomeBack => "Тавтай морилно уу";
  @override String get startLearning => "Суралцаж эхлэх";
  @override String get silentMode => "Аниргүй горим";
  @override String get settings => "Тохиргоо";
}

// ── Mr ──
class _AppLocalizationsMr extends _AppLocalizationsEn {
  _AppLocalizationsMr() : super();
  @override String get systemDefault => "सिस्टम डीफॉल्ट";
  @override String get selectLanguage => "भाषा निवडा";
  @override String get language => "भाषा";
  @override String get home => "होम";
  @override String get back => "मागे";
  @override String get continueText => "पुढे जा";
  @override String get welcomeBack => "स्वागत आहे";
  @override String get startLearning => "शिकणे सुरू करा";
  @override String get silentMode => "शांत मोड";
  @override String get settings => "सेटिंग्ज";
}

// ── Pt ──
class _AppLocalizationsPt extends _AppLocalizationsEn {
  _AppLocalizationsPt() : super();
  @override String get systemDefault => "Padrão do Sistema";
  @override String get selectLanguage => "Selecionar Idioma";
  @override String get language => "Idioma";
  @override String get home => "Início";
  @override String get back => "Voltar";
  @override String get continueText => "Continuar";
  @override String get welcomeBack => "Bem-vindo";
  @override String get startLearning => "Começar a Aprender";
  @override String get silentMode => "Modo Silencioso";
  @override String get settings => "Configurações";
}

// ── Ru ──
class _AppLocalizationsRu extends _AppLocalizationsEn {
  _AppLocalizationsRu() : super();
  @override String get systemDefault => "По умолчанию";
  @override String get selectLanguage => "Выберите язык";
  @override String get language => "Язык";
  @override String get home => "Главная";
  @override String get back => "Назад";
  @override String get continueText => "Продолжить";
  @override String get welcomeBack => "Добро пожаловать";
  @override String get startLearning => "Начать обучение";
  @override String get silentMode => "Беззвучный режим";
  @override String get settings => "Настройки";
}

// ── Ta ──
class _AppLocalizationsTa extends _AppLocalizationsEn {
  _AppLocalizationsTa() : super();
  @override String get systemDefault => "அமைப்பின் இயல்புநிலை";
  @override String get selectLanguage => "மொழியைத் தேர்ந்தெடுக்கவும்";
  @override String get language => "மொழி";
  @override String get home => "முகப்பு";
  @override String get back => "பின்செல்";
  @override String get continueText => "தொடரவும்";
  @override String get welcomeBack => "நல்வரவு";
  @override String get startLearning => "கற்றலைத் தொடங்கு";
  @override String get silentMode => "அமைதி பயன்முறை";
  @override String get settings => "அமைப்புகள்";
}

// ── Te ──
class _AppLocalizationsTe extends _AppLocalizationsEn {
  _AppLocalizationsTe() : super();
  @override String get systemDefault => "సిస్టమ్ డిఫాల్ట్";
  @override String get selectLanguage => "భాషను ఎంచుకోండి";
  @override String get language => "భాష";
  @override String get home => "హోమ్";
  @override String get back => "వెనుకకు";
  @override String get continueText => "కొనసాగించండి";
  @override String get welcomeBack => "స్వాగతం";
  @override String get startLearning => "నేర్చుకోవడం ప్రారంభించండి";
  @override String get silentMode => "నిశ్శబ్ద మోడ్";
  @override String get settings => "సెట్టింగ్‌లు";
}

// ── Th ──
class _AppLocalizationsTh extends _AppLocalizationsEn {
  _AppLocalizationsTh() : super();
  @override String get systemDefault => "ตามระบบ";
  @override String get selectLanguage => "เลือกภาษา";
  @override String get language => "ภาษา";
  @override String get home => "หน้าแรก";
  @override String get back => "ย้อนกลับ";
  @override String get continueText => "ดำเนินต่อ";
  @override String get welcomeBack => "ยินดีต้อนรับ";
  @override String get startLearning => "เริ่มการเรียนรู้";
  @override String get silentMode => "โหมดเงียบ";
  @override String get settings => "ตั้งค่า";
}
