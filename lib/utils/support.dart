// import 'package:flutter/material.dart';

// enum DecisionOptionType { NORMAL, EXPECTATION, WARNING, DENIED }

// class DecisionOption {
//   String title;
//   DecisionOptionType type;
//   bool isImportant;
//   bool isCompleteDecision;
//   Function? onDecisionPressed;

//   DecisionOption(this.title,
//       {this.type = DecisionOptionType.NORMAL,
//       this.isImportant = false,
//       this.isCompleteDecision = true,
//       required this.onDecisionPressed});
// }

// showDecisionDialog(String decisionMessage,
//     {required BuildContext cxt,
//     required List<DecisionOption> lstOptions,
//     String? decisionDescription}) {
//   var themeData = Theme.of(cxt);
//   return showDialog<void>(
//       context: cxt,
//       barrierDismissible: false, // user must tap button!
//       builder: (BuildContext context) {
//         return Container(
//             alignment: AlignmentDirectional.center,
//             padding: const EdgeInsets.all(12),
//             child: Container(
//               decoration: BoxDecoration(
//                   borderRadius: const BorderRadius.all(Radius.circular(12)),
//                   color: themeData.colorScheme.background),
//               padding: const EdgeInsets.only(
//                   left: 24, top: 35, right: 24, bottom: 15),
//               constraints:
//                   BoxConstraints(maxWidth: MediaQuery.of(cxt).size.width / 0.8),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     decisionMessage,
//                     style: themeData.textTheme.headlineMedium,
//                   ),
//                   decisionDescription != null
//                       ? Padding(
//                           padding: const EdgeInsets.symmetric(
//                             vertical: 12,
//                             horizontal: 12,
//                           ),
//                           child: Text(
//                             decisionDescription,
//                             style: themeData.textTheme.bodyMedium!.copyWith(),
//                           ),
//                         )
//                       : Container(),
//                   const SizedBox(height: 12),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Container(),
//                       Expanded(
//                           child: Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: lstOptions.map<Widget>((e) {
//                           var _optionTextColor;
//                           switch (e.type) {
//                             case DecisionOptionType.NORMAL:
//                               _optionTextColor = Colors.blue;
//                               break;
//                             case DecisionOptionType.EXPECTATION:
//                               _optionTextColor = Colors.green;
//                               break;
//                             case DecisionOptionType.WARNING:
//                               _optionTextColor = Colors.yellow;
//                               break;
//                             case DecisionOptionType.DENIED:
//                               _optionTextColor = Colors.red;
//                               break;
//                           }
//                           return TextButton(
//                               onPressed: () async {
//                                 if (e.isCompleteDecision) {
//                                   Navigator.of(context).pop();
//                                 }
//                                 if (e.onDecisionPressed != null) {
//                                   e.onDecisionPressed!.call();
//                                 }
//                               },
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 2.5, vertical: 1),
//                                 child: Text(
//                                   e.title,
//                                   style: themeData.textTheme.bodyMedium!
//                                       .copyWith(
//                                           color: _optionTextColor,
//                                           fontWeight: e.isImportant
//                                               ? FontWeight.bold
//                                               : FontWeight.normal),
//                                 ),
//                               ));
//                         }).toList(),
//                       ))
//                     ],
//                   )
//                 ],
//               ),
//             ));
//       });
// }
