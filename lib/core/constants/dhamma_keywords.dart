/// Tập trung từ khoá Dhamma dùng cho Mock Engine
/// Tổ chức theo 5 nhóm phân tích
/// Source: Pa-Auk methodology + Theravāda standard
abstract class DhammaKeywords {
  // ─────────────────────────────────────────────
  // NHÓM 1: Opening (Cách mở đầu)
  // ─────────────────────────────────────────────

  static const List<String> respectfulOpenings = [
    'bhante',
    'venerable sir',
    'venerable',
    'sayadaw',
    'ajahn',
    'luang por',
  ];

  // ─────────────────────────────────────────────
  // NHÓM 2: Object — Đề mục thiền
  // ─────────────────────────────────────────────

  static const List<String> samathaObjects = [
    'breath',
    'breathing',
    'anapana',
    'ānāpāna',
    'nimitta',
    'kasina',
    'kasiṇa',
    'metta',
    'mettā',
    'light',
    'sign',
    'object',
    'subject',
    'in-breath',
    'out-breath',
    'in breath',
    'out breath',
    'inhalation',
    'exhalation',
  ];

  static const List<String> vipassanaObjects = [
    'arising',
    'passing',
    'impermanence',
    'anicca',
    'suffering',
    'dukkha',
    'non-self',
    'anatta',
    'anattā',
    'nama',
    'nāma',
    'rupa',
    'rūpa',
    'nama-rupa',
    'nāma-rūpa',
    'mind and matter',
    'mental',
    'material',
    'characteristic',
    'three characteristics',
    'tilakkhana',
    'tilakkhaṇa',
  ];

  /// Tất cả đề mục (samatha + vipassanā)
  static List<String> get allObjects => [
        ...samathaObjects,
        ...vipassanaObjects,
      ];

  // ─────────────────────────────────────────────
  // NHÓM 3: Location — Điểm chú ý Pa-Auk
  // ─────────────────────────────────────────────

  static const List<String> paAukLocations = [
    'nostril',
    'nostrils',
    'upper lip',
    'lip',
    'touching point',
    'contact point',
    'touch',
    'phassa',
    'tip of the nose',
    'nose',
    'below the nose',
    'above the lip',
  ];

  // ─────────────────────────────────────────────
  // NHÓM 4: Difficulty / Nīvaraṇa
  // ─────────────────────────────────────────────

  static const List<String> hindranceWords = [
    'sleepy',
    'sleepiness',
    'drowsy',
    'drowsiness',
    'dull',
    'heavy',
    'thina',
    'thīna',
    'middha',
    'sloth',
    'torpor',
    'restless',
    'restlessness',
    'agitated',
    'agitation',
    'uddhacca',
    'thinking',
    'thought',
    'thoughts',
    'wandering',
    'distracted',
    'doubt',
    'vicikiccha',
    'vicikicchā',
    'desire',
    'craving',
    'kamacchanda',
    'kāmacchanda',
    'aversion',
    'anger',
    'ill will',
    'vyapada',
    'vyāpāda',
  ];

  static const List<String> difficultyPhrases = [
    'mind wanders',
    'mind wandered',
    'keep thinking',
    'cannot focus',
    "can't focus",
    'not stable',
    'unstable',
    'difficult',
    'hard to',
    'problem with',
    'trouble with',
    'cannot sit',
    "can't sit",
    'pain',
    'ache',
    'uncomfortable',
    'distracted',
  ];

  // ─────────────────────────────────────────────
  // NHÓM 5: Semantic Hints — Gợi ý trạng thái
  // ─────────────────────────────────────────────

  static const Map<List<String>, String> semanticHintMap = {};

  // ─── Samatha indicators ──────────────────────

  /// Dấu hiệu có thể đang tiến vào định
  static const List<String> stillnessIndicators = [
    'quiet',
    'still',
    'calm',
    'peaceful',
    'settled',
    'stable',
    'steady',
    'clear',
    'bright',
    'light',
    'luminous',
    'pleasant',
    'smooth',
    'long breath',
    'deep breath',
  ];

  /// Dấu hiệu nimitta sơ khởi (uggaha nimitta)
  static const List<String> uggahaNimittaIndicators = [
    'white',
    'gray',
    'grey',
    'smoke',
    'smoke-like',
    'cotton',
    'wool',
    'cloud',
    'cloudy',
    'blurry',
    'unclear',
    'rough nimitta',
    'moving',
    'changing shape',
    'unstable light',
    'faint light',
    'appeared',
    'something appeared',
    'saw something',
  ];

  /// Dấu hiệu nimitta tinh tế (paṭibhāga nimitta)
  static const List<String> patibhagaNimittaIndicators = [
    'very bright',
    'very clear',
    'sharp',
    'stable nimitta',
    'steady nimitta',
    'bright nimitta',
    'crystal',
    'transparent',
    'pure',
    'permanent',
    'not moving',
    'fixed',
    'staying',
  ];

  /// Dấu hiệu jhāna / absorption
  static const List<String> jhanaIndicators = [
    'absorbed',
    'absorption',
    'jhana',
    'jhāna',
    'very deep',
    'very still',
    'no thinking',
    'no thoughts',
    'mind stayed',
    'stayed with',
    'could not move',
    'long time',
    'did not notice time',
    'time passed',
    'floating',
    'rapture',
    'piti',
    'pīti',
    'joy',
    'bliss',
    'sukha',
  ];

  /// Dấu hiệu upacāra samādhi / cận định
  static const List<String> upacamaIndicators = [
    'very quiet',
    'very calm',
    'very still',
    'almost',
    'close to',
    'nearly',
    'access',
    'upacara',
    'upacāra',
    'nimitta appeared',
    'nimitta is stable',
  ];

  // ─── Vipassanā indicators ─────────────────────

  /// Dấu hiệu đang quán sát tam đặc tướng
  static const List<String> vipassanaIndicators = [
    'arising',
    'passing away',
    'arise and pass',
    'coming and going',
    'impermanent',
    'changing',
    'not permanent',
    'no control',
    'no self',
    'not mine',
    'not me',
    'just happening',
    'just process',
    'cause and effect',
    'conditioned',
  ];

  // ─── Physical difficulty ──────────────────────

  static const List<String> physicalDifficulty = [
    'knee',
    'back',
    'lower back',
    'shoulder',
    'neck',
    'pain',
    'ache',
    'numb',
    'numbness',
    'sore',
    'fever',
    'headache',
    'dizzy',
    'tired',
    'exhausted',
  ];

  // ─── Question indicators ──────────────────────

  static const List<String> questionIndicators = [
    'is that',
    'is this',
    'what should',
    'how should',
    'should i',
    'am i',
    'is it',
    'what do',
    'what does',
    'why is',
    'please',
    '?',
  ];
}
