import 'package:flutter/material.dart';
import 'package:moblie_app_project/provider/dbservice.dart';

class ProfileConfirmWidget extends StatefulWidget {
  final String? code;

  const ProfileConfirmWidget({super.key, this.code});

  @override
  State<ProfileConfirmWidget> createState() => _ProfileConfirmWidgetState();
}

class _ProfileConfirmWidgetState extends State<ProfileConfirmWidget> {
  String? _userName; // 사용자 이름 저장
  bool _isLoading = true; // 로딩 상태
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          )
        else
          Text(
            _userName != null
                ? "$_userName 님에게\n친구 추가 요청을\n전송할까요?"
                : "사용자 정보를 확인할 수 없습니다.${widget.code}",
            style: const TextStyle(fontSize: 24),
          ),
        const SizedBox(height: 35),
        if (_userName != null && widget.code != null)
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 8, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.purple.shade100,
                        child:
                            Icon(Icons.person, size: 30, color: Colors.purple),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userName!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Text(
                            widget.code!,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
