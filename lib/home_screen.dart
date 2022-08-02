import 'dart:async';

import 'package:chool_check/checkButton.dart';
import 'package:chool_check/gMap.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'Authorization/UserLocateAuthorization.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // "출근 확정" 여부를 확인하는 Control Variable
  bool isWorked = false;

  // "새로 고침" 할 떄 유용하게 쓰이는 Google Map Controller 
  Completer<GoogleMapController> _completer = Completer();

  // "애오개역"에 대한 위도, 경도
  static final LatLng compayLatLng =
      const LatLng(37.552720979146, 126.95637149707);

  // "애오개역" 위치로 카메라를 잡겠다.
  static final CameraPosition initalPosition =
      CameraPosition(target: compayLatLng, zoom: 15);

  // "자신의 위치"가 애오개역 근방 100m에 속할 떄
  // 보여주는 Blue Circle
  final Circle withinCircle = Circle(
    circleId: CircleId('withinCircle'),
    fillColor: Colors.blueAccent.withOpacity(0.2),
    center: compayLatLng,

    // 반지름 100m 설정
    radius: 100.0,
    strokeWidth: 2,
    strokeColor: Colors.amberAccent,
  );

  // "자신의 위치"가 애오개역 100m 반경에 속하지 않을 떄
  // 보여주는 Red Circle
  final Circle notWithinCircle = Circle(
    circleId: CircleId('notWithinCircle'),
    fillColor: Colors.redAccent.withOpacity(0.2),
    center: compayLatLng,

    // 반지름 100m 설정
    radius: 100.0,
    strokeWidth: 2,
    strokeColor: Colors.amberAccent,
  );

  // "자신의 위치"가 애오개역 100m 반경에 속하고 check까지 끝낼 떄
  // 보여주는 Green Circle
  final Circle checkCircle = Circle(
    circleId: CircleId('checkCircle'),
    fillColor: Colors.green.withOpacity(0.2),
    center: compayLatLng,

    // 반지름 100m 설정
    radius: 100.0,
    strokeWidth: 2,
    strokeColor: Colors.amberAccent,
  );

  // "애오개역"을 Marker로 표시한다.
  final Marker makrer =
      Marker(markerId: MarkerId('marker'), position: compayLatLng);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: rebderAppBar(),

      // async Method를 제어하는 FutureBuilder Widget
      // 한 흐름이 먼저 가고 async Method가 끝나면 다시 builder()를 실행한다.
      body: FutureBuilder(
        // 위치 권한을 확인하는 Static Async Method
        future: LocationAuthorization.checkPermission(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          print('FutureBulder - builder()가 실행됩니다.');

          if (snapshot.connectionState == ConnectionState.waiting) {
            print('Loading Bar를 실행합니다.');
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data == '위치 권한을 허용하였습니다.') {
            print('위치 권한 허용으로 Google Map를 보여줍니다.');

            // "자신의 위치가" 바뀔 떄 마다 호출하는 StreamBuilder
            // "자신의 위치가 바뀌면 StreamBuilder - builder()를 다시 실행합니다."
            return StreamBuilder(
              stream: Geolocator.getPositionStream(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                print('자신의 위치가 바뀌어서 StreamBuilder - builder()가 실행됩니다.');

                // 자신의 위치가 사정권에 들어왔는 지 판단하는 Control Variable
                bool isWithin = false;

                if (snapshot.hasData) {
                  // "자신의 위치"
                  final myLocation = snapshot.data;
                  // "회사의 위치"
                  final destLocation = compayLatLng;

                  // "자신의 위치"와 "회사의 위치" 거리 계산
                  final distance = Geolocator.distanceBetween(
                      myLocation.latitude,
                      myLocation.longitude,
                      destLocation.latitude,
                      destLocation.longitude);

                  // "자신의 위치"와 "회사의 위치"간 거리가 100m 여부 인지 확인
                  if (distance < 100.0) {
                    isWithin = true;
                  }
                }

                return Column(
                  children: [
                    // Google Map를 보여주는 Widget
                    CustomGoogleMap(
                      initalPosition: initalPosition,
                      // 사실 연속으로 해서 조건 연산자는 추천하지 않지만,
                      // 간혹 코드를 이렇게 쓰는 page가 있어서 한번 써봤습니다.
                      circle: isWorked
                          ? checkCircle
                          : isWithin
                              ? withinCircle
                              : notWithinCircle,
                      marker: makrer,
                      completer: _completer,
                    ),
                    // 하단 Button을 보여주는 Widget
                    ChoolCheckButton(
                      isWorked: isWorked,
                      isWithin: isWithin,
                      workButton: workButton,
                    ),
                  ],
                );
              },
            );
          } 
          else {
            print('위치 권한 비허용으로  Google Map를 보여주지 않습니다.');
            return Center(
              child: Text(snapshot.data),
            );
          }
        },
      ),
    );
  }

  

  // Custom AppBar
  AppBar rebderAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      title: const Text(
        '오늘도 출근',
        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w700),
      ),
      actions: [
        IconButton(
          onPressed: () async {
            // Gelocator Package를 활용해 current Location을 가져온다.
            Position currentLocation = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high);

            // 현재 위치 위도, 경도를 가져온다.
            double longitude = currentLocation.latitude;
            double latitude = currentLocation.longitude;

            // 현재 위치로 Camera Animate
            final c = await _completer.future;
            final p =
                CameraPosition(target: LatLng(longitude, latitude), zoom: 15.0);

            c.animateCamera(CameraUpdate.newCameraPosition(p));
          },

          icon: Icon(
            Icons.location_searching_rounded,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  // "출근하기" Button을 누를 떄 호출되는 Method
  void workButton() async {
    final bool isResult = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text(
              '출근 등록 Dialog',
            ),
            content: Text('출근을 확정하려면 "출근하기" 버튼을 눌러주세요'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text('출근하기'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text('취소'),
              ),
            ],
          );
        });

    // "출근하기" Button을 눌렀을 떄 Event 처리
    if (isResult) {
      setState(() {
        isWorked = true;
      });
    }
  }
}



