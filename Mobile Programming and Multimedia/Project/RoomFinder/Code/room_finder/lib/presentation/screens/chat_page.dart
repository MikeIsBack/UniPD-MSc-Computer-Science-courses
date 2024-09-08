import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:room_finder/presentation/components/chat_item.dart';
import 'package:room_finder/presentation/components/error_messages.dart';
import 'package:room_finder/presentation/components/screens_templates.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:room_finder/presentation/screens/chat_detail_page.dart';
import 'package:room_finder/util/network_handler.dart';

class StudentChatPage extends ConsumerWidget {
const StudentChatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkStatus = ref.watch(networkAwareProvider);

    return MainTemplateScreen(
        screenLabel: AppLocalizations.of(context)!.lblChatPage,
        screenContent: networkStatus == NetworkStatus.off
            ? Center(
                heightFactor: 6.h,
                child: NoInternetErrorMessage(context: context))
            : Column(children: [
                ChatItem(
                    receiverPhoto:
                        "https://shotkit.com/wp-content/uploads/2020/04/david-hurley-xHKVr_OPTFI-unsplash.jpg",
                    facilityPhoto:
                        "https://media.mondoconv.it/media/catalog/product/cache/9183606dc745a22d5039e6cdddceeb98/X/A/XABP_1LVL.jpg",
                    receiverName: "Giada Rossi",
                    facilityName: "Casa Dolce Casa",
                    address: "Via Roma 12",
                    lastMessage: DateTime(2024, 7, 1),
                    isLastChatItem: false,
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ChatDetailPage(
                            receiverImageUrl:
                                "https://shotkit.com/wp-content/uploads/2020/04/david-hurley-xHKVr_OPTFI-unsplash.jpg",
                            receiverName: "Giada Rossi",
                            facilityName: "Casa Dolce Casa",
                            lastMessage: DateTime(2024, 7, 1),
                            isHost: false,
                            onTap: () => {})))),
                ChatItem(
                    receiverPhoto:
                        "https://www.fotografareperstupire.com/wp-content/uploads/2023/03/pose-per-foto-uomo-selfie.jpg",
                    facilityPhoto:
                        "https://cdn.cosedicasa.com/wp-content/uploads/webp/2022/05/cucina-e-soggiorno-640x320.webp",
                    receiverName: "Mario Guidi",
                    facilityName: "Bella Italia",
                    address: "Via Belzoni 5",
                    lastMessage: DateTime(2024, 6, 28),
                    isLastChatItem: false,
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ChatDetailPage(
                            receiverImageUrl:
                                "https://www.fotografareperstupire.com/wp-content/uploads/2023/03/pose-per-foto-uomo-selfie.jpg",
                            receiverName: "Mario Guidi",
                            facilityName: "Bella Italia",
                            lastMessage: DateTime(2024, 6, 28),
                            isHost: false,
                            onTap: () => {})))),
                ChatItem(
                    receiverPhoto:
                        "https://www.fotografareperstupire.com/wp-content/uploads/2023/03/pose-modello-uomo.jpg",
                    facilityPhoto:
                        "https://www.grazia.it/content/uploads/2018/03/come-arredare-monolocale-sfruttando-centimetri-2.jpg",
                    receiverName: "Luigi Frassi",
                    facilityName: "Casa Studenti",
                    address: "Viale Luna 289",
                    lastMessage: DateTime(2024, 6, 25),
                    isLastChatItem: false,
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ChatDetailPage(
                            receiverImageUrl:
                                "https://www.fotografareperstupire.com/wp-content/uploads/2023/03/pose-modello-uomo.jpg",
                            receiverName: "Luigi Frassi",
                            facilityName: "Casa Studenti",
                            lastMessage: DateTime(2024, 6, 25),
                            isHost: false,
                            onTap: () => {})))),
                ChatItem(
                    receiverPhoto:
                        "https://dy7glz37jgl0b.cloudfront.net/advice/images/3f64195ec17bf2d488a315987f4861e5-woman-smiles-while-crossing-the-street-in-a-city_l.jpg",
                    facilityPhoto:
                        "https://www.fiorenzointeriordesign.com/images/galcms/850x635c50q80/galleryone/gallery-prodotto-test/zoom/img_6206_65721.jpg",
                    receiverName: "Serena Pizzoli",
                    facilityName: "Casa Studio",
                    address: "Via Vittoria 10",
                    lastMessage: DateTime(2024, 6, 20),
                    isLastChatItem: true,
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ChatDetailPage(
                            receiverImageUrl:
                                "https://dy7glz37jgl0b.cloudfront.net/advice/images/3f64195ec17bf2d488a315987f4861e5-woman-smiles-while-crossing-the-street-in-a-city_l.jpg",
                            receiverName: "Serena Pizzoli",
                            facilityName: "Casa Studio",
                            lastMessage: DateTime(2024, 6, 20),
                            isHost: false,
                            onTap: () => {}))))
              ]));
  }
}

