import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v2/pages/customs/appbar.dart';
import 'package:v2/pages/customs/dialog_custom.dart';
import 'package:v2/services/localization_service.dart';


import '../../model/payment_info.dart';

class PaymentListPage extends StatefulWidget {
  const PaymentListPage({super.key});

  @override
  State<PaymentListPage> createState() => _PaymentListPageState();
}

class _PaymentListPageState extends State<PaymentListPage> {
  late List<PaymentInfoModel> listCard;
  @override
  void initState() {
    super.initState();
    setState(() {
      listCard = PaymentInfoModel.getListCard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(
        title: Text(
          TKeys.payment_method.translate(),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        actions: [
          IconButton(
              onPressed: () async {
                await Get.toNamed("/payment_form");
                setState(() {
                  listCard = PaymentInfoModel.getListCard();
                });
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: SafeArea(
          child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
            child: Text(
              TKeys.list_payment_note.translate(),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: Colors.grey),
            ),
          ),
          Expanded(
            child: listCard.isEmpty
                ? Center(child: Text(TKeys.no_info_credit_card.translate()))
                : ListView.builder(
                    itemCount: listCard.length,
                    itemBuilder: (context, i) {
                      return buildCard(i);
                    }),
          ),
        ],
      )),
    );
  }

  buildCard(int index) {
    var cardType = PaymentInfoModel.detectCCType(listCard[index].numberCard!);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  PaymentInfoModel.getImageCard(PaymentInfoModel.detectCCType(
                      listCard[index].numberCard)),
                  color: cardType == CardTypeCustom.visa
                      ? Colors.blue.shade900
                      : null,
                  width: 42,
                  height: 42,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      PaymentInfoModel.removeNumberCard(
                          listCard[index].numberCard),
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(listCard[index].cardHolder!,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        InkWell(
                            child: Text(
                              TKeys.edit.translate(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      color: Theme.of(context).primaryColor),
                            ),
                            onTap: () async {
                              await Get.toNamed("/payment_form",
                                  arguments: listCard[index]);
                              setState(() {
                                listCard = PaymentInfoModel.getListCard();
                              });
                            }),
                        const SizedBox(width: 8),
                        InkWell(child: const Text("|"), onTap: () {}),
                        const SizedBox(width: 8),
                        InkWell(
                            child: Text(TKeys.delete.translate(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                        color: Theme.of(context).primaryColor)),
                            onTap: () {
                              showDialogCustom(context, () {
                                PaymentInfoModel.removeCard(
                                    listCard[index].numberCard);
                                setState(() {
                                  listCard = PaymentInfoModel.getListCard();
                                });
                              },
                                  title: TKeys.delete.translate(),
                                  question:
                                      TKeys.you_want_proces.translate());
                            }),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
