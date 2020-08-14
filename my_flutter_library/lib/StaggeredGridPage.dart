import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:my_flutter_library/entity/Photos.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

///瀑布流, 网络缓存图片
class StaggeredGridPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StaggeredGridPageState();
  }
}

class StaggeredGridPageState extends State<StaggeredGridPage> {

  int _page = 0;
  int _size = 6;
  List<Photo> posts = [];

  RefreshController _controller = RefreshController();

  @override
  void initState() {
    super.initState();
    // 首次拉取数据
    _getPostData(true);
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: true);
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("瀑布流"),
        ),

        //StaggeredGridView有几列是由crossAxisCount除以StaggeredTile设置上的纵轴的数量的结果。
        body: SmartRefresher(
            controller: _controller,
            onRefresh: _refreshData,
            onLoading: _addMoreData,
            enablePullUp: true,
            child: StaggeredGridView.countBuilder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    mainAxisSpacing: 5.w,
                    crossAxisSpacing: 5.w,
                    crossAxisCount: 4,
                    itemCount: posts.length,
                    itemBuilder: (context, index) => TileCard(
                        img: '${posts[index].urls.regular}',
                        title: '${posts[index].description}',
                        author: '${posts[index].user.username}',
                        authorUrl: '${posts[index].user.profile_image.small}',
                    ),
                    staggeredTileBuilder: (int index) {
                        return StaggeredTile.fit(2);
                    },
            ),
        ),

    );
  }

  // 下拉刷新数据
  Future<Null> _refreshData() async {
    _page = 0;
    await _getPostData(false);

    _controller.refreshCompleted();
  }

  // 上拉加载数据
  Future<Null> _addMoreData() async {
    ++_page;
    await _getPostData(true);

    _controller.loadComplete();
  }

  //搜索自然相关的图片
  Future<void> _getPostData(bool _beAdd) async {
    var response = await Dio().get(
        'https://api.unsplash.com/search/photos',
        queryParameters: {
            "page": _page,
            "per_page" : _size,
            "query": "natural",
            "client_id" : "V9H-n_lRkQxy9M-PQRDZ5hpv5k_NU6JDcuCCXUrk00I"
        }
    );

    var data = json.encode(response.data);
    Photos photos = Photos.fromJson(json.decode(data));

    setState(() {
        if (!_beAdd) {
            posts.clear();
            posts = photos.results;
        } else {
            posts.addAll(photos.results);
        }
    });
  }
}

class TileCard extends StatelessWidget {
  final String img;
  final String title;
  final String author;
  final String authorUrl;

  TileCard({this.img, this.title, this.author, this.authorUrl});

  @override
  Widget build(BuildContext context) {

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            color: Colors.deepOrange,
            child: CachedNetworkImage(
                imageUrl: '$img',
                placeholder: (context, url) => Image.asset("assets/placeholder.png"),
            ),
            //Image(image: NetworkImage(img))
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            margin: EdgeInsets.symmetric(vertical: 10.w),
            child: Text(
              '${title ?? ""}',
              style: TextStyle(fontSize: 30.sp, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 20.w, bottom: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                CircleAvatar(
                  backgroundImage: NetworkImage('$authorUrl'),
                  radius: 30.w,
                ),
                Container(
                  margin: EdgeInsets.only(left: 20.w),
                  child: Text(
                    '$author',
                    style: TextStyle(
                      fontSize: 25.sp,
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
