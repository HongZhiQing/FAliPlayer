//
// Created by Neal on 2020/3/18.
//

#import <Foundation/Foundation.h>
#import "Flutter/Flutter.h"
#import "AliyunPlayer/AVPDelegate.h"

@interface FAliPlayerView : NSObject<FlutterPlatformView,FlutterStreamHandler,AVPDelegate>
- (instancetype _Nullable)initWithWithFrame:(CGRect)frame
                             viewIdentifier:(int64_t)viewId
                                  arguments:(id _Nullable)args
                                     player:(id _Nullable)player
                            binaryMessenger:(NSObject <FlutterBinaryMessenger> *_Nullable)messenger;
@end