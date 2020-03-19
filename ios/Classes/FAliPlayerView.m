//
// Created by Neal on 2020/3/18.
//

#import "FAliPlayerView.h"
#import "FAliPlayerView.h"
#import "AliyunPlayer/AliListPlayer.h"


@implementation FAliPlayerView {
    UIView *playerView;
    FlutterMethodChannel *channel;
    FlutterEventSink eventSink;
    AliListPlayer *aliListPlayer;
}
- (FAliPlayerView *)initWithWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id _Nullable)args player:(id _Nullable)player binaryMessenger:(NSObject <FlutterBinaryMessenger> *_Nullable)messenger {
    if ([super init]) {
        ///初始化渠道
        [self initChannel:viewId messenger:messenger];
        ///初始化view
        aliListPlayer = [[AliListPlayer alloc] init];
        aliListPlayer.delegate = self;

        playerView = [UIView new];
        aliListPlayer.playerView = playerView;
        aliListPlayer.playerView.frame = frame;
        aliListPlayer.autoPlay = YES;
    }

    return self;
}

- (void)initChannel:(int64_t)viewId messenger:(NSObject <FlutterBinaryMessenger> *)messenger {
    NSString *methodChannelName = [NSString stringWithFormat:@"plugin.iqingbai.com/ali_video_play_%lld", viewId];
    NSString *eventChannelName = [NSString stringWithFormat:@"plugin.iqingbai.com/eventChannel/ali_video_play_%lld", viewId];
    [[FlutterEventChannel
            eventChannelWithName:eventChannelName
                 binaryMessenger:messenger] setStreamHandler:self];
    channel = [FlutterMethodChannel methodChannelWithName:methodChannelName binaryMessenger:messenger];
    __weak __typeof__(self) weakSelf = self;
    [channel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
        [weakSelf onMethodCall:call result:result];
    }];
}

- (UIView *)view {
    return aliListPlayer.playerView;
}

- (void)onMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSLog(@"call method:%@", call.method);
    if ([call.method isEqualToString:@"moveTo"]) {
        NSString *url = call.arguments[@"url"];
        result(@([aliListPlayer moveTo:url]));
    } else if ([call.method isEqualToString:@"moveToPre"]) {
        result(@([aliListPlayer moveToPre]));
    } else if ([call.method isEqualToString:@"moveToNext"]) {
        result(@([aliListPlayer moveToNext]));
    } else if ([call.method isEqualToString:@"start"]) {
        [aliListPlayer start];
    } else if ([call.method isEqualToString:@"pause"]) {
        [aliListPlayer pause];
    } else if ([call.method isEqualToString:@"addUrlSource"]) {
        NSArray *list = call.arguments[@"urls"];
        for (int i = 0; i < list.count; ++i) {
            [aliListPlayer addUrlSource:list[(NSUInteger) i] uid:list[(NSUInteger) i]];
        }
    }

}

- (FlutterError *_Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(FlutterEventSink)events {
    eventSink = events;
    return nil;
}

- (FlutterError *_Nullable)onCancelWithArguments:(id _Nullable)arguments {
    eventSink = nil;
    return nil;
}

- (void)onPlayerStatusChanged:(AliPlayer *)player oldStatus:(AVPStatus)oldStatus newStatus:(AVPStatus)newStatus {
    NSLog(@"onPlayerStatusChanged:%@", @(newStatus));
    eventSink(@{
            @"eventType": @"onPlayerStatusChanged",
            @"values": @(newStatus)
    });
}

- (void)onPlayerEvent:(AliPlayer *)player eventType:(AVPEventType)eventType {
    NSLog(@"onPlayerEvent:%@", @(eventType));
    eventSink(@{
            @"eventType": @"onPlayerEvent",
            @"values": @(eventType)
    });
}

- (void)onBufferedPositionUpdate:(AliPlayer *)player position:(int64_t)position {
//    NSLog(@"onBufferedPositionUpdate:%@", @(position));
}

- (void)onError:(AliPlayer *)player errorModel:(AVPErrorModel *)errorModel {
    NSLog(@"onError:%@", errorModel.message);
}

@end