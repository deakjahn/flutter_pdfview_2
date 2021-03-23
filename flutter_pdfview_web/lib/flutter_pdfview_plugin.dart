import 'dart:async';
import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview_platform_interface/flutter_pdfview_platform_interface.dart';
import 'package:flutter_pdfview_web/flutter_pdfview_web.dart';
import 'package:flutter_pdfview_web/html_element_view.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

class PDFViewFlutterPlugin extends FlutterPDFViewPlatform {
  static final _viewers = <int, FlutterPDFView>{};
  static final _readyCompleter = Completer<bool>();
  static late Future<bool> _isReady;

  static void registerWith(Registrar registrar) {
    final self = PDFViewFlutterPlugin();
    _isReady = _readyCompleter.future;
    html.window.addEventListener('flutter_pdfview_web_ready', (_) {
      if (!_readyCompleter.isCompleted) _readyCompleter.complete(true);
    });
    FlutterPDFViewPlatform.instance = self;

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory('plugins.endigo.io/pdfview', (viewId) {
      final view = _viewers[viewId] = FlutterPDFView(viewId);
      return view.canvas;
    });

    // Add JS dynamically if not already imported (this is needed to prevent hot reload or refresh to import it again and again)
    var foundRequireJs = false;
    var foundPdfViewJs = false;
    for (html.ScriptElement script in html.document.body!.querySelectorAll('script')) {
      if (script.src.contains('assets/packages/flutter_pdfview_web/assets/require.js')) foundRequireJs = true;
      if (script.src.contains('assets/packages/flutter_pdfview_web/assets/flutter_pdfview.js')) foundPdfViewJs = true;
    }

    if (!foundRequireJs) {
      print("WARNING: Importing 'require.js' from assets, consider importing it directly from your index.html");
      html.document.body!.append(html.ScriptElement()
        ..src = 'assets/packages/flutter_pdfview_web/assets/require.js' // ignore: unsafe_html
        ..type = 'application/javascript');
    }
    if (!foundPdfViewJs) {
      html.document.body!.append(html.ScriptElement()
        ..src = 'assets/packages/flutter_pdfview_web/assets/flutter_pdfview.js' // ignore: unsafe_html
        ..type = 'application/javascript');
    }
  }

  @override
  void init(Map<String, dynamic> params, {required int viewId}) {
    _viewers[viewId]!.init(params);
  }

  @override
  Future<int> getPageCount({required int viewId}) async {
    return _viewers[viewId]!.getPageCount();
  }

  @override
  Future<int> getCurrentPage({required int viewId}) async {
    return _viewers[viewId]!.getCurrentPage();
  }

  @override
  Future<bool> setPage(int page, {required int viewId}) async {
    return _viewers[viewId]!.setPage(page);
  }

  @override
  Future<void> updateSettings(Map<String, dynamic> settings, {required int viewId}) async {
    return _viewers[viewId]!.updateSettings(settings);
  }

  @override
  Widget buildView(Map<String, dynamic> creationParams, Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers, PlatformViewCreatedCallback onPlatformViewCreated) => FutureBuilder<bool>(
        future: _isReady,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            //TODO change to HtmlElementView when https://github.com/flutter/flutter/issues/56181 fixed
            return HtmlElementViewEx(
              viewType: 'plugins.endigo.io/pdfview',
              onPlatformViewCreated: onPlatformViewCreated,
              creationParams: creationParams,
            );
          } else if (snapshot.hasError)
            return Center(child: Text('Error loading library'));
          else
            return Center(child: CircularProgressIndicator());
        },
      );
}
