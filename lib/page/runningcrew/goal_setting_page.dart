import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GoalSettingPage extends StatefulWidget {
  final bool isDistanceMode;
  final double initialDistance;
  final Duration initialDuration;

  const GoalSettingPage({
    super.key,
    required this.isDistanceMode,
    required this.initialDistance,
    required this.initialDuration,
  });

  @override
  State<GoalSettingPage> createState() => _GoalSettingPageState();
}

class _GoalSettingPageState extends State<GoalSettingPage> {
  late TextEditingController _intDistanceController;
  late TextEditingController _decimalDistanceController;
  late TextEditingController _hoursController;
  late TextEditingController _minutesController;
  late TextEditingController _secondsController;

  final FocusNode _intDistanceFocus = FocusNode();
  final FocusNode _decimalDistanceFocus = FocusNode();
  final FocusNode _hourFocus = FocusNode();
  final FocusNode _minuteFocus = FocusNode();
  final FocusNode _secondFocus = FocusNode();

  bool isOverMax = false;

  @override
  void initState() {
    super.initState();

    // ✅ 초기 거리 20.0km 고정
    const initialDistance = 20.0;
    final intPart = initialDistance.floor();
    final decimalPart = ((initialDistance - intPart) * 100).round();

    _intDistanceController = TextEditingController(text: intPart.toString().padLeft(2, '0'));
    _decimalDistanceController = TextEditingController(text: decimalPart.toString().padLeft(2, '0'));

    _hoursController = TextEditingController(
      text: widget.initialDuration.inHours.toString().padLeft(2, '0'),
    );
    _minutesController = TextEditingController(
      text: (widget.initialDuration.inMinutes % 60).toString().padLeft(2, '0'),
    );
    _secondsController = TextEditingController(
      text: (widget.initialDuration.inSeconds % 60).toString().padLeft(2, '0'),
    );
  }

  @override
  void dispose() {
    _intDistanceController.dispose();
    _decimalDistanceController.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('목표 설정', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소', style: TextStyle(color: Colors.black)),
        ),
        actions: [
          TextButton(
            onPressed: _onConfirmPressed,
            child: const Text('완료', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          Text(
            widget.isDistanceMode
                ? '목표 거리를 자유롭게 설정해 보세요.\n목표 최대 거리는 20.0km입니다.'
                : '목표 시간을 자유롭게 설정해 보세요.\n목표 최대 시간은 2시간입니다.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 40),
          widget.isDistanceMode ? _buildDistanceInput() : _buildTimeInput(),
        ],
      ),
    );
  }

  Widget _buildDistanceInput() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNumberField(_intDistanceController, _intDistanceFocus, _decimalDistanceFocus),
            const Text('.', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
            _buildNumberField(_decimalDistanceController, _decimalDistanceFocus, null),
          ],
        ),
        const Divider(
          color: Colors.deepOrange,
          thickness: 3,
          indent: 80,
          endIndent: 80,
        ),
        const Text('km', style: TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildTimeInput() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNumberField(_hoursController, _hourFocus, _minuteFocus),
            const Text(':', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
            _buildNumberField(_minutesController, _minuteFocus, _secondFocus),
            const Text(':', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
            _buildNumberField(_secondsController, _secondFocus, null),
          ],
        ),
        const Divider(
          color: Colors.deepOrange,
          thickness: 3,
          indent: 80,
          endIndent: 80,
        ),
        const Text('시:분:초', style: TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildNumberField(
      TextEditingController controller,
      FocusNode currentFocus,
      FocusNode? nextFocus,
      ) {
    return SizedBox(
      width: 60,
      child: TextField(
        controller: controller,
        focusNode: currentFocus,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 2,
        style: const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly], // ✅ 숫자만 입력 허용
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        onTap: () {
          controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: controller.text.length,
          );
        },
        onChanged: (value) {
          if (value.length == 2 && nextFocus != null) {
            FocusScope.of(context).requestFocus(nextFocus);

            WidgetsBinding.instance.addPostFrameCallback((_) {
              final focusedField = FocusScope.of(context).focusedChild?.context?.widget as EditableText?;
              final controller = focusedField?.controller;
              if (controller != null) {
                controller.selection = TextSelection(baseOffset: 0, extentOffset: controller.text.length);
              }
            });
          }

          _handleInputLimit(controller);
          _checkOverMax();
        },
      ),
    );
  }

  void _handleInputLimit(TextEditingController controller) {
    if (widget.isDistanceMode) {
      return; // 거리 입력은 여기서 막지 않음 (전체 거리 합산으로 나중에 막음)
    } else {
      int value = int.tryParse(controller.text) ?? 0;
      if (value > 59) {
        controller.text = '59';
        controller.selection = TextSelection.collapsed(offset: controller.text.length);
      }
    }
  }

  void _checkOverMax() {
    if (widget.isDistanceMode) {
      double intPart = double.tryParse(_intDistanceController.text) ?? 0;
      double decimalPart = (double.tryParse(_decimalDistanceController.text) ?? 0) / 100;
      double totalDistance = intPart + decimalPart;
      setState(() {
        isOverMax = totalDistance > 20.0;
      });
    } else {
      int h = int.tryParse(_hoursController.text) ?? 0;
      int m = int.tryParse(_minutesController.text) ?? 0;
      int s = int.tryParse(_secondsController.text) ?? 0;
      Duration total = Duration(hours: h, minutes: m, seconds: s);
      setState(() {
        isOverMax = total.inMinutes > 120;
      });
    }
  }

  void _onConfirmPressed() {
    if (widget.isDistanceMode) {
      double intPart = double.tryParse(_intDistanceController.text) ?? 0;
      double decimalPart = (double.tryParse(_decimalDistanceController.text) ?? 0) / 100;
      double totalDistance = double.parse((intPart + decimalPart).toStringAsFixed(2));

      if (totalDistance > 20.0) {
        _showMaxSnackbar('목표 최대 거리는 20.0km입니다.');
        totalDistance = 20.0;
      }
      Navigator.pop(context, totalDistance);
    } else {
      int h = int.tryParse(_hoursController.text) ?? 0;
      int m = int.tryParse(_minutesController.text) ?? 0;
      int s = int.tryParse(_secondsController.text) ?? 0;
      Duration total = Duration(hours: h, minutes: m, seconds: s);
      if (total.inMinutes > 120) {
        _showMaxSnackbar('목표 최대 시간은 2시간입니다.');
        total = const Duration(hours: 2);
      }
      Navigator.pop(context, total);
    }
  }

  void _showMaxSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
