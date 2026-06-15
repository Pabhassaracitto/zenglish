/// Temporal Flexibility — 5 tình huống thời gian
/// Lý do: trạng thái thiền vô thường (anicca)
/// Người dùng có thể báo cáo hiện tại, quá khứ,
/// hoặc hỏi về tương lai
enum TemporalContext {
  present,
  past,
  future,
  pastAndFuture,
  all;

  String get displayName {
    switch (this) {
      case TemporalContext.present:
        return 'Present';
      case TemporalContext.past:
        return 'Past';
      case TemporalContext.future:
        return 'Future';
      case TemporalContext.pastAndFuture:
        return 'Past & Future';
      case TemporalContext.all:
        return 'All Temporal Contexts';
    }
  }

  static TemporalContext fromString(String value) {
    return TemporalContext.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TemporalContext.present,
    );
  }
}
