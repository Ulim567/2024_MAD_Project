import 'package:flutter/material.dart';
import 'package:moblie_app_project/provider/dbservice.dart';

class FriendRequestResultWidget extends StatefulWidget {
  final String? code;

  const FriendRequestResultWidget({super.key, this.code});

  @override
  State<FriendRequestResultWidget> createState() =>
      _FriendRequestResultWidgetState();
}

class _FriendRequestResultWidgetState extends State<FriendRequestResultWidget> {
  bool _isLoading = true; // 로딩 상태
  String? _userName;
  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    if (widget.code != null && widget.code!.isNotEmpty) {
      final userData = await _databaseService.getUserData(widget.code!);
      setState(() {
        if (userData != null) {
          _userName = userData['name'];
        } else {
          _userName = null;
        }
        _isLoading = false;
      });
    } else {
      setState(() {
        _userName = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 200),
        const Icon(
          Icons.check_circle_outline_sharp,
          size: 60,
        ),
        SizedBox(
          height: 10,
        ),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          )
        else
          Text(
            _userName != null
                ? "$_userName 님에게\n친구 추가 요청을\n전송했어요!"
                : "사용자 정보를 확인할 수 없습니다.${widget.code}",
            style: const TextStyle(fontSize: 24),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}
