import 'package:flutter/material.dart';

class FinishtrackingPage extends StatelessWidget {
  const FinishtrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("귀가 완료"),
        automaticallyImplyLeading: false,
        centerTitle: true,
        shape: const Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 1,
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 150),
            const Icon(
              Icons.check_circle_outline_sharp,
              size: 45,
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "안전하게 귀가했어요!\n좋은 하루 보내세요 :)",
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            Expanded(child: Container()),
            Padding(
              padding: const EdgeInsets.all(64),
              child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/', // 이동하려는 경로
                      (Route<dynamic> route) => false, // 모든 이전 경로를 제거
                    );
                  },
                  child: const Text("홈 화면으로 돌아가기")),
            )
          ],
        ),
      ),
    );
  }
}
