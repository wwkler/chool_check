import 'package:geolocator/geolocator.dart';

class LocationAuthorization {
  
  // 위치 권한을 확인하고 제어하는 Static Method 
  // 객체를 만들지 않고 쉽게 접근할 수 있도록 Static Method로 설정했다.
   static Future<String> checkPermission() async {
    // 사용자가 위치 활성화 했는지 여부 확인하는 코드
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();

    if (!isLocationEnabled) {
      return "위치 활성화를 켜주세요...";
    }

    LocationPermission checkPermission = await Geolocator.checkPermission();
    // APP을 켤 떄 위치 권한 허용 정보가 "Denied"일 경우
    if (checkPermission == LocationPermission.denied) {
      // 위치 권한 화면에 Floating 한다.
      checkPermission = await Geolocator.requestPermission();

      // Floating된 위치 권한 화면에 "Denided"를 Click할 경우
      if (checkPermission == LocationPermission.denied) {
        return "위치 권한을 허용하지 않았습니다.";
      }
    }

    // APP을 켤 떄 위치 권한 허용 정보가 "Denided Forever"인 경우
    // 맨 처음 APP을 켤 떄 위치 권한 허용 정보가 "Denied"인 상태에서 Floating된 위치 권한 화면에
    // "Denided"를 Click했고, 다시 APP을 작동시켰을 떄가 해당된다.
    if (checkPermission == LocationPermission.deniedForever) {
      return "위치 권한을 허용하지 않았습니다.";
    }

    // 위치 권한을 허용한 경우
    return "위치 권한을 허용하였습니다.";
  }
}