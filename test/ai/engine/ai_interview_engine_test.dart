/// test/ai/engine/ai_interview_engine_test.dart
/// 
/// Unit tests cho AIInterviewEngine với mock OpenAIService
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:zenglish/ai/engine/ai_interview_engine.dart';
import 'package:zenglish/ai/services/openai_service.dart';
import 'package:zenglish/ai/models/interview_feedback.dart';
import 'package:zenglish/data/models/lesson.dart';
import 'package:zenglish/data/models/lesson_flow.dart';
import 'package:zenglish/core/enums/cefr_level.dart';
import 'package:zenglish/core/enums/meditation_stage.dart';
import 'package:zenglish/core/enums/situation_type.dart';
import 'package:zenglish/core/enums/temporal_context.dart';

// ─── Mock ────────────────────────────────────

class MockOpenAIService extends Mock implements OpenAIService {}

// ─── Fixture ─────────────────────────────────

const _validJsonResponse = '''
{
  "isAuthentic": true,
  "overallScore": 82,
  "checkResults": [
    {
      "checkName": "Opening",
      "checkNameVi": "Lời Mở Đầu",
      "passed": true,
      "description": "Good opening with Bhante.",
      "tip": "Perfect opening phrase.",
      "detectedValue": "Bhante, may I report"
    },
    {
      "checkName": "MeditationObject",
      "checkNameVi": "Đối Tượng Thiền",
      "passed": true,
      "description": "Breath at nostrils mentioned.",
      "tip": "Clear object.",
      "detectedValue": "breath at nostrils"
    },
    {
      "checkName": "LocationSensation",
      "checkNameVi": "Vị Trí / Cảm Giác",
      "passed": true,
      "description": "Cool sensation described.",
      "tip": "Good detail.",
      "detectedValue": "cool"
    },
    {
      "checkName": "Difficulties",
      "checkNameVi": "Khó Khăn",
      "passed": false,
      "description": "No difficulty mentioned.",
      "tip": "Mention any distractions.",
      "detectedValue": null
    },
    {
      "checkName": "Question",
      "checkNameVi": "Câu Hỏi / Xin Chỉ Dạy",
      "passed": true,
      "description": "Has question.",
      "tip": "Good specific question.",
      "detectedValue": "what should I do?"
    }
  ],
  "missingPoints": ["Khó Khăn"],
  "presentPoints": ["Lời Mở Đầu", "Đối Tượng Thiền", "Vị Trí / Cảm Giác", "Câu Hỏi / Xin Chỉ Dạy"],
  "languageFeedback": "Clear and structured report.",
  "semanticHintType": "stillnessSign",
  "encouragement": "Well done!",
  "suggestedNextStep": "Add a difficulty next time.",
  "detectedKeywords": ["breath", "nostrils", "cool"]
}
''';

// ─── Tests ────────────────────────────────────

void main() {
  late MockOpenAIService mockService;
  late AIInterviewEngine engine;
  late Lesson testLesson;

  setUp(() {
    mockService = MockOpenAIService();
    engine = AIInterviewEngine(openAIService: mockService);

    testLesson = _buildTestLesson();
  });

  group('analyzeReport — success', () {
    test('parses valid JSON response correctly', () async {
      when(
        () => mockService.analyzeReport(
          userTranscript: any(named: 'userTranscript'),
          currentLesson: any(named: 'currentLesson'),
        ),
      ).thenAnswer((_) async => _validJsonResponse);

      final result = await engine.analyzeReport(
        userTranscript: 'Bhante, may I report my sitting?',
        currentLesson: testLesson,
      );

      expect(result.isAuthentic, isTrue);
      expect(result.overallScore, equals(82));
      expect(result.checkResults.length, equals(5));
      expect(result.checkResults[0].passed, isTrue); // Opening
      expect(result.checkResults[3].passed, isFalse); // Difficulties
      expect(result.semanticHint.hasContent, isTrue);
      expect(result.rawTranscript, isNotEmpty); // Injected by engine
    });

    test('rawTranscript is injected from input, not AI', () async {
      when(
        () => mockService.analyzeReport(
          userTranscript: any(named: 'userTranscript'),
          currentLesson: any(named: 'currentLesson'),
        ),
      ).thenAnswer((_) async => _validJsonResponse);

      const input = 'My test transcript';
      final result = await engine.analyzeReport(
        userTranscript: input,
        currentLesson: testLesson,
      );

      expect(result.rawTranscript, equals(input));
    });
  });

  group('analyzeReport — empty transcript', () {
    test('returns empty feedback without calling service', () async {
      final result = await engine.analyzeReport(
        userTranscript: '   ',
        currentLesson: testLesson,
      );

      expect(result.isAuthentic, isFalse);
      expect(result.overallScore, equals(0));
      verifyNever(
        () => mockService.analyzeReport(
          userTranscript: any(named: 'userTranscript'),
          currentLesson: any(named: 'currentLesson'),
        ),
      );
    });
  });

  group('analyzeReport — error handling', () {
    test('returns safe feedback on timeout', () async {
      when(
        () => mockService.analyzeReport(
          userTranscript: any(named: 'userTranscript'),
          currentLesson: any(named: 'currentLesson'),
        ),
      ).thenThrow(const OpenAITimeoutError());

      final result = await engine.analyzeReport(
        userTranscript: 'Some report',
        currentLesson: testLesson,
      );

      expect(result.isAuthentic, isFalse);
      expect(result.overallScore, equals(0));
    });

    test('returns specific feedback on rate limit (429)', () async {
      when(
        () => mockService.analyzeReport(
          userTranscript: any(named: 'userTranscript'),
          currentLesson: any(named: 'currentLesson'),
        ),
      ).thenThrow(
        const OpenAIHttpError(statusCode: 429, detail: 'Rate limit exceeded'),
      );

      final result = await engine.analyzeReport(
        userTranscript: 'Some report',
        currentLesson: testLesson,
      );

      expect(result.isAuthentic, isFalse);
    });

    test('returns specific feedback on 401 unauthorized', () async {
      when(
        () => mockService.analyzeReport(
          userTranscript: any(named: 'userTranscript'),
          currentLesson: any(named: 'currentLesson'),
        ),
      ).thenThrow(
        const OpenAIHttpError(statusCode: 401, detail: 'Unauthorized'),
      );

      final result = await engine.analyzeReport(
        userTranscript: 'Some report',
        currentLesson: testLesson,
      );

      expect(result.isAuthentic, isFalse);
    });
  });
}

Lesson _buildTestLesson() {
  // Minimal lesson for testing
  return Lesson(
    lessonId: 'A2_CH06_L01',
    titleEn: 'Test Lesson',
    titleVi: 'Bài Test',
    level: CEFRLevel.a2,
    meditationStageMin: MeditationStage.any,
    situationTypes: const [],
    temporalContexts: const [],
    prerequisites: const [],
    monasteryNote: '',
    authenticityReminder: 'Test reminder',
    vocabulary: const [],
    lessonFlow: LessonFlow.empty(),
    situationVariants: const {},
  );
}
