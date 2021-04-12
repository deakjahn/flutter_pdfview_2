import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'flutter_pdfview_platform_interface.dart';

class MethodChannelFlutterPDFView extends FlutterPDFViewPlatform {
  final Map<int, MethodChannel> _channels = {};

  @override
  void init(Map<String, dynamic> settings, {required int viewId}) {
    if (!_channels.containsKey(viewId)) {
      final channel = MethodChannel('plugins.endigo.io/pdfview_$viewId');
      channel.setMethodCallHandler((call) => _onMethodCall(call, viewId));
      _channels[viewId] = channel;
    }
  }

  @override
  Future<int> getPageCount({required int viewId}) async {
    final result = await _channels[viewId]!.invokeMethod('pageCount');
    return result!;
  }

  @override
  Future<int> getCurrentPage({required int viewId}) async {
    final result = await _channels[viewId]!.invokeMethod('getCurrentPage');
    return result!;
  }

  @override
  Future<bool> setPage(int page, {required int viewId}) async {
    final result = await _channels[viewId]!.invokeMethod('setPage', <String, dynamic>{
      'page': page,
    });
    return result!;
  }

  @override
  Future<void> updateSettings(Map<String, dynamic> settings, {required int viewId}) async {
    final result = await _channels[viewId]!.invokeMethod('updateSettings', settings);
    return result!;
  }

  Future<dynamic> _onMethodCall(MethodCall call, int viewId) async {
    switch (call.method) {
      case 'onRender':
        events.add(PDFViewRenderEvent(viewId, call.arguments['pages']));
        break;
      case 'onPageChanged':
        events.add(PDFViewPageChangeEvent(viewId, call.arguments['page'], call.arguments['total']));
        break;
      case 'onError':
        events.add(PDFViewErrorEvent(viewId, call.arguments['error']));
        break;
      case 'onPageError':
        events.add(PDFViewPageErrorEvent(viewId, call.arguments['page'], call.arguments['error']));
        break;
      default:
        throw MissingPluginException(call.method);
    }
  }

  @override
  Widget buildView(Map<String, dynamic> creationParams, Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers, PlatformViewCreatedCallback onPlatformViewCreated) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'plugins.endigo.io/pdfview',
        onPlatformViewCreated: onPlatformViewCreated,
        gestureRecognizers: gestureRecognizers,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'plugins.endigo.io/pdfview',
        onPlatformViewCreated: onPlatformViewCreated,
        gestureRecognizers: gestureRecognizers,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
    return Text('$defaultTargetPlatform is not supported');
  }
}
