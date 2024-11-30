import 'package:flutter/material.dart';
import 'package:wheel_picker/wheel_picker.dart';

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

class SelectTimePage extends StatelessWidget {
  const SelectTimePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 10,
        ),
        Text(
          "도착 예정 시간을\n선택해주세요",
          style: TextStyle(fontSize: 24),
        ),
        SizedBox(
          height: 35,
        ),
        WheelPickerExample(),
      ],
    );
  }
}

class WheelPickerExample extends StatefulWidget {
  const WheelPickerExample({super.key});

  @override
  State<WheelPickerExample> createState() => _WheelPickerExampleState();
}

class _WheelPickerExampleState extends State<WheelPickerExample> {
  final now = TimeOfDay.now();

  int selectedHour = TimeOfDay.now().hour;
  int selectedMinute = TimeOfDay.now().minute;
  int selectedAmPm =
      (TimeOfDay.now().period == DayPeriod.am) ? 0 : 1; // 0: AM, 1: PM

  late final _hoursWheel = WheelPickerController(
    itemCount: 24,
    initialIndex: now.hour % 24,
  );
  late final _minutesWheel = WheelPickerController(
    itemCount: 60,
    initialIndex: now.minute,
    mounts: [_hoursWheel],
  );

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 26.0, height: 1.5);
    final wheelStyle = WheelPickerStyle(
      itemExtent: textStyle.fontSize! * textStyle.height!, // Text height
      squeeze: 1.25,
      diameterRatio: .8,
      surroundingOpacity: .25,
      magnification: 1.2,
    );

    // 시간과 분을 업데이트하는 함수
    void updateTime(int hour, int minute, int amPm) {
      setState(() {
        selectedHour = hour;
        selectedMinute = minute;
        selectedAmPm = amPm;
      });
    }

    Widget itemBuilder(BuildContext context, int index) {
      return Text("$index".padLeft(2, '0'), style: textStyle);
    }

    final timeWheels = <Widget>[
      for (final wheelController in [_hoursWheel, _minutesWheel])
        Expanded(
          child: WheelPicker(
            builder: itemBuilder,
            controller: wheelController,
            looping: true,
            style: wheelStyle,
            selectedIndexColor: Colors.blueGrey,
            onIndexChanged: (index) {
              if (wheelController == _hoursWheel) {
                updateTime(index, selectedMinute, selectedAmPm);
              } else if (wheelController == _minutesWheel) {
                updateTime(selectedHour, index, selectedAmPm);
              }
            },
          ),
        ),
    ];
    timeWheels.insert(1, const Text(":", style: textStyle));

    final amPmWheel = Expanded(
      child: WheelPicker(
        itemCount: 2,
        builder: (context, index) {
          return Text(["AM", "PM"][index], style: textStyle);
        },
        initialIndex: (now.period == DayPeriod.am) ? 0 : 1,
        looping: false,
        style: wheelStyle.copyWith(
          shiftAnimationStyle: const WheelShiftAnimationStyle(
            duration: Duration(seconds: 1),
            curve: Curves.bounceOut,
          ),
        ),
        onIndexChanged: (index) {
          updateTime(selectedHour, selectedMinute, index);
        },
      ),
    );

    return Column(
      children: [
        Center(
          child: SizedBox(
            width: 350.0,
            height: 200.0,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _centerBar(context),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    children: [
                      ...timeWheels,
                      const SizedBox(width: 6.0),
                      amPmWheel,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Text(
            "${selectedHour.toString().padLeft(2, '0')}시 ${selectedMinute.toString().padLeft(2, '0')}분"),
      ],
    );
  }

  @override
  void dispose() {
    _hoursWheel.dispose();
    _minutesWheel.dispose();
    super.dispose();
  }

  Widget _centerBar(BuildContext context) {
    return Center(
      child: Container(
        height: 38.0,
        decoration: BoxDecoration(
          color: const Color(0xFFC3C9FA).withAlpha(26),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}
