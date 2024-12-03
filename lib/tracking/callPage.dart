import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class CallPage extends StatefulWidget {
  const CallPage({super.key});

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  final _stopWatchTimer = StopWatchTimer(mode: StopWatchMode.countUp);

  @override
  void initState() {
    super.initState();
    _stopWatchTimer.setPresetTime(mSec: 0);
    _stopWatchTimer.onStartTimer();
  }

  @override
  void dispose() async {
    super.dispose();
    await _stopWatchTimer.dispose(); // Need to call dispose function.
  }

  Widget iconButton(IconData iconData) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(20),
          backgroundColor: const Color.fromARGB(45, 255, 255, 255),
          foregroundColor: const Color.fromARGB(112, 255, 255, 255),
        ),
        child: Icon(
          iconData,
          color: Colors.white,
          size: 45,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 35, 34, 51),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 125,
            ),
            const Text(
              "아빠",
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.w300,
                color: Colors.white,
              ),
            ),
            // const Text(
            //   "011-1928-2837",
            //   style: TextStyle(
            //     fontSize: 25,
            //     fontWeight: FontWeight.w200,
            //     color: Colors.white,
            //   ),
            // ),
            StreamBuilder<int>(
              stream: _stopWatchTimer.rawTime,
              initialData: 0,
              builder: (context, snap) {
                final value = snap.data ?? 0;

                final hours =
                    (value ~/ (60 * 60 * 1000)).toString().padLeft(2, '0');
                final minutes =
                    ((value ~/ (60 * 1000)) % 60).toString().padLeft(2, '0');
                final seconds =
                    ((value ~/ 1000) % 60).toString().padLeft(2, '0');
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        "$hours:$minutes:$seconds",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w100,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            Expanded(child: Container()),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 30, 30, 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      iconButton(Icons.mic_off),
                      iconButton(Icons.apps),
                      iconButton(Icons.volume_up),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      iconButton(Icons.add),
                      iconButton(Icons.videocam),
                      iconButton(Icons.bluetooth),
                    ],
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 60),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(15),
                  backgroundColor: const Color.fromARGB(255, 199, 9, 9),
                  foregroundColor: const Color.fromARGB(255, 78, 4, 4),
                ),
                child: const Icon(
                  Icons.call_end,
                  color: Colors.white,
                  size: 45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
