import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_pdfview_platform_interface/flutter_pdfview_platform_interface.dart';

typedef PDFViewCreatedCallback = void Function(PDFViewController controller);
typedef RenderCallback = void Function(int pages);
typedef PageChangedCallback = void Function(int page, int total);
typedef ErrorCallback = void Function(dynamic error);
typedef PageErrorCallback = void Function(int page, dynamic error);

enum FitPolicy { WIDTH, HEIGHT, BOTH }

class PDFView extends StatefulWidget {
  const PDFView({
    Key? key,
    this.filePath,
    this.pdfData,
    this.onViewCreated,
    this.onRender,
    this.onPageChanged,
    this.onError,
    this.onPageError,
    this.gestureRecognizers,
    this.enableSwipe = true,
    this.swipeHorizontal = false,
    this.password,
    this.nightMode = false,
    this.autoSpacing = true,
    this.pageFling = true,
    this.pageSnap = true,
    this.fitEachPage = true,
    this.defaultPage = 0,
    this.fitPolicy = FitPolicy.WIDTH,
  })  : assert(filePath != null || pdfData != null),
        super(key: key);

  @override
  _PDFViewState createState() => _PDFViewState();

  /// If not null invoked once the web view is created.
  final PDFViewCreatedCallback? onViewCreated;
  final RenderCallback? onRender;
  final PageChangedCallback? onPageChanged;
  final ErrorCallback? onError;
  final PageErrorCallback? onPageError;

  /// Which gestures should be consumed by the pdf view.
  ///
  /// It is possible for other gesture recognizers to be competing with the pdf view on pointer
  /// events, e.g if the pdf view is inside a [ListView] the [ListView] will want to handle
  /// vertical drags. The pdf view will claim gestures that are recognized by any of the
  /// recognizers on this list.
  ///
  /// When this set is empty or null, the pdf view will only handle pointer events for gestures that
  /// were not claimed by any other gesture recognizer.
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  /// The initial URL to load.
  final String? filePath;
  final Uint8List? pdfData;

  final bool enableSwipe;
  final bool swipeHorizontal;
  final String? password;
  final bool nightMode;
  final bool autoSpacing;
  final bool pageFling;
  final bool pageSnap;
  final int defaultPage;
  final FitPolicy fitPolicy;
  final bool fitEachPage;
}

class _PDFViewState extends State<PDFView> {
  final Completer<PDFViewController> _controller = Completer<PDFViewController>();

  @override
  Widget build(BuildContext context) {
    final params = <String, dynamic>{
      'filePath': widget.filePath,
      'pdfData': widget.pdfData,
      'enableSwipe': widget.enableSwipe,
      'swipeHorizontal': widget.swipeHorizontal,
      'password': widget.password,
      'nightMode': widget.nightMode,
      'autoSpacing': widget.autoSpacing,
      'pageFling': widget.pageFling,
      'pageSnap': widget.pageSnap,
      'defaultPage': widget.defaultPage,
      'fitPolicy': widget.fitPolicy.toString(),
      'fitEachPage': widget.fitEachPage,
    };
    return FlutterPDFViewPlatform.instance.buildView(params, widget.gestureRecognizers, (viewId) {
      final ctrl = PDFViewController._create(viewId, widget);
      _controller.complete(ctrl);
      widget.onViewCreated?.call(ctrl);
      FlutterPDFViewPlatform.instance.init(params, viewId: viewId);
    });
  }
}

class PDFViewController {
  final int viewId;
  final PDFView widget;

  PDFViewController._create(this.viewId, this.widget) {
    if (widget.onRender != null) {
      FlutterPDFViewPlatform.instance //
          .onRender(viewId: viewId)
          .listen((msg) => widget.onRender!(msg.pages));
    }
    if (widget.onPageChanged != null) {
      FlutterPDFViewPlatform.instance //
          .onPageChanged(viewId: viewId)
          .listen((msg) => widget.onPageChanged!(msg.page, msg.total));
    }
    if (widget.onError != null) {
      FlutterPDFViewPlatform.instance //
          .onError(viewId: viewId)
          .listen((msg) => widget.onError!(msg.error));
    }
    if (widget.onPageError != null) {
      FlutterPDFViewPlatform.instance //
          .onPageError(viewId: viewId)
          .listen((msg) => widget.onPageError!(msg.page, msg.error));
    }
  }

  Future<int> getPageCount() {
    return FlutterPDFViewPlatform.instance.getPageCount(viewId: viewId);
  }

  Future<int> getCurrentPage() async {
    return FlutterPDFViewPlatform.instance.getCurrentPage(viewId: viewId);
  }

  Future<bool> setPage(int page) {
    return FlutterPDFViewPlatform.instance.setPage(page, viewId: viewId);
  }

  Future<void> updateSettings({bool? enableSwipe, bool? swipeHorizontal, String? password, bool? nightMode, bool? autoSpacing, bool? pageFling, bool? pageSnap, int? defaultPage, FitPolicy? fitPolicy, bool? fitEachPage}) {
    final settings = <String, dynamic>{
      'enableSwipe': enableSwipe,
      'swipeHorizontal': swipeHorizontal,
      'password': password,
      'nightMode': nightMode,
      'autoSpacing': autoSpacing,
      'pageFling': pageFling,
      'pageSnap': pageSnap,
      'defaultPage': defaultPage,
      'fitPolicy': fitPolicy.toString(),
      'fitEachPage': fitEachPage,
    };
    return FlutterPDFViewPlatform.instance.updateSettings(settings, viewId: viewId);
  }
}
