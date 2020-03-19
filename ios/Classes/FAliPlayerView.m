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
        aliListPlayer.scalingMode = AVP_SCALINGMODE_SCALEASPECTFILL;///画面铺面.dart层控制宽高

        ///循环播放
        aliListPlayer.loop = @([args[@"loop"] intValue]).boolValue;

        AVPCacheConfig *cacheConfig = [[AVPCacheConfig alloc] init];
        //开启缓存功能
        cacheConfig.enable = YES;
        //能够缓存的单个文件最大时长。超过此长度则不缓存
        cacheConfig.maxDuration = 100;
        //缓存目录的位置，需替换成app期望的路径
        cacheConfig.path = [self getCachesPath];
        //缓存目录的最大大小。超过此大小，将会删除最旧的缓存文件
        cacheConfig.maxSizeMB = 1024;
        //设置缓存配置给到播放器
        NSLog(@"设置:%d", [aliListPlayer setCacheConfig:cacheConfig]);


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
    } else if ([call.method isEqualToString:@"seekTo"]) {
        int64_t time = (int64_t) call.arguments[@"time"];
        [aliListPlayer seekToTime:time seekMode:AVP_SEEKMODE_INACCURATE];
    } else if ([call.method isEqualToString:@"getCachesPath"]) {
        NSString *url = call.arguments[@"url"];
        result([aliListPlayer getCacheFilePath:url]);
    } else if ([call.method isEqualToString:@"setScalingMode"]) {
        int mode = [call.arguments[@"mode"] intValue];
        aliListPlayer.scalingMode = (AVPScalingMode) mode;///画面铺面.dart层控制宽高
    } else if ([call.method isEqualToString:@"addUrlSource"]) {
        NSArray *list = call.arguments[@"urls"];
        for (int i = 0; i < list.count; ++i) {
            [aliListPlayer addUrlSource:list[(NSUInteger) i] uid:list[(NSUInteger) i]];
        }
    }

}

//获取缓存文件路径
- (NSString *)getCachesPath {
    // 获取Caches目录路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDir = paths[0];

    //指定文件名
    NSString *filePath = [cachesDir stringByAppendingPathComponent:@"com.st.video"];
    long size = [self fileSizeAtPath:filePath];
    NSLog(@"缓存目录:%@", cachesDir);
    NSLog(@"缓存目录2:%@", filePath);
    NSLog(@"缓存目录大小:%ld", size);
    return filePath;
}

- (long long)fileSizeAtPath:(NSString *)filePath {
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]) {

//        //取得一个目录下得所有文件名
        NSArray *files = [manager subpathsAtPath:filePath];
        NSLog(@"files1111111%@ == %ld", files, files.count);
//
//        // 从路径中获得完整的文件名（带后缀）
//        NSString *exe = [filePath lastPathComponent];
//        NSLog(@"exeexe ====%@",exe);
//
//        // 获得文件名（不带后缀）
//        exe = [exe stringByDeletingPathExtension];
//
//        // 获得文件名（不带后缀）
//        NSString *exestr = [[files objectAtIndex:1] stringByDeletingPathExtension];
//        NSLog(@"files2222222%@  ==== %@",[files objectAtIndex:1],exestr);


        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }

    return 0;
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
    if (eventSink) {
        eventSink(@{
                @"eventType": @"onPlayerStatusChanged",
                @"values": @(newStatus)
        });
    }
}
- (void)onTrackReady:(AliPlayer *)player info:(NSArray<AVPTrackInfo *> *)info {
//    NSLog(@"onTrackReady :%d === %d", info[0].videoWidth,info[0].videoHeight);
//    if(info[0].videoWidth<info[0].videoHeight){
//        aliListPlayer.scalingMode = AVP_SCALINGMODE_SCALEASPECTFILL;
//    }else{
//        aliListPlayer.scalingMode = AVP_SCALINGMODE_SCALEASPECTFIT;
//    }
}
- (void)onVideoSizeChanged:(AliPlayer *)player width:(int)width height:(int)height rotation:(int)rotation {
    eventSink(@{
            @"eventType": @"onVideoSizeChanged",
            @"height": @(height),
            @"width": @(width),
    });
}

- (void)onPlayerEvent:(AliPlayer *)player eventType:(AVPEventType)eventType {
    NSLog(@"onPlayerEvent:%@", @(eventType));
    if (eventSink) {
        eventSink(@{
                @"eventType": @"onPlayerEvent",
                @"values": @(eventType)
        });
    }
}

- (void)onBufferedPositionUpdate:(AliPlayer *)player position:(int64_t)position {
    if (eventSink) {
        eventSink(@{
                @"eventType": @"onBufferedPositionUpdate",
                @"values": @(position)
        });
    }
}

- (void)onCurrentPositionUpdate:(AliPlayer *)player position:(int64_t)position {
    if (eventSink) {
        eventSink(@{
                @"eventType": @"onCurrentPositionUpdate",
                @"values": @(position)
        });
    }
}

- (void)onError:(AliPlayer *)player errorModel:(AVPErrorModel *)errorModel {
    NSLog(@"onError:%@", errorModel.message);
}

@end