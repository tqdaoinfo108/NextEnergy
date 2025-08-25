
//     import 'package:flutter/widgets.dart';
// import 'package:get/get.dart';

// Widget buildIsBegingStarted(BuildContext context) {
//       return Obx(() => Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//             child: Column(
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     SizedBox(
//                         width: 60,
//                         height: 60,
//                         child: Lottie.asset('assets/images/charging.json')),
//                     const SizedBox(height: 10),
//                     Text(TKeys.charging.translate(),
//                         style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                             color: Theme.of(context).primaryColor,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 24))
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 Image.asset(
//                   "assets/images/charge.gif",
//                   width: Get.width / 2,
//                 ),
//                 const SizedBox(height: 12),
//                 Text(TKeys.do_note_remove_flag.translate(),
//                     textAlign: TextAlign.center,
//                     style: Theme.of(context).textTheme.bodyLarge),
//                 const SizedBox(height: 12),
//                 Text(
//                     "${controller.getTimeStillText.value} / ${controller.getTimeTotalsText.value}",
//                     style: Theme.of(context)
//                         .textTheme
//                         .bodyLarge!
//                         .copyWith(fontSize: 15)),
//                 FAProgressBar(
//                   backgroundColor:
//                       Theme.of(context).primaryColor.withOpacity(0.2),
//                   currentValue: controller.percentProcessbar.value,
//                   maxValue: controller.bookingData?.getDurationTimeEnd ?? 100,
//                   displayText: '',
//                   displayTextStyle: const TextStyle(fontSize: 0),
//                   progressGradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: const Alignment(0.8, 1),
//                     colors: <Color>[
//                       Theme.of(context).primaryColor,
//                       Theme.of(context).primaryColor.withOpacity(0.7),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     buildButtonClose(context),
//                     const SizedBox(width: 12),
//                     buildButton(context),
//                   ],
//                 ),
//               ],
//             ),
//           ));
//     }