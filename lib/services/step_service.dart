import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:cashwalk/services/step_api_service.dart'; // ✅ 서버 연동용 API 호출 클래스
import 'package:cashwalk/services/http_service.dart';

/// 걸음 수 측정 및 실시간 UI + 서버 전송 로직을 담당하는 클래스
class StepService {
  // ✅ 싱글톤 패턴으로 어디서든 하나의 인스턴스만 사용
  static final StepService _instance = StepService._internal();
  factory StepService() => _instance;
  StepService._internal();

  Stream<StepCount>? _stepCountStream; // 센서에서 받아오는 걸음 수 스트림
  final StreamController<int> _stepCountController = StreamController<int>.broadcast();

  int _currentSteps = 0;         // 현재 측정된 걸음 수
  int _lastReportedSteps = 0;    // 마지막으로 서버에 전송한 걸음 수

  /// 외부에서 실시간 걸음 수를 구독할 수 있도록 제공하는 스트림
  Stream<int> get stepStream => _stepCountController.stream;

  /// 센서 초기화 및 걸음 수 스트림 구독 시작
  Future<void> init() async {
    _stepCountStream = Pedometer.stepCountStream;

    // 걸음 수가 바뀔 때마다 _onStepCount 호출
    _stepCountStream?.listen(
      _onStepCount,
      onError: _onStepError,
    );
  }

  /// 걸음 수가 변경되었을 때 호출되는 함수
  void _onStepCount(StepCount event) {
    _currentSteps = event.steps;

    // 1. UI 업데이트 (즉시 반영)
    _stepCountController.add(_currentSteps);

    // 2. 서버 전송: 30보 이상 증가한 경우에만 호출
    if (_currentSteps - _lastReportedSteps >= 30) {
      _lastReportedSteps = _currentSteps;

      print('🛰 서버에 자동 보고: $_currentSteps 걸음');
      StepApiService.reportSteps(_currentSteps); // ✅ 서버에 보고
    }
  }

  /// 걸음 수 측정 중 오류가 발생했을 때 호출
  void _onStepError(error) {
    print('🚨 걸음 수 측정 오류: $error');
    _stepCountController.addError('걸음 수 측정 실패');
  }

  /// 외부에서 현재 걸음 수에 접근 가능하게 제공
  int get currentSteps => _currentSteps;

  /// 앱 종료 시 스트림 닫기 (메모리 누수 방지)
  void dispose() {
    _stepCountController.close();
  }
}
