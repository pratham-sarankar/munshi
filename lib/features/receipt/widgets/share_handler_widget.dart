import 'dart:async';

import 'package:flutter/material.dart';
import 'package:share_handler/share_handler.dart';

class ShareHandlerWidget extends StatefulWidget {
  const ShareHandlerWidget({
    required this.child,
    required this.onMediaReceived,
    super.key,
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
    unawaited(initialize());
  }

  Future<void> initialize() async {
    final shareHandler = ShareHandlerPlatform.instance;
    final initialMedia = await shareHandler.getInitialSharedMedia();
    if (initialMedia != null) {
      widget.onMediaReceived(initialMedia);
    }
    shareHandler.sharedMediaStream.listen(widget.onMediaReceived);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
