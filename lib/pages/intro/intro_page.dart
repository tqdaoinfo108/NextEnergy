import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:lottie/lottie.dart';

import '../../services/base_hive.dart';
import '../../utils/const.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return IntroSlider(
      key: UniqueKey(),
      renderNextBtn: const Text("Tiếp theo"),
      renderDoneBtn: const Text("Hoàn tất"),
      renderSkipBtn: const SizedBox(),
      listContentConfig: [
        ContentConfig(
          heightImage: Get.height / 4,
          pathImage: "assets/images/logo.png",
          widgetDescription: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: DefaultTextStyle.of(context).style.copyWith(fontSize: 18),
              children: const <TextSpan>[
                TextSpan(
                    text: 'Xin chào !\n\n',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
                TextSpan(
                    text:
                        'Cảm ơn bạn đã sử dụng Next Energy. Trước tiên, vui lòng xác nhận thông tin cần thiết để sử dụng ứng dụng.'),
              ],
            ),
          ),
        ),
        ContentConfig(
          widgetTitle: SizedBox(
              height: Get.height / 3,
              child: Column(
                children: [
                  Image.asset("assets/images/logo.png", width: 64),
                  Spacer(),
                  Lottie.asset("assets/images/intro_2.json", width: Get.width/2),
                ],
              )),
          widgetDescription: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: DefaultTextStyle.of(context).style.copyWith(fontSize: 18),
              children: const <TextSpan>[
                TextSpan(text: 'Để sử dụng ứng dụng NextEnergy\ncần bật quyền「'),
                TextSpan(
                    text: 'Vị trí',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: '」. Dựa trên'),
                TextSpan(
                    text: 'vị trí',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                    text:
                        'của điện thoại thông minh, bạn sẽ có thể tìm kiếm các trạm EV gần đó và sử dụng các dịch vụ dựa trên vị trí.'),
              ],
            ),
          ),
        ),
        ContentConfig(
          widgetTitle: SizedBox(
              height: Get.height / 3,
              child: Column(
                children: [
                  Image.asset("assets/images/logo.png", width: 64),
                  Spacer(),
                  Lottie.asset("assets/images/intro_3.json",
                      width: Get.width / 2),
                ],
              )),
          widgetDescription:RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: DefaultTextStyle.of(context).style.copyWith(fontSize: 18),
              children: const <TextSpan>[
                TextSpan(text: 'Ứng dụng NextEnergy có thể đặt trước việc sạc bằng cách quét mã QR bằng camera. Để quét mã QR, bạn cần bật quyền camera.'),
                
              ],
            ),
          ),
        ),
        ContentConfig(
          heightImage: Get.height / 3,
          widgetTitle: SizedBox(
              height: Get.height / 3,
              child: Column(
                children: [
                  Image.asset("assets/images/logo.png", width: 64),
                  Spacer(),
                  Image.asset("assets/images/intro_4.png",
                      width: Get.width / 2),
                ],
              )),
          widgetDescription: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: DefaultTextStyle.of(context).style.copyWith(fontSize: 18),
              children: const <TextSpan>[
                TextSpan(text: 'Có thể sạc bằng thao tác từ ứng dụng! Việc điều khiển sạc giữa ứng dụng NextEnergy và trạm sạc được thực hiện qua kết nối '),
                TextSpan(
                    text: 'Bluetooth',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: '. Để sử dụng ứng dụng, vui lòng cho phép quyền「'),
                TextSpan(
                    text: 'Bluetooth',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                  text: '」.',
                ),
              ],
            ),
          ),
        ),
      ],
      onDonePress: () {
        HiveHelper.put(Constants.INTRO, true);
        Get.offAndToNamed("/login");
      },
    );
  }
}
