import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

typedef GridItemOnTap = void Function(GridItem item);

///PageView 与 GridView 结合 完成网格布局分页显示
/// 根据每页个数再计算GridView中item的宽高比, 以每页8个效果最佳
class PagerGridLayout extends StatefulWidget {
  //每页最多网格数
  final int numberPerPage;
  final List<GridItem> list;
  final GridItemOnTap gridItemOnTap;

  PagerGridLayout({
      @required this.list,
      this.numberPerPage = 8,
      this.gridItemOnTap
  }){
      assert(numberPerPage.isEven);
  }


  @override
  State<StatefulWidget> createState() {
    return PagerGridLayoutState(list: list, numberPerPage: numberPerPage, gridItemOnTap: gridItemOnTap);
  }
}

class PagerGridLayoutState extends State<PagerGridLayout> {
  //每页最多网格数
  final int numberPerPage;
  final List<GridItem> list;
  final GridItemOnTap gridItemOnTap;

  PagerGridLayoutState({this.list, this.numberPerPage, this.gridItemOnTap});

  PageController _pageController = PageController();

  //计算页数
  int _pageCount;
  //当前页数
  int _currentPage = 0;

  List<List<GridItem>> _pageList = [];

  @override
  void initState() {
    super.initState();

    //计算页数  向上取整, 一页不满也算一页
    _pageCount = (list.length / numberPerPage).ceil();

    //每页所对应的网格项列表
    for (int i = 0; i < _pageCount; i++) {
      if (list.length > numberPerPage) {
        _pageList.add(list.sublist(0, numberPerPage));
        list.removeRange(0, numberPerPage);
      } else {
        _pageList.add(list.sublist(0));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);

    return Scaffold(
      body: Card(
        child: Container(
          color: Colors.black12,
          padding: EdgeInsets.symmetric(vertical: 35.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                height: ScreenUtil.screenWidth / 2,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pageCount,
                  itemBuilder: (context, index) {
                    return GridPage(_pageList[index], numberPerPage, gridItemOnTap);
                  },
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pageCount, (index) {
                  Color color = (index != _currentPage) ? Colors.black12 : Colors.orangeAccent;
                  return _buildIndicator(color);
                }),
              )
            ],
          ),
        ),
      ),
    );
  }

  //指示器
  Widget _buildIndicator(Color color) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      color: color,
      width: 40.w,
      height: 8.h,
    );
  }
}

class GridPage extends StatelessWidget {
  final int numberPerPage;
  final List<GridItem> list;
  final GridItemOnTap gridItemOnTap;

  GridPage(this.list, this.numberPerPage, this.gridItemOnTap);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GridView.count(
        //每个页面只有两行,
        crossAxisCount: (numberPerPage / 2).floor(),

        //宽高比    宽 = ScreenUtil.screenWidth / (numberPerPage / 2)   高 = (ScreenUtil.screenWidth / 4)
        childAspectRatio: (numberPerPage / 8),
        children: list.map((item) {
          return _buildGridItem(item);
        }).toList(),
      ),
    );
  }

  Widget _buildGridItem(GridItem item) {
    return GestureDetector(
      onTap: () {gridItemOnTap(item);},
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Icon(item.iconData, color: item.color, size: 45.w),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.h),
              child: Text(
                "${item.itemName}",
                style: TextStyle(fontSize: 23.sp),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class GridItem {
  final int id;
  final IconData iconData;
  final Color color;
  final String itemName;

  GridItem(this.id, this.iconData, this.color, this.itemName);

  @override
  String toString() {
    return 'GridItem{id: $id, iconData: $iconData, color: $color, itemName: $itemName}';
  }
}
