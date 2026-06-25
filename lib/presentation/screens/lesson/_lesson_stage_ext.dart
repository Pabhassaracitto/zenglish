// lib/presentation/screens/lesson/_lesson_stage_ext.dart
//
// File này chứa phần mở rộng (extension) cho LessonStage
// liên quan đến UI - tách riêng để giữ lesson_provider.dart sạch.

import 'package:flutter/material.dart';

import '../../providers/lesson_provider.dart';

/// Extension thêm icon hiển thị cho từng giai đoạn bài học.
/// Đặt ở UI layer vì IconData thuộc về Flutter, không phải logic thuần.
extension LessonStageIconExt on LessonStage {
  IconData get icon {
    switch (this) {
      case LessonStage.input:
        return Icons.hearing_rounded; // Tai nghe → Giai đoạn nghe
      case LessonStage.pattern:
        return Icons.abc_rounded; // Chữ cái → Giai đoạn mẫu câu
      case LessonStage.vocab:
        return Icons.link_rounded; // Link → Giai đoạn nối từ
      case LessonStage.guided:
        return Icons.people_rounded; // Người → Giai đoạn luyện tập
      case LessonStage.output:
        return Icons.mic_rounded; // Micro → Giai đoạn tự nói
    }
  }
}
