//
//  GMAudioRecordStat.h
//  Pods
//
//  Created by bytedance on 2022/7/27.
//


typedef NS_ENUM(NSInteger, BDReplayAudioTrackType) {
    BDReplayAudioUnit = (1U << 3),
    BDReplayAUGraph = (1U << 4),
    BDReplayAUGraphConnect = (1U << 5)
};

@interface GMHookAudioTrackInfo : NSObject

@property (nonatomic, assign) size_t audio_track_id;
@property (nonatomic, assign) uint32_t audio_format;
@property (nonatomic, assign) uint32_t buffersize;
@property (nonatomic, assign) BDReplayAudioTrackType track_type;
@property (nonatomic, assign) int32_t sample_rate;
@property (nonatomic, assign) int32_t channel;

@end

@interface GMHookAudioTrackStat : NSObject
@property (nonatomic, assign) size_t audio_track_id;
@property (nonatomic, assign) uint16_t pre_buffer_size;
@property (nonatomic, assign) uint16_t post_buffer_size;

@end


@interface GMAudioRecordStat : NSObject
@property (nonatomic, strong) NSMutableDictionary<NSString *, GMHookAudioTrackInfo *>* info;

@property (nonatomic, strong) NSMutableDictionary<NSString *, GMHookAudioTrackStat *>* stat;

- (size_t) getAudioTrackSize;

- (NSMutableArray<GMHookAudioTrackInfo *> *) getHookAudioTrackInfoList;

- (GMHookAudioTrackStat *) getHookAudioTrackStat:(size_t)track_id;

@end
