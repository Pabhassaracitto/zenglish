import '../models/lesson.dart';
import '../models/user_profile.dart';
import '../models/vocab_item.dart';
import '../models/lesson_flow.dart';
import '../models/situation_variant.dart';
import '../../core/enums/cefr_level.dart';
import '../../core/enums/meditation_stage.dart';
import '../../core/enums/temporal_context.dart';
import '../../core/enums/situation_type.dart';
import '../repositories/lesson_repository.dart';

/// MockDatabase — in-memory data for MVP
/// Swap → FirebaseRepository khi sẵn sàng production
class MockDatabase implements LessonRepository {
  final Map<String, Lesson> _lessons = {};
  final Map<String, UserProfile> _users = {};

  /// Seed sample data
  void seed() {
    _lessons['A2_CH06_L01'] = _buildA2Ch06();
    _users['user_demo_001'] = _buildDemoUser();
  }

  // ─── Lessons ────────────────────────────────

  @override
  Future<Lesson?> getLessonById(String lessonId) async {
    return _lessons[lessonId];
  }

  @override
  Future<List<Lesson>> getLessonsByLevel(CEFRLevel level) async {
    await _simulateDelay();
    return _lessons.values
        .where((l) => l.level == level)
        .toList()
      ..sort((a, b) => a.lessonId.compareTo(b.lessonId));
  }

  @override
  Future<List<Lesson>> getLessonsForUser(UserProfile user) async {
    await _simulateDelay();
    return _lessons.values.where((lesson) {
      return user.canAccessLesson(
        lessonLevel: lesson.level,
        lessonMinStage: lesson.meditationStageMin,
        prerequisites: lesson.prerequisites,
      );
    }).toList();
  }

  @override
  Future<List<Lesson>> searchLessons({
    String? keyword,
    CEFRLevel? level,
    MeditationStage? stage,
  }) async {
    await _simulateDelay();
    return _lessons.values.where((lesson) {
      if (level != null && lesson.level != level) return false;
      if (stage != null && lesson.meditationStageMin != stage) {
        return false;
      }
      if (keyword != null && keyword.isNotEmpty) {
        final kw = keyword.toLowerCase();
        return lesson.titleEn.toLowerCase().contains(kw) ||
            lesson.titleVi.toLowerCase().contains(kw) ||
            lesson.vocabulary.any(
              (v) =>
                  v.english.toLowerCase().contains(kw) ||
                  v.vietnamese.toLowerCase().contains(kw) ||
                  (v.pali?.toLowerCase().contains(kw) ?? false),
            );
      }
      return true;
    }).toList();
  }

  @override
  Future<void> upsertLesson(Lesson lesson) async {
    _lessons[lesson.lessonId] = lesson;
  }

