enum DailyTaskType {
  completeLevels,
  findWords,
  useLetterHints,
  useWordHints,
  endlessStage,
  loginStreak,
  buyBackground,
  noHintLevels,
  playCategories,
}

class DailyTaskDefinition {
  const DailyTaskDefinition({
    required this.id,
    required this.type,
    required this.target,
    required this.reward,
    required this.titleEn,
    required this.titleAr,
    required this.icon,
  });

  final String id;
  final DailyTaskType type;
  final int target;
  final int reward;
  final String titleEn;
  final String titleAr;
  final String icon;

  String title(bool isArabic) => isArabic ? titleAr : titleEn;
}

class DailyTaskProgress {
  const DailyTaskProgress({
    required this.taskId,
    required this.progress,
    required this.claimed,
  });

  final String taskId;
  final int progress;
  final bool claimed;

  bool isComplete(int target) => progress >= target;

  DailyTaskProgress copyWith({int? progress, bool? claimed}) {
    return DailyTaskProgress(
      taskId: taskId,
      progress: progress ?? this.progress,
      claimed: claimed ?? this.claimed,
    );
  }

  Map<String, dynamic> toJson() => {
        'taskId': taskId,
        'progress': progress,
        'claimed': claimed,
      };

  factory DailyTaskProgress.fromJson(Map<String, dynamic> json) {
    return DailyTaskProgress(
      taskId: json['taskId'] as String,
      progress: json['progress'] as int? ?? 0,
      claimed: json['claimed'] as bool? ?? false,
    );
  }
}
