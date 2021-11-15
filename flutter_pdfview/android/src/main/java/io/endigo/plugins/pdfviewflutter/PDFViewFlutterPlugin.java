package io.endigo.plugins.pdfviewflutter;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
//import io.flutter.plugin.common.PluginRegistry.Registrar;

public class PDFViewFlutterPlugin implements FlutterPlugin {

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    binding
      .getPlatformViewRegistry()
      .registerViewFactory("plugins.endigo.io/pdfview", new PDFViewFactory(binding.getBinaryMessenger()));
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
  }

//  public static void registerWith(Registrar registrar) {
//    registrar
//      .platformViewRegistry()
//      .registerViewFactory(
//        "plugins.endigo.io/pdfview", new PDFViewFactory(registrar.messenger()));
//  }

}
