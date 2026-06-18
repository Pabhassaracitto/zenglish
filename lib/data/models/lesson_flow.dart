/// Cấu trúc 4 giai đoạn của mỗi bài học
class LessonFlow {
  const LessonFlow({
    required this.input,
    required this.pattern,
    required this.guided,
    required this.output,
  });

  final InputPhase input;
  final PatternPhase pattern;
  final GuidedPhase guided;
  final OutputPhase output;

  factory LessonFlow.fromJson(Map<String, dynamic> json) {
    return LessonFlow(
      input: InputPhase.fromJson(
        json['input'] as Map<String, dynamic>,
      ),
      pattern: PatternPhase.fromJson(
        json['pattern'] as Map<String, dynamic>,
      ),
      guided: GuidedPhase.fromJson(
        json['guided'] as Map<String, dynamic>,
      ),
      output: OutputPhase.fromJson(
        json['output'] as Map<String, dynamic>,
      ),
    );
  }

  factory LessonFlow.empty() {
    return const LessonFlow(
      input: InputPhase(
        title: '',
        description: '',
        sampleDialogues: [],
      ),
      pattern: PatternPhase(
        title: '',
        description: '',
        corePatterns: [],
      ),
      guided: GuidedPhase(
        title: '',
        description: '',
        interviewSteps: [],
      ),
      output: OutputPhase(
        title: '',
        description: '',
        promptForUser: '',
        evaluationCriteria: [],
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'input': input.toJson(),
        'pattern': pattern.toJson(),
        'guided': guided.toJson(),
        'output': output.toJson(),
      };
}

// ─────────────────────────────────────────────
// INPUT PHASE
// ─────────────────────────────────────────────

class InputPhase {
  const InputPhase({
    required this.title,
    required this.description,
    required this.sampleDialogues,
    this.audioUrl, // ← THÊM FIELD NÀY
  });

  final String title;
  final String description;
  final List<SampleDialogue> sampleDialogues;
  final String? audioUrl;

  factory InputPhase.fromJson(Map<String, dynamic> json) {
    return InputPhase(
      title: json['title'] as String,
      description: json['description'] as String,
      sampleDialogues: (json['sample_dialogues'] as List<dynamic>? ?? [])
          .map((e) => SampleDialogue.fromJson(e as Map<String, dynamic>))
          .toList(),
      audioUrl: json['audio_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'sample_dialogues': sampleDialogues.map((e) => e.toJson()).toList(),
    if (audioUrl != null) 'audio_url': audioUrl,
  };
}

class SampleDialogue {
  const SampleDialogue({
    required this.context,
    required this.lines,
  });

  final String context;
  final List<String> lines;

  factory SampleDialogue.fromJson(Map<String, dynamic> json) {
    return SampleDialogue(
      context: json['context'] as String,
      lines: List<String>.from(json['dialogue'] as List<dynamic>? ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'context': context,
        'dialogue': lines,
      };
}

// ─────────────────────────────────────────────
// PATTERN PHASE
// ─────────────────────────────────────────────

class PatternPhase {
  const PatternPhase({
    required this.title,
    required this.description,
    required this.corePatterns,
  });

  final String title;
  final String description;
  final List<CorePattern> corePatterns;

  factory PatternPhase.fromJson(Map<String, dynamic> json) {
    return PatternPhase(
      title: json['title'] as String,
      description: json['description'] as String,
      corePatterns: (json['core_patterns'] as List<dynamic>? ?? [])
          .map((e) => CorePattern.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'core_patterns': corePatterns.map((e) => e.toJson()).toList(),
      };
}

class CorePattern {
  const CorePattern({
    required this.patternId,
    required this.function,
    required this.template,
    required this.examples,
    this.monasteryEnglishNote,
  });

  final String patternId;
  final String function;
  final String template;
  final List<String> examples;
  final String? monasteryEnglishNote;

  factory CorePattern.fromJson(Map<String, dynamic> json) {
    return CorePattern(
      patternId: json['pattern_id'] as String,
      function: json['function'] as String,
      template: json['template'] as String,
      examples: List<String>.from(json['examples'] as List<dynamic>? ?? []),
      monasteryEnglishNote: json['monastery_english_note'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'pattern_id': patternId,
        'function': function,
        'template': template,
        'examples': examples,
        'monastery_english_note': monasteryEnglishNote,
      };
}

// ─────────────────────────────────────────────
// GUIDED PHASE
// ─────────────────────────────────────────────

class GuidedPhase {
  const GuidedPhase({
    required this.title,
    required this.description,
    required this.interviewSteps,
  });

  final String title;
  final String description;
  final List<InterviewStep> interviewSteps;

  factory GuidedPhase.fromJson(Map<String, dynamic> json) {
    // Support both 'interview_steps' (assets) and 'ai_interview_sequence' (legacy TASK files)
    final stepsData = (json['interview_steps'] as List<dynamic>?) ??
        (json['ai_interview_sequence'] as List<dynamic>?) ??
        [];
    
    return GuidedPhase(
      title: json['title'] as String,
      description: json['description'] as String,
      interviewSteps: stepsData
          .map((e) => InterviewStep.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'interview_steps': interviewSteps.map((e) => e.toJson()).toList(),
      };
}

class InterviewStep {
  const InterviewStep({
    required this.step,
    required this.aiPrompt,
    required this.purpose,
    this.expectedPattern,
    this.expectedAnswerType,
    this.ifIncorrect,
    this.authenticityNote,
  });

  final int step;
  final String aiPrompt;
  final String purpose;
  final String? expectedPattern;
  final String? expectedAnswerType;
  final String? ifIncorrect;
  final String? authenticityNote;

  factory InterviewStep.fromJson(Map<String, dynamic> json) {
    return InterviewStep(
      step: json['step'] as int? ?? 0,
      aiPrompt: (json['ai_prompt'] as String?) ?? '',
      purpose: (json['purpose'] as String?) ?? '',
      expectedPattern: json['expected_pattern'] as String?,
      expectedAnswerType: json['expected_answer_type'] as String?,
      ifIncorrect: json['if_incorrect'] as String?,
      authenticityNote: json['authenticity_note'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'step': step,
        'ai_prompt': aiPrompt,
        'purpose': purpose,
        'expected_pattern': expectedPattern,
        'expected_answer_type': expectedAnswerType,
        'if_incorrect': ifIncorrect,
        'authenticity_note': authenticityNote,
      };
}

// ─────────────────────────────────────────────
// OUTPUT PHASE
// ─────────────────────────────────────────────

class OutputPhase {
  const OutputPhase({
    required this.title,
    required this.description,
    required this.promptForUser,
    required this.evaluationCriteria,
    this.sampleOutputs,
  });

  final String title;
  final String description;
  final String promptForUser;
  final List<String> evaluationCriteria;

  /// Key = level label (e.g. "A1", "A2", "B1")
  /// Value = sample output text
  final Map<String, String>? sampleOutputs;

  factory OutputPhase.fromJson(Map<String, dynamic> json) {
    // Collect all sample_output_* keys dynamically
    final outputs = <String, String>{};
    json.forEach((key, value) {
      if (key.startsWith('sample_output_') && value is String) {
        final label = key.replaceFirst('sample_output_', '').toUpperCase();
        outputs[label] = value;
      }
    });

    return OutputPhase(
      title: json['title'] as String,
      description: json['description'] as String,
      promptForUser: json['prompt_for_user'] as String,
      evaluationCriteria: List<String>.from(
          json['evaluation_criteria'] as List<dynamic>? ?? []),
      sampleOutputs: outputs.isNotEmpty ? outputs : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'prompt_for_user': promptForUser,
      'evaluation_criteria': evaluationCriteria,
    };
    sampleOutputs?.forEach((key, value) {
      map['sample_output_${key.toLowerCase()}'] = value;
    });
    return map;
  }
}
