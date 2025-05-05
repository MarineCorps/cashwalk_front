class Park {
  final int id;
  final String parkName;
  final double latitude;
  final double longitude;
  final double distance;
  final bool isRewardedToday;

  Park({
    required this.id,
    required this.parkName,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.isRewardedToday,
  });

  factory Park.fromJson(Map<String, dynamic> json) {
    print('[🐛 Park.fromJson 디버깅] ${json['parkName']} - isRewardedToday: ${json['RewardedToday']}');
    return Park(
      id: (json['id'] as num).toInt(),
      parkName: json['parkName'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      distance: (json['distance'] as num).toDouble(),
      isRewardedToday: json['rewardedToday'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'parkName': parkName,
    'latitude': latitude,
    'longitude': longitude,
    'distance': distance,
    'isRewardedToday': isRewardedToday,
  };

  /// ✅ 추가된 copyWith 메서드
  Park copyWith({
    int? id,
    String? parkName,
    double? latitude,
    double? longitude,
    double? distance,
    bool? isRewardedToday,
  }) {
    return Park(
      id: id ?? this.id,
      parkName: parkName ?? this.parkName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distance: distance ?? this.distance,
      isRewardedToday: isRewardedToday ?? this.isRewardedToday,
    );
  }
}

//🧠 추가 설명: 왜 이런 문제가 생기냐?
// Java 스펙상, Getter가 isXXX() 형태면, Jackson이 직렬화할 때 필드명에서 is를 자동 제거한다.
//
// 그래서 isRewardedToday → rewardedToday로 JSON key가 변환돼서 내려옴.
//
// (Spring Boot + Jackson 사용하면 자동임. 별도 설정 없으면 이 규칙 따라감.)
