//
// Created by Neal on 2020/3/18.
//

#import "FAliPlayListFactory.h"
#import "FAliPlayerView.h"

@interface FAliPlayListFactory ()
@property(nonatomic) NSObject <FlutterBinaryMessenger> *messenger;

@end

@implementation FAliPlayListFactory {
    FAliPlayerView *fAliPlayerView;
}
- (instancetype)initWithMessenger:(NSObject <FlutterBinaryMessenger> *)messenger {
    self = [super init];
    if (self) {
        NSLog(@"Factory 注册");
        self.messenger = messenger;

    }
    return self;
}

- (NSObject <FlutterMessageCodec> *)createArgsCodec {
    return [FlutterStandardMessageCodec sharedInstance];
}

- (NSObject <FlutterPlatformView> *)createWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args {
    if(!fAliPlayerView){
        fAliPlayerView = [[FAliPlayerView alloc] initWithWithFrame:frame viewIdentifier:viewId arguments:args player:nil binaryMessenger:_messenger];
    }
    return fAliPlayerView;
}

@end