class HostChatPage extends ConsumerWidget {
  const HostChatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkStatus = ref.watch(networkAwareProvider);

    return MainTemplateScreen(
        screenLabel: AppLocalizations.of(context)!.lblChatPage,
        screenContent: networkStatus == NetworkStatus.off
            ? Center(
                heightFactor: 6.h,
                child: NoInternetErrorMessage(context: context))
            : Column(children: [
                ChatItem(
                    receiverPhoto:
                        "https://i0.wp.com/digital-photography-school.com/wp-content/uploads/2021/03/people-posing-photography-1003.jpg?w=1264&ssl=1",
                    facilityPhoto:
                        "https://media.mondoconv.it/media/catalog/product/cache/9183606dc745a22d5039e6cdddceeb98/X/A/XABP_1LVL.jpg",
                    receiverName: "Luna Delis",
                    facilityName: "Casa Dolce Casa",
                    address: "Via Roma 12",
                    lastMessage: DateTime(2024, 7, 1),
                    isLastChatItem: false,
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ChatDetailPage(
                            receiverImageUrl:
                                "https://i0.wp.com/digital-photography-school.com/wp-content/uploads/2021/03/people-posing-photography-1003.jpg?w=1264&ssl=1",
                            receiverName: "Luna Delis",
                            facilityName: "Casa Dolce Casa",
                            lastMessage: DateTime(2024, 7, 1),
                            isHost: true,
                            onTap: () => {})))),
                ChatItem(
                    receiverPhoto:
                        "https://cdn.create.vista.com/api/media/medium/319362956/stock-photo-man-pointing-showing-copy-space-isolated-on-white-background-casual-handsome-caucasian-young-man?token=",
                    facilityPhoto:
                        "https://cdn.cosedicasa.com/wp-content/uploads/webp/2022/05/cucina-e-soggiorno-640x320.webp",
                    receiverName: "Mario Rossi",
                    facilityName: "Casa Dolce Casa",
                    address: "Via Roma 12",
                    lastMessage: DateTime(2024, 6, 28),
                    isLastChatItem: false,
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ChatDetailPage(
                            receiverImageUrl:
                                "https://cdn.create.vista.com/api/media/medium/319362956/stock-photo-man-pointing-showing-copy-space-isolated-on-white-background-casual-handsome-caucasian-young-man?token=",
                            receiverName: "Mario Rossi",
                            facilityName: "Casa Dolce Casa",
                            lastMessage: DateTime(2024, 6, 28),
                            isHost: true,
                            onTap: () => {})))),
                ChatItem(
                    receiverPhoto:
                        "https://www.c-and-a.com/image/upload/q_auto:good,ar_4:3,c_fill,g_auto:face,w_637/s/editorial/bewerbungstipps/bewerberknigge-bewerbungsfotos-text-media3.jpg",
                    facilityPhoto:
                        "https://www.grazia.it/content/uploads/2018/03/come-arredare-monolocale-sfruttando-centimetri-2.jpg",
                    receiverName: "Arianna Grandi",
                    facilityName: "Casa Dolce Casa",
                    address: "Via Roma 12",
                    lastMessage: DateTime(2024, 6, 25),
                    isLastChatItem: false,
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ChatDetailPage(
                            receiverImageUrl:
                                "https://www.c-and-a.com/image/upload/q_auto:good,ar_4:3,c_fill,g_auto:face,w_637/s/editorial/bewerbungstipps/bewerberknigge-bewerbungsfotos-text-media3.jpg",
                            receiverName: "Arianna Grandi",
                            facilityName: "Casa Dolce Casa",
                            lastMessage: DateTime(2024, 6, 25),
                            isHost: true,
                            onTap: () => {})))),
                ChatItem(
                    receiverPhoto:
                        "https://cdn.create.vista.com/api/media/medium/153585546/stock-photo-smiling-young-african-american-woman?token=",
                    facilityPhoto:
                        "https://www.fiorenzointeriordesign.com/images/galcms/850x635c50q80/galleryone/gallery-prodotto-test/zoom/img_6206_65721.jpg",
                    receiverName: "Serena Pizzoli",
                    facilityName: "Casa Dolce Casa",
                    address: "Via Roma 12",
                    lastMessage: DateTime(2024, 6, 20),
                    isLastChatItem: true,
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ChatDetailPage(
                            receiverImageUrl:
                                "https://cdn.create.vista.com/api/media/medium/153585546/stock-photo-smiling-young-african-american-woman?token=",
                            receiverName: "Serena Pizzoli",
                            facilityName: "Casa Dolce Casa",
                            lastMessage: DateTime(2024, 6, 20),
                            isHost: true,
                            onTap: () => {}))))
              ]));
  }
}
