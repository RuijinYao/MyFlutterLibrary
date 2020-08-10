import 'dart:math';
import 'package:flutter/material.dart';

///AnimatedList 一个滚动容器，可在插入或移除项目时为其设置动画
class AnimatedListPage extends StatefulWidget {
  @override
  State<AnimatedListPage> createState() => AnimatedListPageState();
}

class AnimatedListPageState extends State<AnimatedListPage> {
  //动画类型, 1-平移  2-缩放  3-淡化
  int type = 1;
  List<String> typeName = ["平移", "缩放", "淡化"];

  var _data = <String>[];
  final _myListKey = GlobalKey<AnimatedListState>();

  //平移
  Tween<Offset> offsetTween = Tween<Offset>(
    begin: Offset(1, 0),
    end: Offset(0, 0),
  );

  Widget myOffsetItem(String d, animation) {
    return SlideTransition(
      position: animation.drive(offsetTween),
      child: myItem(d),
    );
  }

  //缩放
  Tween<double> scaleTween = Tween<double>(
    begin: 0,
    end: 1,
  );

  Widget myScaleItem(String d, animation) {
    return ScaleTransition(
      scale: animation.drive(scaleTween),
      child: myItem(d),
    );
  }

  //淡化
  Tween<double> fadeInTween = Tween<double>(
    begin: 0,
    end: 1,
  );

  Widget myFadeInItem(String d, animation) {
    return FadeTransition(
      opacity: animation.drive(scaleTween),
      child: myItem(d),
    );
  }

  Widget myItem(String d) {
    return ListTile(
      title: Text(
        '$d',
        style: TextStyle(fontSize: 40),
      ),
      trailing: IconButton(
        onPressed: () {
          var index = _data.indexOf(d);

          _myListKey.currentState.removeItem(index, (context, animation){
              //此处 d 已经从_data中移除, 即使将 _data.remove(d) 放在最后
              print(_data);
              return type == 1
                  ? myOffsetItem(d, animation)
                  : type == 2 ? myScaleItem(d, animation) : myFadeInItem(d, animation);
          });

          _data.remove(d);
        },
        icon: Icon(Icons.delete_forever),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('AnimatedList - ${typeName[type - 1]}'),
        actions: <Widget>[
          PopupMenuButton(onSelected: (int value) {
            setState(() {
                type = value;
            });
          }, itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(
                value: 1,
                child: Text('平移'),
              ),
              PopupMenuItem(
                value: 2,
                child: Text('缩放'),
              ),
              PopupMenuItem(
                value: 3,
                child: Text('淡化'),
              ),
            ];
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          String newv = Random().nextInt(1000).toString();
          _data.add(newv);
          var index = _data.lastIndexOf(newv);
          _myListKey.currentState.insertItem(index);
        },
        child: Icon(Icons.add),
      ),
      body: AnimatedList(
        key: _myListKey,
        initialItemCount: _data.length,
        itemBuilder: (context, int index, Animation<double> animation) {
          return type == 1
              ? myOffsetItem(_data[index], animation)
              : type == 2 ? myScaleItem(_data[index], animation) : myFadeInItem(_data[index], animation);
        },
      ),
    );
  }
}
