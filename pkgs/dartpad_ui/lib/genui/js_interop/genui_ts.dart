import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// The URL of the deployed flutter app to use for rendering.
///
/// This is used as the src of the iframe that GenuiTs injects.
const defaultGenuiRuntimeUrl = 'https://fluttergenui.web.app/';

/// The JS-interop layer for the `window.genui` global.
extension type GenuiTs._(JSObject _) implements JSObject {
  @JS('render')
  external void _render(
    JSString runtimeUrl,
    JSObject element,
    JSObject payload,
  );

  @JS('createPayload')
  external JSObject _createPayload(JSString js);
}

/// Exposes a Dart-specific API to use the GenuiTs object.
extension GenuiDartRenderExtension on GenuiTs {
  /// Renders the given [payload] into the [target] element.
  ///
  /// The [runtimeUrl] is the URL of the runtime files to use.
  ///
  /// To use a custom flutter runtime app, specify its [runtimeUrl]. This is
  /// optional, and defaults to [defaultGenuiRuntimeUrl].
  void render(
    String payload, {
    required web.HTMLElement target,
    String runtimeUrl = defaultGenuiRuntimeUrl,
  }) {
    _render(runtimeUrl.toJS, target, _createPayload(payload.toJS));
  }
}

/// Binding to the `window.genui` JS global.
@JS('genui')
external GenuiTs get genui;
