import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_flutter_library/entity/Vote.dart';
import 'package:my_flutter_library/widget/TestWidget.dart';

class VotePage extends StatefulWidget {
  VotePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<VotePage> {

  String myChosen;
  int total = 0;
  List<Vote> votes = [
    Vote(1, "选项一", 2),
    Vote(2, "选项二", 5),
    Vote(3, "选项三", 9),
    Vote(4, "选项四", 8),
    Vote(5, "选项五", 3),
    Vote(6, "选项六", 11),
  ];

  @override
  void initState() {
    super.initState();
    Vote maxCountVote = votes.reduce((vote1, vote2){
      return vote1.count > vote2.count ? vote1 : vote2;
    });
    Vote mixCountVote = votes.reduce((vote1, vote2){
      return vote1.count < vote2.count ? vote1 : vote2;
    });

    total = maxCountVote.count + mixCountVote.count;
  }
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("自定义投票"),
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 40.w),
          child: ListView(
            children: votes.map((vote){
              return GestureDetector(
                onTap: (){
                  if(myChosen == null){
                    setState(() {
                      vote.count = vote.count + 1;
                      myChosen = vote.voteName;
                    });
                    return;
                  }

                  if(myChosen == vote.voteName){
                    setState(() {
                      vote.count = vote.count - 1;
                      myChosen = null;
                    });
                  }
                },
                child: TestWidget(
                  itemName: vote.voteName,
                  value: vote.count,
                  count: total,
                  myChosen: myChosen,
                ),
              );
            }).toList(),
          ),
        )
    );
  }
}

