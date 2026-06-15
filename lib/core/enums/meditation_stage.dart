/// Giai đoạn thiền tập theo hệ thống Pa-Auk
/// Samatha trước → Vipassanā sau (không đảo thứ tự)
enum MeditationStage {
  /// Chưa có kinh nghiệm thiền — cư sĩ mới
  preRetreat,

  /// Đang học giới luật nền tảng
  silaPreiliminary,

  /// Samatha giai đoạn sơ khởi (ānāpāna, kasiṇa cơ bản)
  samathaPreiliminary,

  /// Upacāra samādhi — cận định, nimitta xuất hiện
  samathaUpacara,

  /// Appanā samādhi — jhāna (1st–4th)
  samathaAppana,

  /// Bắt đầu vipassanā sau khi samatha đủ mạnh
  vipassanaPreiliminary,

  /// Nāma-rūpa pariccheda — phân tích danh sắc
  vipassanaNamaRupa,

  /// Tuệ quán sâu — tilakkhaṇa rõ ràng
  vipassanaInsight,

  /// Không xác định / áp dụng ở mọi giai đoạn
  any;

  String get displayName {
    switch (this) {
      case MeditationStage.preRetreat:
        return 'Pre-Retreat';
      case MeditationStage.silaPreiliminary:
        return 'Sīla Preliminary';
      case MeditationStage.samathaPreiliminary:
        return 'Samatha Preliminary';
      case MeditationStage.samathaUpacara:
        return 'Upacāra Samādhi';
      case MeditationStage.samathaAppana:
        return 'Appanā Samādhi (Jhāna)';
      case MeditationStage.vipassanaPreiliminary:
        return 'Vipassanā Preliminary';
      case MeditationStage.vipassanaNamaRupa:
        return 'Nāma-Rūpa Analysis';
      case MeditationStage.vipassanaInsight:
        return 'Vipassanā Insight';
      case MeditationStage.any:
        return 'Any Stage';
    }
  }

  static MeditationStage fromString(String value) {
    return MeditationStage.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MeditationStage.any,
    );
  }
}
