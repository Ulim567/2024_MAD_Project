import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RouteOptionPage extends StatefulWidget {
  const RouteOptionPage({super.key});

  @override
  State<RouteOptionPage> createState() => _RouteOptionPageState();
}

class _RouteOptionPageState extends State<RouteOptionPage> {
  int index = 0;
  List<Widget> pages = [const ConfirmRoutewidget(), const SelectTimePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("위치 확인"),
        centerTitle: true,
        shape: const Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 1,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            pages[index],
            Expanded(child: Container()),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                      onPressed: () {
                        if (index == 0) {
                          Navigator.pop(context);
                        } else {
                          setState(() {
                            index--;
                          });
                        }
                      },
                      child: const Text("돌아가기")),
                  ElevatedButton(
                      onPressed: () {
                        if (index == pages.length - 1) {
                        } else {
                          setState(() {
                            index++;
                          });
                        }
                      },
                      child: const Text("다음"))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ConfirmRoutewidget extends StatelessWidget {
  const ConfirmRoutewidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 10,
        ),
        const Text(
          "선택하신 도착지가\n맞는지 확인해주세요",
          style: TextStyle(fontSize: 24),
        ),
        const SizedBox(
          height: 35,
        ),
        const Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: Colors.black54,
            ),
            const Text(
              "포항시 북구 한동로 588 한동대학교",
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Center(
          child: Container(
            width: 350,
            height: 350,
            color: Colors.black45,
          ),
        ),
      ],
    );
  }
}

class SelectTimePage extends StatefulWidget {
  const SelectTimePage({super.key});

  @override
  State<SelectTimePage> createState() => _SelectTimePageState();
}

class _SelectTimePageState extends State<SelectTimePage> {
  TimeOfDay? selectedTime;

  // MaterialTapTargetSize (버튼 터치 크기 설정)
  MaterialTapTargetSize tapTargetSize = MaterialTapTargetSize.padded;
  // 다른 변수들...
  TimePickerEntryMode entryMode = TimePickerEntryMode.dial;
  Orientation? orientation;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        const Text(
          "도착 예정 시간을\n선택해주세요",
          style: TextStyle(fontSize: 24),
        ),
        const SizedBox(
          height: 35,
        ),
        ElevatedButton(
          child: const Text('Open time picker (Input Mode)'),
          onPressed: () async {
            final TimeOfDay? time = await showTimePicker(
              context: context,
              initialTime: selectedTime ?? TimeOfDay.now(),
              initialEntryMode: TimePickerEntryMode.input, // 입력 모드 설정
              builder: (BuildContext context, Widget? child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    materialTapTargetSize: tapTargetSize,
                  ),
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        alwaysUse24HourFormat: false,
                      ),
                      child: child!,
                    ),
                  ),
                );
              },
            );
            setState(() {
              selectedTime = time;
            });
          },
        ),
      ],
    );
  }
}
