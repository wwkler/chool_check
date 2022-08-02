// Button을 Click하는 Under Widget
import 'package:flutter/material.dart';

class ChoolCheckButton extends StatelessWidget {
  final bool isWorked;
  final bool isWithin;
  final VoidCallback workButton;

  const ChoolCheckButton({
    required this.isWorked,
    required this.isWithin,
    required this.workButton,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(
            Icons.location_on,
            size: 50.0,
            // 원래 연속해서 조건 연산자 쓰는 것을 추천하지 않지만,
            // 가끔 코드를 이렇게 쓰는 Page가 있다. 그냥 이렇게 써봤다.
            color: isWorked
                ? Colors.greenAccent
                : isWithin
                    ? Colors.blueAccent
                    : Colors.redAccent,
          ),
          //  "출근 확정"이 아닌 상황에서 자신의 위치가 100m 안에 있을 경우
          if (!isWorked && isWithin)
            TextButton(
              onPressed: workButton,
              child: Text(
                '출근하기',
                style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
              ),
            )
        ],
      ),
    );
  }
}
