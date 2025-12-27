//
//  MRDLNA.m
//  MRDLNA
//
//  Created by MccRee on 2018/5/4.
//

#import "MRDLNA.h"
#import "StopAction.h"

@interface MRDLNA()<CLUPnPServerDelegate, CLUPnPResponseDelegate>

@property(nonatomic,strong) CLUPnPServer *upd;              //MDS服务器
@property(nonatomic,strong) NSMutableArray *dataArray;

@property(nonatomic,strong) CLUPnPRenderer *render;         //MDR渲染器
@property(nonatomic,copy) NSString *volume;
@property(nonatomic,assign) NSInteger seekTime;
@property(nonatomic,assign) BOOL isPlaying;
@property(nonatomic,assign) BOOL connectDeviceStaus;
@property(nonatomic,assign) double currenPlayTime;
@property(nonatomic,strong) NSString* currentTransportState;



@end

@implementation MRDLNA

+ (MRDLNA *)sharedMRDLNAManager{
    static MRDLNA *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.upd = [CLUPnPServer shareServer];
        self.upd.searchTime = 3;
        self.upd.delegate = self;
        self.currenPlayTime = 0.0;
        self.dataArray = [NSMutableArray array];
    }
    return self;
}

/**
 ** DLNA投屏
 */
- (void)startDLNA{
    [self initCLUPnPRendererAndDlnaPlay];
}

/**
 连接设备
 */
-(void)connectDevice:(CLUPnPDevice*)device {
    
    self.device = device;
    
    StopAction *action = [[StopAction alloc]initWithDevice:self.device Success:^{
       
        if ([self.delegate respondsToSelector:@selector(connectDevice:Status:)]) {
            
            [self.delegate connectDevice:device Status:YES];
        }
        
        self.render = [[CLUPnPRenderer alloc] initWithModel:self.device];
        self.render.delegate = self;
        
        self.connectDeviceStaus = YES;
        
    } failure:^{
      
        if ([self.delegate respondsToSelector:@selector(connectDevice:Status:)]) {
            
            [self.delegate connectDevice:device Status:NO];
        }
        self.connectDeviceStaus = NO;
    }];
    [action executeAction];
}

/**
 获取连接状态
 */
-(BOOL)getConnectDeviceStaus {
    
    return self.connectDeviceStaus;
}

/**
 获取已经发现的设备
 
 @return Device Array
 */
- (NSArray<CLUPnPDevice *> *)getDeviceList {
    
    return [self.upd getDeviceList];
}


/**
 ** DLNA投屏
 ** 【流程: 停止 ->设置代理 ->设置Url -> 播放】
 */
- (void)startDLNAAfterStop{
    StopAction *action = [[StopAction alloc]initWithDevice:self.device Success:^{
        [self initCLUPnPRendererAndDlnaPlay];
        
    } failure:^{
        [self initCLUPnPRendererAndDlnaPlay];
    }];
    [action executeAction];
}
/**
 初始化CLUPnPRenderer
 */
-(void)initCLUPnPRendererAndDlnaPlay{
    self.render = [[CLUPnPRenderer alloc] initWithModel:self.device];
    self.render.delegate = self;
    [self.render setAVTransportURL:self.playUrl];
}

/**
 退出DLNA
 */
- (void)endDLNA{
    [self.render stop];
}


/**
 设置播放链接
 @param url   资源URL
 @param isPlay   是否立即播放
 */
- (void)setAVTransportURL:(NSString*)url IsPlay:(BOOL)isPlay {
    
    self.playUrl = url;
    
    [self.render setAVTransportURL:self.playUrl];
    
    if (isPlay) {
        [self dlnaPlay];
    }
}
- (void)setAVTransportURL:(NSString*)url IsPlay:(BOOL)isPlay seek:(NSInteger)seek {
    
    self.playUrl = url;
    
    [self.render setAVTransportURL:self.playUrl];
    
    if (isPlay) {
        [self dlnaPlay];
    }
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (seek > 0) {
            
            NSString *seekStr = [self timeFormatted:seek];
            [self.render seekToTarget:seekStr Unit:unitREL_TIME];
        }
    });

}

