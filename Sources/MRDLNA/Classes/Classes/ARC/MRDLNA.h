//
//  MRDLNA.h
//  MRDLNA
//
//  Created by MccRee on 2018/5/4.
//

#import <Foundation/Foundation.h>
#import "CLUPnP.h"
#import "CLUPnPDevice.h"

@protocol DLNADelegate <NSObject>

@optional
/**
 DLNA局域网搜索设备结果
 @param devicesArray <CLUPnPDevice *> 搜索到的设备
 */
- (void)searchDLNAResult:(NSArray *)devicesArray;

/**
 链接设备结果
 @param device   链接的设备
 @param status   链接的状态
 */
-(void)connectDevice:(CLUPnPDevice*)device Status:(BOOL)status;
/**
 投屏成功开始播放
 */
- (void)dlnaStartPlay;

@end

@interface MRDLNA : NSObject

@property(nonatomic,weak)id<DLNADelegate> delegate;

@property(nonatomic, strong) CLUPnPDevice *device;

@property(nonatomic,copy) NSString *playUrl;

@property(nonatomic,assign) NSInteger searchTime;

/**
 单例
 */
+(instancetype)sharedMRDLNAManager;

/**
 搜设备
 */
- (void)startSearch;

/**
 连接设备
 */
-(void)connectDevice:(CLUPnPDevice*)device;

/**
 获取连接状态
 */
-(BOOL)getConnectDeviceStaus;


/**
 获取已经发现的设备
 
 @return Device Array
 */
- (NSArray<CLUPnPDevice *> *)getDeviceList;


/**
 DLNA投屏
 */
//- (void)startDLNA;
/**
 DLNA投屏(首先停止)---投屏不了可以使用这个方法
 ** 【流程: 停止 ->设置代理 ->设置Url -> 播放】
 */
- (void)startDLNAAfterStop;


/**
 设置播放链接
 @param url   资源URL
 @param isPlay   是否立即播放
 */
- (void)setAVTransportURL:(NSString*)url IsPlay:(BOOL)isPlay ;

- (void)setAVTransportURL:(NSString*)url IsPlay:(BOOL)isPlay seek:(NSInteger)seek;

- (void)setNextAVTransportURI:(NSString*)url;

-(void)dlnaPlayNextSeek:(NSInteger)seek;

-(NSString*)currentPlayState;

/**
 退出DLNA
 */
- (void)endDLNA;

/**
 播放
 */
- (void)dlnaPlay;

/**
 暂停
 */
- (void)dlnaPause;



/**
 设置音量 volume建议传0-100之间字符串
 */
- (void)volumeChanged:(NSString *)volume;

/**
 设置播放进度 seek单位是秒
 */
- (void)seekChanged:(NSInteger)seek;

/**
 播放切集
 */
- (void)playTheURL:(NSString *)url;
/**
 当前播放时间
 */
-(double)getPlayTime;
/**
 获取播放信息
 */
-(void)getPositionInfo;

/**
 获取播放状态,可通过协议回调使用
 */
- (void)getTransportInfo;


@end
