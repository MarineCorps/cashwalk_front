class InviteStats {
  final String inviteCode;
  final int invitedCount;
  final int invitedMeCount;
  final int totalCash;

  InviteStats({
    required this.inviteCode,
    required this.invitedCount,
    required this.invitedMeCount,
    required this.totalCash,
  });

  factory InviteStats.fromJson(Map<String, dynamic> json) {
    return InviteStats(
      inviteCode: json['inviteCode'],
      invitedCount: json['invitedCount'],
      invitedMeCount: json['invitedMeCount'],
      totalCash: json['totalCash'],
    );
  }
}
