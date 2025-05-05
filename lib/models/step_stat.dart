class StepStat {
  final DateTime date;
  final int steps;

  StepStat({
    required this.date,
    required this.steps,
  });

  factory StepStat.fromJson(Map<String, dynamic> json) {
    try {
      return StepStat(
        date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()), // 🛡️ date null 방어
        steps: json['steps'] ?? 0, // 🛡️ steps null 방어
      );
    } catch (e) {
      // 만약 date 파싱 자체가 터지면 지금 시간으로 대체
      return StepStat(
        date: DateTime.now(),
        steps: 0,
      );
    }
  }
}
