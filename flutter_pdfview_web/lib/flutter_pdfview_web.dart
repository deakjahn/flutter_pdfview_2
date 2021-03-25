@JS('flutter_pdfview_web')
library flutter_pdfview_web;

import 'dart:html';
import 'dart:typed_data';

import 'package:flutter_pdfview_platform_interface/flutter_pdfview_platform_interface.dart';
import 'package:js/js.dart';

class FlutterPDFView {
  final int viewId;
  late CanvasElement canvas;
  String? filePath;
  Uint8List? pdfData;
  int defaultPage = 0;

  FlutterPDFView(this.viewId) {
    final id = 'pdfview-canvas-$viewId';
    canvas = CanvasElement()
      ..id = id
      ..style.border = 'none'
      ..style.backgroundColor = 'white'
      ..style.pointerEvents = 'auto'
      // idea from https://keithclark.co.uk/articles/working-with-elements-before-the-dom-is-ready/
      ..append(StyleElement()..innerText = '@keyframes $id-animation {from { clip: rect(1px, auto, auto, auto); } to { clip: rect(0px, auto, auto, auto); }}')
      ..style.animationName = '$id-animation'
      ..style.animationDuration = '0.001s'
      ..addEventListener('animationstart', (event) {
        if (filePath != null)
          _nativeCreatePath(canvas, filePath!, defaultPage + 1, allowInterop(_onRender), allowInterop(_onError));
        else if (pdfData != null)
          _nativeCreateData(canvas, pdfData!, defaultPage + 1, allowInterop(_onRender), allowInterop(_onError));
        else
          throw ArgumentError('Neither path nor data');
      });
  }

  void init(Map<String, dynamic> params) {
    filePath = params['filePath'];
    pdfData = params['pdfData'];
    defaultPage = params['defaultPage'];
  }

  Future<int> getPageCount() async {
    return _nativeGetPageCount(canvas);
  }

  Future<int> getCurrentPage() async {
    return _nativeGetCurrentPage(canvas);
  }

  Future<bool> setPage(int page) async {
    return _nativeSetPage(canvas, page, allowInterop(_onPageChange), allowInterop(_onPageError));
  }

  Future<void> updateSettings(Map<String, dynamic> settings) async {
    //TODO
    return Future.value(null);
  }

  void _onRender(int pages) => FlutterPDFViewPlatform.instance.events.add(PDFViewRenderEvent(viewId, pages));

  void _onPageChange(int page, int total) => FlutterPDFViewPlatform.instance.events.add(PDFViewPageChangeEvent(viewId, page, total));

  void _onError(String error) => FlutterPDFViewPlatform.instance.events.add(PDFViewErrorEvent(viewId, error));

  void _onPageError(int page, String error) => FlutterPDFViewPlatform.instance.events.add(PDFViewPageErrorEvent(viewId, page, error));
}

@JS('createPath')
external bool _nativeCreatePath(dynamic canvas, String filePath, int defaultPage, Function onRender, Function onError);

@JS('createData')
external bool _nativeCreateData(dynamic canvas, Uint8List pdfData, int defaultPage, Function onRender, Function onError);

@JS('getPageCount')
external int _nativeGetPageCount(dynamic canvas);

@JS('getCurrentPage')
external int _nativeGetCurrentPage(dynamic canvas);

@JS('setPage')
external bool _nativeSetPage(dynamic canvas, int page, Function onChange, Function onError);
