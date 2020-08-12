import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_flutter_library/widget/PagerGridLayout.dart';

class PagerGridPage extends StatefulWidget{

    @override
  State<StatefulWidget> createState() {
    return PagerGridPageState();
  }
}

class PagerGridPageState extends State<PagerGridPage>{

    List<GridItem> list = [
      GridItem(0, FontAwesomeIcons.facebookF, Colors.indigo, "facebook"),
      GridItem(1, FontAwesomeIcons.twitter, Colors.indigo, "twitter"),
      GridItem(2, FontAwesomeIcons.whatsapp, Colors.indigo, "whatsapp"),
      GridItem(3, FontAwesomeIcons.amazon, Colors.indigo, "amazon"),
      GridItem(4, FontAwesomeIcons.qq, Colors.indigo, "qq"),
      GridItem(5, FontAwesomeIcons.microsoft, Colors.indigo, "microsoft"),
      GridItem(6, FontAwesomeIcons.firefox, Colors.indigo, "firefox"),
      GridItem(7, FontAwesomeIcons.youtube, Colors.indigo, "youtube"),
      GridItem(8, FontAwesomeIcons.twitch, Colors.indigo, "twitch"),
      GridItem(9, FontAwesomeIcons.weibo, Colors.indigo, "weibo"),
      GridItem(10, FontAwesomeIcons.steam, Colors.indigo, "steam"),
      GridItem(11, FontAwesomeIcons.googlePlay, Colors.indigo, "googlePlay"),
      GridItem(12, FontAwesomeIcons.instagram, Colors.indigo, "instagram"),
      GridItem(14, FontAwesomeIcons.pinterest, Colors.indigo, "pinterest"),
      GridItem(15, FontAwesomeIcons.google, Colors.indigo, "google"),

      GridItem(0, FontAwesomeIcons.facebookF, Colors.indigo, "facebook"),
      GridItem(1, FontAwesomeIcons.twitter, Colors.indigo, "twitter"),
      GridItem(2, FontAwesomeIcons.whatsapp, Colors.indigo, "whatsapp"),
      GridItem(3, FontAwesomeIcons.amazon, Colors.indigo, "amazon"),
      GridItem(4, FontAwesomeIcons.qq, Colors.indigo, "qq"),
      GridItem(5, FontAwesomeIcons.microsoft, Colors.indigo, "microsoft"),
      GridItem(6, FontAwesomeIcons.firefox, Colors.indigo, "firefox"),
      GridItem(7, FontAwesomeIcons.youtube, Colors.indigo, "youtube"),
      GridItem(8, FontAwesomeIcons.twitch, Colors.indigo, "twitch"),
      GridItem(9, FontAwesomeIcons.weibo, Colors.indigo, "weibo"),
      GridItem(10, FontAwesomeIcons.steam, Colors.indigo, "steam"),
      GridItem(11, FontAwesomeIcons.googlePlay, Colors.indigo, "googlePlay"),
      GridItem(12, FontAwesomeIcons.instagram, Colors.indigo, "instagram"),
      GridItem(14, FontAwesomeIcons.pinterest, Colors.indigo, "pinterest"),
      GridItem(15, FontAwesomeIcons.google, Colors.indigo, "google"),

      GridItem(0, FontAwesomeIcons.facebookF, Colors.indigo, "facebook"),
      GridItem(1, FontAwesomeIcons.twitter, Colors.indigo, "twitter"),
      GridItem(2, FontAwesomeIcons.whatsapp, Colors.indigo, "whatsapp"),
      GridItem(3, FontAwesomeIcons.amazon, Colors.indigo, "amazon"),
      GridItem(4, FontAwesomeIcons.qq, Colors.indigo, "qq"),
      GridItem(5, FontAwesomeIcons.microsoft, Colors.indigo, "microsoft"),
      GridItem(6, FontAwesomeIcons.firefox, Colors.indigo, "firefox"),
      GridItem(7, FontAwesomeIcons.youtube, Colors.indigo, "youtube"),
      GridItem(8, FontAwesomeIcons.twitch, Colors.indigo, "twitch"),
      GridItem(9, FontAwesomeIcons.weibo, Colors.indigo, "weibo"),
      GridItem(10, FontAwesomeIcons.steam, Colors.indigo, "steam"),
      GridItem(11, FontAwesomeIcons.googlePlay, Colors.indigo, "googlePlay"),
      GridItem(12, FontAwesomeIcons.instagram, Colors.indigo, "instagram"),
      GridItem(14, FontAwesomeIcons.pinterest, Colors.indigo, "pinterest"),
      GridItem(15, FontAwesomeIcons.google, Colors.indigo, "google"),
    ];

    @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("网格分页"),
            centerTitle: true,
        ),
        body: PagerGridLayout(
            list: list,
            numberPerPage: 8,
            gridItemOnTap: (GridItem item){
                print("你点击了 $item");
            },
        ),
    );
  }
}