  @override
  Future<void> deleteLesson(String lessonId) async {
    _lessons.remove(lessonId);
  }

  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    await _simulateDelay();
    return _users[userId];
  }

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    _users[profile.userId] = profile;
  }

  @override
  Future<void> markLessonCompleted({
    required String userId,
    required String lessonId,
  }) async {
    final user = _users[userId];
    if (user == null) return;
    _users[userId] = user.copyWith(
      completedLessonIds: [
        ...user.completedLessonIds,
        if (!user.completedLessonIds.contains(lessonId)) lessonId,
      ],
      inProgressLessonIds: user.inProgressLessonIds
          .where((id) => id != lessonId)
          .toList(),
    );
  }

  @override
  Future<void> markLessonInProgress({
    required String userId,
    required String lessonId,
  }) async {
    final user = _users[userId];
    if (user == null) return;
    _users[userId] = user.copyWith(
      inProgressLessonIds: [
        ...user.inProgressLessonIds,
        if (!user.inProgressLessonIds.contains(lessonId)) lessonId,
      ],
    );
  }

  @override
  Future<List<Lesson>> getLessonsNeedingAudio() async {
    return _lessons.values
        .where((l) => l.audioNeededVocab.isNotEmpty)
        .toList();
  }

  @override
  Future<List<String>> getAllPaliTerms() async {
    final terms = <String>{};
    for (final lesson in _lessons.values) {
      for (final vocab in lesson.vocabulary) {
        if (vocab.pali != null) terms.add(vocab.pali!);
      }
    }
    return terms.toList()..sort();
  }

  // ─── Delay simulation ───────────────────────

  Future<void> _simulateDelay() =>
      Future.delayed(const Duration(milliseconds: 80));

  // ─────────────────────────────────────────────
  // SEED DATA — A2_CH06_L01 Ānāpāna
  // ─────────────────────────────────────────────

  Lesson _buildA2Ch06() {
    return Lesson(
      lessonId: 'A2_CH06_L01',
      titleEn: 'Ānāpāna — Reporting Your Breath Meditation',
      titleVi: 'Ānāpāna — Trình Pháp Về Thiền Hơi Thở',
      level: CEFRLevel.a2,
      meditationStageMin: MeditationStage.samathaPreiliminary,
      situationTypes: SituationType.values,
      temporalContexts: TemporalContext.values,
      prerequisites: const [
        'A1_CH01_L01',
        'A1_CH02_L01',
        'A1_CH03_L01',
        'A1_CH04_L01',
        'A1_CH05_L01',
      ],
      monasteryNote:
          'Ānāpāna là đối tượng thiền đầu tiên trong hệ thống Pa-Auk. '
          'Điểm chú ý: vùng xúc chạm tại lỗ mũi / môi trên. '
          'KHÔNG theo dõi hơi thở vào bụng (Mahasi method). '
          "Thiền sư thường hỏi: 'What do you know about the breath?'",
      authenticityReminder:
          'AI Interview cần phân biệt rõ: '
          'kinh nghiệm thật / kỳ vọng / luyện tập giả định.',
      vocabulary: _buildA2Ch06Vocab(),
      lessonFlow: _buildA2Ch06Flow(),
      situationVariants: _buildA2Ch06Variants(),
      patchesApplied: const [],
    );
  }

  List<VocabItem> _buildA2Ch06Vocab() => [
        const VocabItem(
          stt: 1,
          english: 'breath / breathing',
          vietnamese: 'hơi thở',
          pali: 'ānāpāna',
          paliRomanized: 'aa-naa-paa-na',
          exampleEn:
              'Bhante, I am practicing ānāpāna. '
              'I keep my attention on the breath.',
          exampleContext:
              'Câu mở đầu chuẩn khi trình pháp ānāpāna lần đầu với thiền sư.',
          priority: 'High',
          note:
              '[NEEDS AUDIO] — người Việt hay đọc nhầm thành '
              "'a-na-pa-na'. aa = âm dài.",
          needsAudio: true,
        ),
        const VocabItem(
          stt: 2,
          english: 'touching point / contact point',
          vietnamese: 'điểm xúc chạm',
          pali: 'phassa',
          paliRomanized: 'phat-sa',
          exampleEn:
              'Bhante, I keep my mind at the touching point, '
              'below the nostrils.',
          exampleContext:
              "Mô tả vị trí chú ý đúng theo Pa-Auk. "
              "Dùng khi thiền sư hỏi 'Where do you put your attention?'",
          priority: 'High',
          note:
              "[NEEDS AUDIO] — 'touching point' là cụm từ đặc trưng Pa-Auk.",
          needsAudio: true,
        ),
        const VocabItem(
          stt: 3,
          english: 'in-breath',
          vietnamese: 'hơi thở vào',
          pali: 'assāsa',
          paliRomanized: 'at-saa-sa',
          exampleEn:
              'Bhante, I notice the in-breath touching above the upper lip.',
          exampleContext:
              'Dùng khi mô tả cảm giác hơi thở vào tại điểm xúc chạm.',
          priority: 'High',
          note: '[NEEDS AUDIO] — phân biệt rõ với out-breath (passāsa).',
          needsAudio: true,
        ),
        const VocabItem(
          stt: 4,
          english: 'out-breath',
          vietnamese: 'hơi thở ra',
          pali: 'passāsa',
          paliRomanized: 'pat-saa-sa',
          exampleEn: 'Bhante, the out-breath feels longer than the in-breath.',
          exampleContext:
              'Mô tả quan sát đặc điểm hơi thở ra.',
          priority: 'High',
          note:
              '[NEEDS AUDIO] — cặp assāsa / passāsa cần học cùng nhau.',
          needsAudio: true,
        ),
        const VocabItem(
          stt: 5,
          english: 'subtle breath / fine breath',
          vietnamese: 'hơi thở tế / hơi thở vi tế',
          pali: 'sukhumā assāsa',
          paliRomanized: 'su-ku-maa at-saa-sa',
          exampleEn:
              'Bhante, the breath has become very subtle. '
              'I can barely feel it.',
          exampleContext:
              'Dùng khi hơi thở trở nên rất nhẹ, khó nhận ra. '
              'Giai đoạn quan trọng trong Pa-Auk ānāpāna.',
          priority: 'High',
          note:
              "[NEEDS AUDIO] — KHÔNG nói 'I lost the breath'. "
              "Chỉ mô tả: 'The breath has become very subtle.'",
          needsAudio: true,
        ),
        const VocabItem(
          stt: 6,
          english: 'wandering mind / distracted',
          vietnamese: 'tâm phóng dật / tâm tán loạn',
          pali: 'vikkhitta citta',
          paliRomanized: 'vik-kit-ta chit-ta',
          exampleEn:
              'Bhante, my mind wanders a lot. '
              'Especially in the evening sitting.',
          exampleContext:
              'Mô tả vấn đề phổ biến nhất trong giai đoạn đầu.',
          priority: 'High',
          note:
              "[NEEDS AUDIO] — tốt hơn 'I cannot concentrate': "
              "nói cụ thể 'My mind wanders to [thinking / planning].'",
          needsAudio: true,
        ),
        const VocabItem(
          stt: 7,
          english: 'nimitta / meditation sign',
          vietnamese: 'tướng thiền / quang tướng',
          pali: 'nimitta',
          paliRomanized: 'ni-mit-ta',
          exampleEn:
              'Bhante, I think something appeared — a light in front of me. '
              'Is that the nimitta?',
          exampleContext:
              'Khi thiền sinh lần đầu thấy dấu hiệu. '
              'Luôn hỏi lại thiền sư — không tự xác nhận.',
          priority: 'High',
          note:
              "[NEEDS AUDIO] — giữ 'nimitta' trong câu tiếng Anh. "
              "KHÔNG dịch thành 'sign' một mình.",
          needsAudio: true,
        ),
        const VocabItem(
          stt: 8,
          english: 'concentration / stillness of mind',
          vietnamese: 'tâm định / sự tập trung',
          pali: 'samādhi',
          paliRomanized: 'sa-maa-di',
          exampleEn:
              'Bhante, today my samādhi feels better. '
              'I could stay with the breath for longer.',
          exampleContext:
              "Mô tả chất lượng định tâm. Dùng 'samādhi' trực tiếp.",
          priority: 'High',
          note:
              "[NEEDS AUDIO] — KHÔNG dùng 'my focus is good' "
              "(quá chung chung, không có nghĩa kỹ thuật).",
          needsAudio: true,
        ),
      ];

  LessonFlow _buildA2Ch06Flow() {
    return LessonFlow(
      input: InputPhase(
        title: 'Nghe & Nhận Biết',
        description:
            'Thiền sinh nghe các đoạn hội thoại trình pháp thật — '
            'từ Situation A đến E.',
        sampleDialogues: [
          SampleDialogue(
            context: 'Situation B — Lần đầu trình pháp về ānāpāna',
            lines: const [
              'Yogi: Bhante, this is my first interview about the breath.',
              "Teacher: Yes. Tell me — what do you know about the breath?",
              'Yogi: Bhante, I keep my attention at the touching point, '
                  'below the nostrils. '
                  'I notice the in-breath and the out-breath.',
              "Teacher: Good. Is the breath long or short?",
              "Yogi: Bhante, sometimes long, sometimes short. I am not sure.",
              "Teacher: Just know whatever is there. Go back and sit.",
            ],
          ),
          SampleDialogue(
            context: 'Situation D — Hơi thở trở nên tế',
            lines: const [
              'Yogi: Bhante, the breath has become very subtle. '
                  'I can barely feel it.',
              "Teacher: That is good. Don't try to make it stronger. "
                  "Just know it is there.",
              "Yogi: Bhante, sometimes I cannot find it at all.",
              "Teacher: If you cannot find it, wait. It will come back. "
                  "Just keep your attention at the touching point.",
            ],
          ),
        ],
      ),
      pattern: PatternPhase(
        title: 'Cấu Trúc Câu Cốt Lõi',
        description:
            '5 mẫu câu thiết yếu cho trình pháp ānāpāna.',
        corePatterns: [
          CorePattern(
            patternId: 'P1',
            function: 'Mô tả điểm chú ý',
            template: 'Bhante, I keep my attention at [location].',
            examples: const [
              'Bhante, I keep my attention at the touching point, '
                  'below the nostrils.',
              'Bhante, I keep my attention at the area '
                  'above the upper lip.',
            ],
            monasteryEnglishNote:
                "Thiền sư Pa-Auk hay xác nhận bằng 'Good' "
                "hoặc 'Yes, that is correct.'",
          ),
          CorePattern(
            patternId: 'P2',
            function: 'Mô tả đặc điểm hơi thở',
            template: 'Bhante, the breath is [adjective].',
            examples: const [
              'Bhante, the breath is long and smooth.',
              'Bhante, the breath is short and difficult to follow.',
              'Bhante, the breath has become very subtle.',
            ],
          ),
          CorePattern(
            patternId: 'P3',
            function: 'Mô tả vấn đề tâm',
            template:
                'Bhante, my mind [problem]. I [action taken].',
            examples: const [
              'Bhante, my mind wanders a lot. '
                  'I try to bring it back to the breath.',
              'Bhante, my mind is sleepy. '
                  'I cannot stay with the breath.',
              'Bhante, my mind keeps thinking. I cannot stop it.',
            ],
            monasteryEnglishNote:
                "Không cần nói 'I am sorry' khi báo cáo vấn đề. "
                'Chỉ mô tả thật.',
          ),
          CorePattern(
            patternId: 'P4',
            function: 'Hỏi về nimitta / dấu hiệu thiền',
            template:
                'Bhante, I noticed [description]. Is that the nimitta?',
            examples: const [
              'Bhante, I noticed a light in front of me. '
                  'Is that the nimitta?',
              'Bhante, I saw something white, like a small cloud. '
                  'Is that the nimitta?',
              'Bhante, I felt a warm feeling at the touching point. '
                  'Is that normal?',
            ],
            monasteryEnglishNote:
                'Luôn hỏi thiền sư — không tự xác nhận đây là nimitta.',
          ),
          CorePattern(
            patternId: 'P5',
            function: 'Mô tả buổi thiền tổng quát',
            template:
                'Bhante, [time reference], my sitting was [quality].',
            examples: const [
              'Bhante, this morning, my sitting was quite good. '
                  'The mind was still.',
              'Bhante, last night, my sitting was difficult. '
                  'There was a lot of thinking.',
              'Bhante, yesterday, the breath became subtle '
                  'and I lost it.',
            ],
          ),
        ],
      ),
      guided: GuidedPhase(
        title: 'Luyện Tập Có Hỗ Trợ',
        description:
            'AI Interview mô phỏng thiền sư hỏi — người dùng trả lời.',
        interviewSteps: [
          InterviewStep(
            step: 1,
            aiPrompt:
                'Tell me — are you reporting a real experience, '
                'or practicing a scenario?',
            purpose: 'Authenticity check.',
          ),
          InterviewStep(
            step: 2,
            aiPrompt:
                'Good. Now — where do you keep your attention '
                'when you meditate?',
            purpose: 'Mô tả điểm chú ý.',
            expectedPattern: 'P1',
            ifIncorrect:
                "Try: 'I keep my attention at the touching point, "
                "below the nostrils.'",
          ),
          InterviewStep(
            step: 3,
            aiPrompt:
                'Tell me about the breath. '
                'Is it long or short? Rough or smooth?',
            purpose: 'Dùng tính từ mô tả hơi thở.',
            expectedPattern: 'P2',
          ),
          InterviewStep(
            step: 4,
            aiPrompt:
                'Is there any problem with the mind? '
                'Thinking? Sleepiness?',
            purpose: 'Mô tả trạng thái tâm.',
            expectedPattern: 'P3',
          ),
          InterviewStep(
            step: 5,
            aiPrompt:
                'Has anything appeared at the touching point — '
                'any light, any feeling, anything unusual?',
            purpose: 'Mô tả / hỏi về nimitta.',
            expectedPattern: 'P4',
            authenticityNote:
                "Nếu chưa có kinh nghiệm: "
                "'I have not noticed anything yet.' — hợp lệ.",
          ),
        ],
      ),
      output: OutputPhase(
        title: 'Trình Pháp Độc Lập',
        description:
            'Người dùng tự tạo một đoạn trình pháp 5-7 câu '
            'về buổi thiền ānāpāna.',
        promptForUser:
            'Imagine you are sitting in front of your teacher. '
            'Report your ānāpāna practice in 5-7 sentences. '
            'Include: where you put your attention, what the breath was like, '
            'any problem with the mind, and anything unusual you noticed.',
        evaluationCriteria: const [
          'Có mô tả điểm chú ý đúng (touching point)',
          'Có mô tả đặc điểm hơi thở',
          'Có mô tả trạng thái tâm',
          'Câu cuối có thể là câu hỏi — hoàn toàn tự nhiên trong trình pháp thật',
        ],
        sampleOutputs: const {
          'A2':
              'Bhante, I have been practicing ānāpāna for one week. '
              'I keep my attention at the touching point, below the nostrils. '
              'The breath is sometimes long, sometimes short. '
              'My mind wanders quite often — especially in the evening sitting. '
              'I bring it back to the breath when I notice it has gone. '
              'I have not seen any nimitta yet. Is that okay, Bhante?',
        },
      ),
    );
  }

  Map<SituationType, SituationVariant> _buildA2Ch06Variants() => {
        SituationType.preparation: SituationVariant(
          situationType: SituationType.preparation,
          temporalContext: TemporalContext.future,
          description:
              'Người dùng chưa bắt đầu thiền ānāpāna — '
              'đang chuẩn bị ngôn ngữ trước khi vào khóa thiền.',
          contextEn:
              'You have not started yet. '
              'You want to prepare what to say in your first interview.',
          contextVi:
              'Bạn chưa bắt đầu. Bạn muốn chuẩn bị ngôn ngữ '
              'cho buổi trình pháp đầu tiên.',
          sampleSentences: const [
            'Bhante, I have not started yet. '
                'Can you please give me the instruction?',
            'Bhante, I understand I should keep my attention '
                'at the touching point. Is that correct?',
            'Bhante, this is my first time practicing ānāpāna. '
                'I am not sure what I should notice.',
            'Bhante, how long should I sit in each session?',
          ],
          vocabularyFocus: const [
            'ānāpāna',
            'touching point',
            'in-breath',
            'out-breath',
          ],
          monasteryNote:
              "Ở nhiều thiền viện Pa-Auk, buổi đầu tiên thiền sư sẽ "
              "cho instruction ngắn rồi bảo đi ngồi. "
              "Câu hay nhất lúc này: 'Bhante, I understand. Thank you.'",
        ),
        SituationType.firstAppearance: SituationVariant(
          situationType: SituationType.firstAppearance,
          temporalContext: TemporalContext.present,
          description:
              'Lần đầu trình pháp sau khi đã thực hành vài buổi. '
              'Tâm chưa ổn định, hơi thở thô, nhiều phóng tâm.',
          contextEn:
              'You have practiced for three days. '
              'Today is your first interview.',
          contextVi:
              'Bạn đã thực hành được ba ngày. '
              'Hôm nay là buổi trình pháp đầu tiên.',
          sampleSentences: const [
            'Bhante, I keep my attention at the touching point, '
                'below the nostrils.',
            'Bhante, the breath is rough and uneven.',
            'Bhante, my mind wanders a lot. '
                'I notice thoughts about daily life.',
            'Bhante, I try to bring my mind back to the breath '
                'when it wanders.',
            'Bhante, I am not sure if I am doing it correctly.',
          ],
          typicalTeacherResponses: const [
            "Just keep your attention there. Don't worry about the thinking.",
            'Go back and sit. Try again.',
            'That is normal. Just know the breath.',
          ],
          vocabularyFocus: const [
            'wandering mind',
            'in-breath',
            'out-breath',
            'touching point',
          ],
        ),
        SituationType.stableTracking: SituationVariant(
          situationType: SituationType.stableTracking,
          temporalContext: TemporalContext.present,
          description:
              'Sau vài ngày / vài tuần — tâm bắt đầu ổn định hơn.',
          contextEn:
              'You have been practicing for two weeks. '
              'Samādhi is improving.',
          contextVi:
              'Bạn đã thực hành hai tuần. Định bắt đầu ổn định hơn.',
          sampleSentences: const [
            'Bhante, the mind is more stable now. There is less wandering.',
            'Bhante, the breath has become longer and smoother.',
            'Bhante, I can stay with the breath for longer periods now.',
            'Bhante, sometimes I notice a warm feeling at the touching point.',
            'Bhante, sometimes there is a faint light. '
                'I am not sure what it is.',
          ],
          vocabularyFocus: const [
            'samādhi',
            'nimitta',
            'subtle breath',
            'long breath',
          ],
          monasteryNote:
              'Khi thiền sư nghe về ánh sáng sơ khởi, thường sẽ hỏi '
              'về màu sắc, hình dạng, độ ổn định.',
        ),
        SituationType.disappearedChanged: SituationVariant(
          situationType: SituationType.disappearedChanged,
          temporalContext: TemporalContext.present,
          description:
              'Samādhi đã tốt nhưng hôm nay mất — hoặc nimitta biến mất.',
          contextEn:
              'Your samādhi was good last week but today it has dropped.',
          contextVi:
              'Định tốt tuần trước nhưng hôm nay tụt. '
              'Nimitta đã biến mất.',
          sampleSentences: const [
            'Bhante, this morning the breath became very subtle. '
                'I could not find it.',
            'Bhante, the nimitta appeared yesterday but today it is gone.',
            'Bhante, my samādhi was good last week '
                'but this week the mind is restless again.',
            'Bhante, I am not sure what happened. The practice changed.',
            'Bhante, there is more thinking today. I do not know why.',
          ],
          typicalTeacherResponses: const [
            "That is normal. Just go back and sit.",
            "If the breath is subtle, just wait. "
                "Keep your attention at the touching point.",
            "The nimitta will come back. Don't look for it. "
                "Just know the breath.",
          ],
          monasteryNote:
              'Mất nimitta hoặc mất định là chuyện thường. '
              "KHÔNG nói 'I failed'. Chỉ mô tả những gì xảy ra.",
        ),
        SituationType.pastFuture: SituationVariant(
          situationType: SituationType.pastFuture,
          temporalContext: TemporalContext.pastAndFuture,
          description:
              'Kể lại kinh nghiệm ānāpāna của khóa thiền trước, '
              'hoặc hỏi về bước tiếp theo.',
          contextEn:
              'You are talking about your last retreat. '
              'Or asking about what comes next.',
          contextVi:
              'Bạn đang kể về khóa thiền trước. '
              'Hoặc hỏi về bước tiếp theo.',
          sampleSentences: const [],
          sampleSentencesPast: const [
            'In my last retreat, I practiced ānāpāna for two weeks.',
            'During that retreat, I noticed a light — '
                'the nimitta appeared on the fifth day.',
            'At that time, my mind was quite restless in the first few days.',
            'After one week, the breath became subtle '
                'and I was not sure what to do.',
            'The teacher told me to just wait at the touching point.',
          ],
          sampleSentencesFuture: const [
            'Bhante, after the nimitta is stable, what should I do next?',
            'Bhante, how will I know when I am ready to move to the next step?',
            'Bhante, is it normal that the breath disappears completely?',
            'Bhante, what should I do if the nimitta changes color?',
          ],
          monasteryNote:
              '[NEEDS REVIEW] — câu hỏi về màu nimitta và tiến trình '
              'tiếp theo (vào jhāna) là chủ đề của cấp B1/C1. '
              'Ở A2 chỉ cần biết cách hỏi — '
              'không cần biết câu trả lời chi tiết.',
        ),
      };

  // ─── Demo User ───────────────────────────────

  UserProfile _buildDemoUser() {
    return UserProfile(
      userId: 'user_demo_001',
      displayName: 'Thiền sinh Demo',
      languageLevel: CEFRLevel.a2,
      meditationStage: MeditationStage.samathaPreiliminary,
      paliKnowledgeLevel: 2,
      completedLessonIds: const [
        'A1_CH01_L01',
        'A1_CH02_L01',
        'A1_CH03_L01',
        'A1_CH04_L01',
        'A1_CH05_L01',
      ],
      inProgressLessonIds: const ['A2_CH06_L01'],
      preferredTradition: 'Pa-Auk',
      isMonk: false,
      createdAt: DateTime(2025, 1, 1),
      lastActiveAt: DateTime.now(),
    );
  }
}