- (void)setNextAVTransportURI:(NSString*)url{
    
//    self.playUrl = url;
    
    [self.render setNextAVTransportURI:url];
    
}

-(void)dlnaPlayNextSeek:(NSInteger)seek {
    
    [self.render next];
}


-(NSString*)currentPlayState {
    
//    BOOL  currentPlayState = [self.currentTransportState isEqualToString:@"PLAYING"];
    
//    NSLog(@"%@ currentPlayState == %d",self.currentTransportState,currentPlayState);
    
    return self.currentTransportState;
}

/**
 播放
 */
- (void)dlnaPlay{
    [self.render play];
}


/**
 暂停
 */
- (void)dlnaPause{
    [self.render pause];
}

/**
 搜设备
 */
- (void)startSearch{
    [self.upd start];
}


/**
 设置音量
 */
- (void)volumeChanged:(NSString *)volume{
    self.volume = volume;
    [self.render setVolumeWith:volume];
}


/**
 播放进度条
 */
- (void)seekChanged:(NSInteger)seek{
    self.seekTime = seek;
    NSString *seekStr = [self timeFormatted:seek];
    [self.render seekToTarget:seekStr Unit:unitREL_TIME];
}

-(double)getPlayTime {
    
    return self.currenPlayTime;
}
/**
 获取播放信息
 */
-(void)getPositionInfo {
    
    [self.render getPositionInfo];
    
}


/**
 获取播放状态,可通过协议回调使用
 */
- (void)getTransportInfo{
    
    [self.render getTransportInfo];
    
}
/**
 播放进度单位转换成string
 */
- (NSString *)timeFormatted:(NSInteger)totalSeconds
{
    NSInteger seconds = totalSeconds % 60;
    NSInteger minutes = (totalSeconds / 60) % 60;
    NSInteger hours = totalSeconds / 3600;
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)hours, (long)minutes, (long)seconds];
}

/**
 播放切集
 */
- (void)playTheURL:(NSString *)url{
    self.playUrl = url;
    [self.render setAVTransportURL:url];
}

#pragma mark -- 搜索协议CLUPnPDeviceDelegate回调
- (void)upnpSearchChangeWithResults:(NSArray<CLUPnPDevice *> *)devices{
    NSMutableArray *deviceMarr = [NSMutableArray array];
    for (CLUPnPDevice *device in devices) {
        // 只返回匹配到视频播放的设备
        if ([device.uuid containsString:serviceType_AVTransport]) {
            [deviceMarr addObject:device];
        }
    }
    if ([self.delegate respondsToSelector:@selector(searchDLNAResult:)]) {
        [self.delegate searchDLNAResult:[deviceMarr copy]];
    }
    self.dataArray = deviceMarr;
}

- (void)upnpSearchErrorWithError:(NSError *)error{
//    NSLog(@"DLNA_Error======>%@", error);
}

#pragma mark - CLUPnPResponseDelegate
- (void)upnpSetAVTransportURIResponse{
    [self.render play];
}

- (void)upnpGetTransportInfoResponse:(CLUPnPTransportInfo *)info{
    NSLog(@"%@ === %@", info.currentTransportState, info.currentTransportStatus);
    if (!([info.currentTransportState isEqualToString:@"PLAYING"] || [info.currentTransportState isEqualToString:@"TRANSITIONING"])) {
//        [self.render play];
    }
    
    self.currentTransportState = info.currentTransportState;
    
}

-(void)upnpGetPositionInfoResponse:(CLUPnPAVPositionInfo *)info{
    
    NSLog(@"absTime == %f",info.absTime);
    NSLog(@"relTime ==%f",info.relTime);
    
    self.currenPlayTime = info.absTime;
}



- (void)upnpPlayResponse{
    if ([self.delegate respondsToSelector:@selector(dlnaStartPlay)]) {
        [self.delegate dlnaStartPlay];
    }
}

#pragma mark Set&Get
- (void)setSearchTime:(NSInteger)searchTime{
    _searchTime = searchTime;
    self.upd.searchTime = searchTime;
}
@end
