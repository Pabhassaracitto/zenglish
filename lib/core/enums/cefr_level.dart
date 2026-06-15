enum CEFRLevel {
  a1,
  a2,
  b1,
  b2,
  c1,
  c2;

  String get displayName {
    switch (this) {
      case CEFRLevel.a1:
        return 'A1';
      case CEFRLevel.a2:
        return 'A2';
      case CEFRLevel.b1:
        return 'B1';
      case CEFRLevel.b2:
        return 'B2';
      case CEFRLevel.c1:
        return 'C1';
      case CEFRLevel.c2:
        return 'C2';
    }
  }

  static CEFRLevel fromString(String value) {
    final lower = value.toLowerCase();
    for (final level in CEFRLevel.values) {
      if (level.name.toLowerCase() == lower || level.displayName.toLowerCase() == lower) {
        return level;
      }
    }
    return CEFRLevel.a1;
  }
}
