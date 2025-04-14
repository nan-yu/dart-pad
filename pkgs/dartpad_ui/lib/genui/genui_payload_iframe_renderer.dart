import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import 'js_interop/genui_ts.dart';

/// A widget that renders a genui response payload into an iframe.
class GenuiPayloadIframeRenderer extends StatefulWidget {
  final String ddcPayload;

  const GenuiPayloadIframeRenderer({super.key, required this.ddcPayload});

  @override
  State<GenuiPayloadIframeRenderer> createState() {
    return _GenuiPayloadIframeRendererState();
  }
}

class _GenuiPayloadIframeRendererState
    extends State<GenuiPayloadIframeRenderer> {
  @override
  Widget build(BuildContext context) {
    return HtmlElementView.fromTagName(
      tagName: 'div',
      onElementCreated: (element) {
        genui.render(widget.ddcPayload, target: element as web.HTMLDivElement);
      },
    );
  }
}
