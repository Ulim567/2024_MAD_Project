import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moblie_app_project/provider/defaultState.dart';
import 'package:moblie_app_project/api/tmap_search_service.dart'; // Timer를 사용하기 위해 import
import 'dart:async';

// import 'package:moblie_app_project/routeoption/widgets/confirmRouteWidget.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

import '../provider/dbservice.dart';

class SearchMapPage extends StatefulWidget {
  const SearchMapPage({super.key});

  @override
  State<SearchMapPage> createState() => _SearchMapPageState();
}

class _SearchMapPageState extends State<SearchMapPage> {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _searchContent = TextEditingController();
  final TmapService tmapService = TmapService(); // TmapService 인스턴스 생성
  List<Map<String, dynamic>> searchResults = []; // 검색 결과를 저장할 리스트
  Timer? _debounceTimer; // Timer를 저장할 변수

  // 검색어가 변경될 때마다 API 호출
  void _searchPlace() async {
    final query = _searchContent.text.trim();
    if (query.isNotEmpty) {
      try {
        // TmapService의 getAutocomplete 호출
        final results = await tmapService.getAutocomplete(query);
        setState(() {
          searchResults = results; // 검색 결과를 상태에 저장
        });
      } catch (e) {
        print('Error: $e');
        // 오류 처리 로직 추가 가능
      }
    } else {
      setState(() {
        searchResults.clear(); // 검색어가 없으면 결과 초기화
      });
    }
  }

  // 디바운싱 처리: 사용자가 입력을 멈추면 API 호출
  void _onSearchChanged(String value) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 100), () {
      _searchPlace();
    });
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            '사용자가 로그인되지 않았습니다.',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    final String uid = user.uid;
    var defaultState = context.watch<Defaultstate>();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(58.0),
        child: AppBar(
          shape: const Border(
            bottom: BorderSide(
              color: Colors.grey,
              width: 1,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: TextField(
            controller: _searchContent,
            decoration: const InputDecoration(
                hintText: '어디로 갈까요?',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.black38)),
            autofocus: true,
            onChanged: _onSearchChanged, // 검색어 변경 시 디바운싱 호출
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _searchContent.clear();
                  searchResults.clear(); // 검색어와 결과 초기화
                });
              },
            ),
          ],
        ),
      ),
      body: searchResults.isEmpty
          ? const Center(child: Text('검색 결과가 없습니다.'))
          : ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: searchResults.length,
              itemBuilder: (BuildContext ctx, int idx) {
                final result = searchResults[idx];
                final name = result['name'] ?? '';
                final address = result['address'] ?? ''; // 상세 주소 (없을 경우 빈 문자열)
                return InkWell(
                  onTap: () async {
                    bool isTracking = await _databaseService.isTrackingNow(uid);
                    if (isTracking) {
                      var toast = getToast(context);
                      toastification.dismissAll();
                      toast.start();
                    } else {
                      FocusScope.of(context).unfocus();
                      defaultState.setName(name);
                      defaultState.setAddress(address);
                      defaultState.setLatitude(result['lat']);
                      defaultState.setLongitude(result['lng']);
                      Navigator.pushNamed(context, '/routeoption');
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: Icon(
                            Icons.location_on,
                            color: Colors.black54,
                            size: 22,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                result['name'], // POI 이름
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black87),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (address.isNotEmpty)
                                Text(
                                  address, // 상세 주소
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600]), // 회색으로 표시
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext ctx, int idx) {
                return const Divider(
                  height: 0,
                  thickness: 1,
                  color: Colors.black12,
                );
              },
            ),
    );
  }
}

ToastificationItem getToast(BuildContext context) {
  return toastification.show(
    context: context,
    type: ToastificationType.info,
    style: ToastificationStyle.flat,
    title: const Text("진행 중인 귀가 정보가 이미 있습니다"),
    alignment: Alignment.bottomCenter,
    autoCloseDuration: const Duration(seconds: 3),
    animationBuilder: (
      context,
      animation,
      alignment,
      child,
    ) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
    borderRadius: BorderRadius.circular(12.0),
    closeButtonShowType: CloseButtonShowType.none,
    showProgressBar: false,
    margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
    closeOnClick: true,
    dragToClose: true,
    dismissDirection: DismissDirection.startToEnd,
  );
}
