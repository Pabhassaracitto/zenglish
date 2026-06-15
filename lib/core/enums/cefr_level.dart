enum CEFRLevel {
  a1,
  a2,
  b1,
  b2,
  c1;

  String get displayName {
    switch (this) {
      case CEFRLevel.a1: return 'A1';
      case CEFRLevel.a2: return 'A2';
      case CEFRLevel.b1: return 'B1';
      case CEFRLevel.b2: return 'B2';
      case CEFRLevel.c1: return 'C1';
    }
  }

  static CEFRLevel fromString(String value) {
    return CEFRLevel.values.firstWhere(
      (e) => e.displayName.toLowerCase() == value.toLowerCase(),
      orElse: () => throw ArgumentError('Invalid CEFRLevel: $value'),
    );
  }
}
