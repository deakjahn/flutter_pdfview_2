//
//  Generated file. Do not edit.
//

#import "GeneratedPluginRegistrant.h"

#if __has_include(<flutter_pdfview/FLTPDFViewFlutterPlugin.h>)
#import <flutter_pdfview/FLTPDFViewFlutterPlugin.h>
#else
@import flutter_pdfview;
#endif

#if __has_include(<path_provider/FLTPathProviderPlugin.h>)
#import <path_provider/FLTPathProviderPlugin.h>
#else
@import path_provider;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [FLTPDFViewFlutterPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTPDFViewFlutterPlugin"]];
  [FLTPathProviderPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTPathProviderPlugin"]];
}

@end
