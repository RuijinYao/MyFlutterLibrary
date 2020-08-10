import 'dart:ui' as image;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui' deferred as ui;

class CustomChartPaint extends CustomPainter {
  Paint _bgPaint;
  Paint _barPaint;
  Paint _checkedBarPaint;

  Color backgroundColor = Color(0xFFF6F6F6); //条形图背景颜色
  Color barColor = Color(0xFF5858D6); //条形图颜色
  Color checkBarColor = Color(0xFF9858D6); //条形图颜色
  static const Color startTextColor = Colors.white; //字体颜色
  static const Color endTextColor = Color(0xFF5858D6); //字体颜色

  double barHeight = 62.0; //条形图高度
  double barMargin = 20.0; //两条形图间距
  double barPadding = 10.0; //文字到矩形的内边距

  static const double fontSize = 12.0; //文字的字体大小

  final int data;
  final String itemName;
  final String myChosen;
  final int length;
  final double targetPercent;
  final image.Image checkedImage;
  final Rect checkedImageRect;

  CustomChartPaint({this.data, this.itemName, this.myChosen, this.length, this.targetPercent, this.checkedImage, this.checkedImageRect}) {
    init();
  }

  init() {
    _bgPaint = new Paint()
      ..isAntiAlias = true //是否启动抗锯齿
      ..color = backgroundColor; //画笔颜色

    _checkedBarPaint = new Paint()
        ..color = checkBarColor
        ..isAntiAlias = true
        ..style = PaintingStyle.fill; //绘画风格，默认为填充;

    _barPaint = new Paint()
      ..color = barColor
      ..isAntiAlias = true
      ..style = PaintingStyle.fill; //绘画风格，默认为填充;
  }

  RRect bgRect;
  RRect fgRect;

  @override
  void paint(Canvas canvas, Size size) {
    print("size: " + size.toString()); //画布大小

    bgRect = RRect.fromLTRBR(0, 0, size.width, barHeight, Radius.circular(8.0));
    canvas.drawRRect(bgRect, _bgPaint); //绘制背景柱形

    double right = 0;
    //柱形图永远不会遮挡票数
    if(size.width * targetPercent > size.width - barPadding * 2){
        right = size.width - barPadding * 2 - 10;
    } else {
        right = size.width * targetPercent;
    }
    fgRect = RRect.fromLTRBR(0, 0, right, barHeight, Radius.circular(8.0));
    canvas.drawRRect(fgRect, itemName == myChosen ? _checkedBarPaint : _barPaint); //绘制前景柱形

    //绘制文字
    Offset textOffset = new ui.Offset(barPadding, barHeight / 2);
    double textWidth = _drawParagraph(canvas, textOffset, itemName.toString(), startTextColor); //在bar上绘制选项值

    //选中状态
    if (itemName == myChosen) {
      Offset checkedImageOffset = new ui.Offset(barPadding + textWidth, barHeight / 2);
      canvas.drawImageRect(checkedImage, checkedImageRect,
          Rect.fromLTRB(checkedImageOffset.dx, checkedImageOffset.dy, checkedImageOffset.dx + 10, checkedImageOffset.dy + 10), Paint());
    }

    //绘制数量值
    if (myChosen != null) {
      Offset bottomTextOffset = new Offset(size.width - barPadding * 2, barHeight / 2);
      _drawParagraph(canvas, bottomTextOffset, data.toString(), endTextColor);
    }
  }

  _drawParagraph(Canvas canvas, Offset offset, String text, Color textColor) {
    ParagraphBuilder paragraphBuilder = new ui.ParagraphBuilder(
      new ui.ParagraphStyle(
        textAlign: TextAlign.justify,
        fontSize: fontSize,
      ),
    )..pushStyle(ui.TextStyle(color: textColor));
    paragraphBuilder.addText(text);

    ParagraphConstraints pc = ui.ParagraphConstraints(width: barHeight * 4); //字体可用宽度
    //这里需要先layout, 后面才能获取到文字高度
    Paragraph textParagraph = paragraphBuilder.build()..layout(pc);

    double textHeight = textParagraph.height;
    double textWidth = textParagraph.minIntrinsicWidth;

    canvas.drawParagraph(textParagraph, offset - Offset(0, textHeight / 2)); //描绘offset所表示的位置上描绘文字text

    return textWidth;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
