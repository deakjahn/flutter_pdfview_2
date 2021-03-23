import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'method_channel_flutter_pdfview.dart';

abstract class FlutterPDFViewPlatform extends PlatformInterface {
  static final _token = Object();
  final events = StreamController<PDFViewEvent>.broadcast();
  static FlutterPDFViewPlatform _instance = MethodChannelFlutterPDFView();

  FlutterPDFViewPlatform() : super(token: _token);

  /// The default instance of [FlutterPDFViewPlatform] to use.
  static FlutterPDFViewPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [FlutterPDFViewPlatform] when they register themselves.
  static set instance(FlutterPDFViewPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  void init(Map<String, dynamic> settings, {required int viewId}) {
    throw UnimplementedError('init');
  }

  Future<int> getPageCount({required int viewId}) {
    throw UnimplementedError('getPageCount');
  }

  Future<int> getCurrentPage({required int viewId}) {
    throw UnimplementedError('getCurrentPage');
  }

  Future<bool> setPage(int page, {required int viewId}) {
    throw UnimplementedError('setPage');
  }

  Future<void> updateSettings(Map<String, dynamic> settings, {required int viewId}) {
    throw UnimplementedError('updateSettings');
  }

  Stream<PDFViewRenderEvent> onRender({required int viewId}) {
    return events.stream //
        .where((event) => event.viewId == viewId && event is PDFViewRenderEvent)
        .cast<PDFViewRenderEvent>();
  }

  Stream<PDFViewPageChangeEvent> onPageChanged({required int viewId}) {
    return events.stream //
        .where((event) => event.viewId == viewId && event is PDFViewPageChangeEvent)
        .cast<PDFViewPageChangeEvent>();
  }

  Stream<PDFViewErrorEvent> onError({required int viewId}) {
    return events.stream //
        .where((event) => event.viewId == viewId && event is PDFViewErrorEvent)
        .cast<PDFViewErrorEvent>();
  }

  Stream<PDFViewPageErrorEvent> onPageError({required int viewId}) {
    return events.stream //
        .where((event) => event.viewId == viewId && event is PDFViewPageErrorEvent)
        .cast<PDFViewPageErrorEvent>();
  }

  Widget buildView(Map<String, dynamic> creationParams, Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers, PlatformViewCreatedCallback onPlatformViewCreated) {
    throw UnimplementedError('buildView');
  }

  void dispose() {
    events.close();
  }
}

class PDFViewEvent {
  final int viewId;

  PDFViewEvent(this.viewId);
}

class PDFViewRenderEvent extends PDFViewEvent {
  final int pages;

  PDFViewRenderEvent(int viewId, this.pages) : super(viewId);
}

class PDFViewPageChangeEvent extends PDFViewEvent {
  final int page;
  final int total;

  PDFViewPageChangeEvent(int viewId, this.page, this.total) : super(viewId);
}

class PDFViewErrorEvent extends PDFViewEvent {
  final dynamic error;

  PDFViewErrorEvent(int viewId, this.error) : super(viewId);
}

class PDFViewPageErrorEvent extends PDFViewEvent {
  final int page;
  final dynamic error;

  PDFViewPageErrorEvent(int viewId, this.page, this.error) : super(viewId);
}
