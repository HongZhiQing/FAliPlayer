import 'dart:io';

import 'package:faliplayer/faliplayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FAliPlayerView extends StatefulWidget {
  final FAliPlayerController controller;
  final String url;
  final bool isCurrentLocation;

  const FAliPlayerView(
      {Key key, this.controller, this.isCurrentLocation, this.url})
      : super(key: key);

  @override
  _FAliPlayerViewState createState() => _FAliPlayerViewState();
}

class _FAliPlayerViewState extends State<FAliPlayerView> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.controller.setFirstRenderedStartListener(() {
      print('firstRenderedStart:${widget.controller.firstRenderedStart}');
      if (widget.controller.firstRenderedStart) {
        setState(() {});
        widget.controller.firstRenderedStart = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, contraints) {
        Widget body = Container(
          color: Colors.black,
        );
        body = Platform.isAndroid
            ? AndroidView(
          viewType: "plugin.iqingbai.com/ali_video_play_single_",
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: widget.controller.onViewCreate,
          creationParams: <String, dynamic>{
            "cacheConfig": widget.controller.cacheConfig?.toJson(),
            "url": widget.url ?? " ",
            "loop": widget.controller.loop,
            "auto":widget.controller.isAutoPlay
          },
        )
            : UiKitView(
          viewType: "plugin.iqingbai.com/ali_video_play_single_",
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: widget.controller.onViewCreate,
        );
        return Container(
          color: Colors.black,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                color: Colors.black,
                child: Image.network(
                    "${widget.url}?vframe/jpg/offset/1"),
              ),
              Offstage(offstage: !widget.isCurrentLocation, child: body),
            ],
          ),
        );
      },
    );
  }
}
