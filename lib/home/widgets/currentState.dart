import 'package:flutter/material.dart';

class CurrentStatePage extends StatefulWidget {
  const CurrentStatePage({super.key});

  @override
  State<CurrentStatePage> createState() => _CurrentStatePageState();
}

class _CurrentStatePageState extends State<CurrentStatePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const SizedBox(
              height: 75,
            ),
            Row(
              children: [
                Icon(Icons.today),
                const SizedBox(
                  width: 10,
                ),
                const Text(
                  "귀가 현황",
                  style: TextStyle(fontSize: 24),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
