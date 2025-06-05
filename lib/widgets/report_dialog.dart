import 'package:flutter/material.dart';

Future<String?> showReportDialog(BuildContext context) async {
  String? selectedReason = 'ABUSE'; // 초기 선택값 설정

  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('신고 사유를 선택해주세요'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildReasonTile(setState, selectedReason, 'ABUSE', '욕설/비방'),
                _buildReasonTile(setState, selectedReason, 'SEXUAL', '선정적 내용'),
                _buildReasonTile(setState, selectedReason, 'PROMOTION', '광고/홍보'),
                _buildReasonTile(setState, selectedReason, 'PRIVACY', '개인정보 노출'),
                _buildReasonTile(setState, selectedReason, 'DEFAMATION', '명예훼손'),
                _buildReasonTile(setState, selectedReason, 'ETC', '기타'),
              ],
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(context, selectedReason),
            child: const Text('신고'),
          ),
        ],
      );
    },
  );
}

Widget _buildReasonTile(
    void Function(VoidCallback) setState,
    String? selected,
    String code,
    String label,
    ) {
  return RadioListTile<String>(
    title: Text(label),
    value: code,
    groupValue: selected,
    onChanged: (value) {
      setState(() {
        selected = value!;
      });
    },
    activeColor: Colors.amber, // ✅ 선택 시 색상 강조
  );
}
