import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

class AddCodeWidget extends StatefulWidget {
  final void Function(String code) onCodeVerified;

  const AddCodeWidget({super.key, required this.onCodeVerified});

  @override
  State<AddCodeWidget> createState() => _AddCodeWidgetState();
}

class _AddCodeWidgetState extends State<AddCodeWidget> {
  final TextEditingController _codeController = TextEditingController();
  String? _statusMessage;

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _checkCode(String code) async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(code).get();

      setState(() {
        if (snapshot.exists) {
          _statusMessage = "코드가 확인되었습니다.";
          widget.onCodeVerified(code); // 부모 위젯에 코드 전달
        } else {
          _statusMessage = "없는 코드입니다.";
          widget.onCodeVerified(""); // 유효하지 않음을 알림
        }
      });
    } catch (e) {
      setState(() {
        _statusMessage = "오류가 발생했습니다. 다시 시도해주세요.";
      });
      print("Error checking code: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const Text(
          "친구 추가를 위해\n코드를 입력해주세요",
          style: TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 35),
        TextField(
          controller: _codeController,
          decoration: const InputDecoration(
            labelText: "친구 코드",
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              _checkCode(value); // 실시간으로 Firestore 확인
            } else {
              setState(() {
                _statusMessage = null;
              });
            }
          },
        ),
        const SizedBox(height: 10),
        if (_statusMessage != null)
          Text(
            _statusMessage!,
            style: TextStyle(
              color:
                  _statusMessage == "코드가 확인되었습니다." ? Colors.green : Colors.red,
            ),
          ),
      ],
    );
  }
}
