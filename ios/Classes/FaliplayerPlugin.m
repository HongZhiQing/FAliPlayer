#import "FaliplayerPlugin.h"
#import "FAliPlayListFactory.h"

@implementation FaliplayerPlugin
+ (void)registerWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel
            methodChannelWithName:@"faliplayer"
                  binaryMessenger:[registrar messenger]];
    FaliplayerPlugin *instance = [[FaliplayerPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    FAliPlayListFactory *aliPlayerFactory = [[FAliPlayListFactory alloc] initWithMessenger:registrar.messenger];
    [registrar registerViewFactory:aliPlayerFactory withId:@"plugin.iqingbai.com/ali_video_play"];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

@end
