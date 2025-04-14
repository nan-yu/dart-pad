import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import 'js_interop/genui_ts.dart';

/// A widget that renders and embeds a genui payload into an iframe.
class GenuiPayloadIframeEmbedder extends StatefulWidget {
  final String ddcPayload;

  const GenuiPayloadIframeEmbedder({super.key, required this.ddcPayload});

  @override
  State<GenuiPayloadIframeEmbedder> createState() {
    return _GenuiPayloadIframeEmbedderState();
  }
}

class _GenuiPayloadIframeEmbedderState
    extends State<GenuiPayloadIframeEmbedder> {
  web.HTMLDivElement? _containerElement;

  @override
  Widget build(BuildContext context) {
    return HtmlElementView.fromTagName(
      tagName: 'div',
      onElementCreated: (element) {
        _containerElement = element as web.HTMLDivElement;
        if (widget.ddcPayload.isNotEmpty) {
          genui.render(widget.ddcPayload, target: _containerElement!);
        }
      },
    );
  }

  @override
  void didUpdateWidget(covariant GenuiPayloadIframeEmbedder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ddcPayload != oldWidget.ddcPayload) {
      if (_containerElement != null) {
        _containerElement!.innerText = '';
        if (widget.ddcPayload.isNotEmpty) {
          genui.render(widget.ddcPayload, target: _containerElement!);
        }
      }
    }
  }

  @override
  void dispose() {
    if (_containerElement != null) {
      _containerElement!.innerText = '';
    }
    _containerElement = null;
    super.dispose();
  }
}
