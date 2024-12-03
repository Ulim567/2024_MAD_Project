import 'package:auto_size_text_plus/auto_size_text_plus.dart';
import 'package:flutter/material.dart';

class CurrentStatePage extends StatefulWidget {
  const CurrentStatePage({super.key});

  @override
  State<CurrentStatePage> createState() => _CurrentStatePageState();
}

class _CurrentStatePageState extends State<CurrentStatePage> {
  Widget stateInfoCard(String name, String locationDetail, String location) {
    return Card(
        child: Padding(
      padding: const EdgeInsets.fromLTRB(12, 15, 15, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 4, 8, 0),
            child: Icon(
              Icons.location_on,
              size: 30,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  name,
                  style: const TextStyle(fontSize: 20),
                  maxLines: 1,
                  minFontSize: 18,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(
                  height: 4,
                ),
                AutoSizeText(
                  locationDetail,
                  maxLines: 1,
                  minFontSize: 12,
                  overflow: TextOverflow.ellipsis,
                ),
                AutoSizeText(
                  location,
                  maxLines: 1,
                  minFontSize: 12,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () {}, child: const Text("확인하기")),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
              child: Row(
                children: [
                  const Icon(Icons.today),
                  const SizedBox(
                    width: 10,
                  ),
                  const Text(
                    "귀가 현황",
                    style: TextStyle(fontSize: 24),
                  ),
                  Expanded(child: Container()),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.navigation_rounded),
                    iconSize: 30,
                  )
                ],
              ),
            ),
            Expanded(
                child: ListView(
              children: [
                stateInfoCard("이우림", "경기도 성남시 중원로 72", "E금빛그랑메종5단지"),
                stateInfoCard("이향우", "경상도 포항 북구 한동로 588", "한동대학교"),
                stateInfoCard("이향우", "경상도 포항 북구 한동로 588", "한동대학교"),
                stateInfoCard("이향우", "경상도 포항 북구 한동로 588", "한동대학교"),
                stateInfoCard("이향우", "경상도 포항 북구 한동로 588", "한동대학교"),
                stateInfoCard("이향우", "경상도 포항 북구 한동로 588", "한동대학교"),
                stateInfoCard("이향우", "경상도 포항 북구 한동로 588", "한동대학교"),
                stateInfoCard("이향우", "경상도 포항 북구 한동로 588", "한동대학교"),
              ],
            ))
          ],
        ),
      ),
    );
  }
}
