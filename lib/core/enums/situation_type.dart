/// 5 tình huống theo Temporal Flexibility
enum SituationType {
  /// A — Chuẩn bị, chưa có kinh nghiệm
  preparation,

  /// B — Lần đầu xuất hiện / kinh nghiệm
  firstAppearance,

  /// C — Ổn định / theo dõi tiếp diễn
  stableTracking,

  /// D — Biến mất / thay đổi
  disappearedChanged,

  /// E — Kể lại quá khứ / hỏi tương lai
  pastFuture;

  String get code {
    switch (this) {
      case SituationType.preparation:
        return 'A';
      case SituationType.firstAppearance:
        return 'B';
      case SituationType.stableTracking:
        return 'C';
      case SituationType.disappearedChanged:
        return 'D';
      case SituationType.pastFuture:
        return 'E';
    }
  }

  String get displayName {
    switch (this) {
      case SituationType.preparation:
        return 'A — Preparation';
      case SituationType.firstAppearance:
        return 'B — First Appearance';
      case SituationType.stableTracking:
        return 'C — Stable Tracking';
      case SituationType.disappearedChanged:
        return 'D — Disappeared / Changed';
      case SituationType.pastFuture:
        return 'E — Past / Future';
    }
  }

  static SituationType fromCode(String code) {
    return SituationType.values.firstWhere(
      (e) => e.code == code.toUpperCase(),
      orElse: () => throw ArgumentError('Invalid SituationType code: $code'),
    );
  }
}
