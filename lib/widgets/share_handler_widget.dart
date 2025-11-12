import 'package:flutter/material.dart';
import 'package:share_handler/share_handler.dart';

class ShareHandlerWidget extends StatefulWidget {
  const ShareHandlerWidget({
    super.key,
    required this.child,
    required this.onMediaReceived,
  });
  final Widget child;
  final ValueChanged<SharedMedia> onMediaReceived;
  @override
  State<ShareHandlerWidget> createState() => _ShareHandlerWidgetState();
}

class _ShareHandlerWidgetState extends State<ShareHandlerWidget> {
  @override
  void initState() {
    super.initState();
    ShareHandlerPlatform.instance.sharedMediaStream.listen((SharedMedia media) {
      widget.onMediaReceived(media);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
