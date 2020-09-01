import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

///多行文字展开收起
//源代码 https://github.com/wode0weiyi/flutter-components/tree/master/flutter_learn/lib/widgets/expandableText
class ExpandableText extends StatefulWidget {
    const ExpandableText(
        this.text, {
            Key key,
            @required this.expandText,
            @required this.collapseText,
            this.expanded = false,
            this.linkColor,
            this.style,
            this.textDirection,
            this.textAlign,
            this.textScaleFactor,
            this.maxLines = 2,
            this.semanticsLabel,
        })  : assert(text != null),
            assert(expandText != null),
            assert(collapseText != null),
            assert(expanded != null),
            assert(maxLines != null && maxLines > 0),
            super(key: key);

    final String text;
    final String expandText;
    final String collapseText;
    final bool expanded;
    final Color linkColor;
    final TextStyle style;
    final TextDirection textDirection;
    final TextAlign textAlign;
    final double textScaleFactor;
    final int maxLines;
    final String semanticsLabel;

    @override
    ExpandableTextState createState() => ExpandableTextState();
}

class ExpandableTextState extends State<ExpandableText> {
    bool _expanded = false;
    TapGestureRecognizer _tapGestureRecognizer;

    @override
    void initState() {
        super.initState();

        _expanded = widget.expanded;
        _tapGestureRecognizer = TapGestureRecognizer()..onTap = _toggleExpanded;
    }

    @override
    void dispose() {
        _tapGestureRecognizer.dispose();
        super.dispose();
    }

    void _toggleExpanded() {
        setState(() => _expanded = !_expanded);
    }

    @override
    Widget build(BuildContext context) {
        final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
        TextStyle effectiveTextStyle = widget.style;
        if (widget.style == null || widget.style.inherit) {
            effectiveTextStyle = defaultTextStyle.style.merge(widget.style);
        }

        final textAlign =
            widget.textAlign ?? defaultTextStyle.textAlign ?? TextAlign.start;

        final textDirection = widget.textDirection ?? Directionality.of(context);

        final textScaleFactor =
            widget.textScaleFactor ?? MediaQuery.textScaleFactorOf(context);

        final locale = Localizations.localeOf(context, nullOk: true);

        final linkText = _expanded ? ' ${widget.collapseText}' : '${widget.expandText}';

        final linkColor = widget.linkColor ?? Theme.of(context).accentColor;

        final link = TextSpan(
            text: _expanded ? '' : '\u2026 ',   //是否显示省略号  \u2026 = [TextOverflow.ellipsis]
            style: effectiveTextStyle,
            children: <TextSpan>[
                TextSpan(
                    text: linkText,
                    style: effectiveTextStyle.copyWith(
                        color: linkColor,
                    ),
                    //手势识别器，将接收点击此Span的事件。
                    recognizer: _tapGestureRecognizer,
                )
            ],
        );

        final text = TextSpan(
            text: widget.text,
            style: effectiveTextStyle,
        );

        Widget result = LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
                assert(constraints.hasBoundedWidth);
                final double maxWidth = constraints.maxWidth;

                TextPainter textPainter = TextPainter(
                    text: link,
                    textAlign: textAlign,
                    textDirection: textDirection,
                    textScaleFactor: textScaleFactor,
                    maxLines: widget.maxLines,
                    locale: locale,
                );
                textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
                final linkSize = textPainter.size;
                final linkWidth = textPainter.maxIntrinsicWidth;

                //print(' textPainter-min: ${textPainter.minIntrinsicWidth} textPainter-max: ${textPainter.maxIntrinsicWidth}');

                //print('linkSize-width: ${linkSize.width} linkSize-height: ${linkSize.height} linkWidth: $linkWidth');

                textPainter.text = text;
                textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
                final textSize = textPainter.size;

                //print("textSize-width: ${textSize.width} textSize-height: ${textSize.height}");

                final TextPosition position = textPainter.getPositionForOffset(Offset(
                    textSize.width - linkWidth,
                    textSize.height,
                ));

                final endOffset = textPainter.getOffsetBefore(position.offset);

                //print("position: $position,  endOffset: $endOffset");

                TextSpan textSpan;

                //如果文本超过了用户设置的最大行数, 就截取部分显示, 并且显示"收起,展开",  否则显示全部问题,不显示",收起,展开"
                if (textPainter.didExceedMaxLines) {
                    textSpan = TextSpan(
                        style: effectiveTextStyle,
                        text: _expanded ? widget.text : widget.text.substring(0, endOffset),
                        children: <TextSpan>[
                            link,
                        ],
                    );
                } else {
                    textSpan = text;
                }

                return RichText(
                    text: textSpan,
                    softWrap: true,
                    textDirection: textDirection,
                    textAlign: textAlign,
                    textScaleFactor: textScaleFactor,
                    overflow: TextOverflow.clip,
                );
            },
        );

        if (widget.semanticsLabel != null) {
            result = Semantics(
                textDirection: widget.textDirection,
                label: widget.semanticsLabel,
                child: ExcludeSemantics(
                    child: result,
                ),
            );
        }

        return result;
    }
}