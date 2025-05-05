class CertificationModel {
  final String? residenceAddress;
  final String? activityAddress;
  final String? residenceCertifiedAt;
  final String? activityCertifiedAt;

  CertificationModel({
    this.residenceAddress,
    this.activityAddress,
    this.residenceCertifiedAt,
    this.activityCertifiedAt,
  });

  factory CertificationModel.fromJson(Map<String, dynamic> json) {
    return CertificationModel(
      residenceAddress: json['residenceAddress'],
      activityAddress: json['activityAddress'],
      residenceCertifiedAt: json['residenceCertifiedAt'],
      activityCertifiedAt: json['activityCertifiedAt'],
    );
  }
}
