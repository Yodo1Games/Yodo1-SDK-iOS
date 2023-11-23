//
//  GMReplayASBDInfo.h
//  BDReplay
//
//  Created by Cliffe on 2021/8/3.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GMReplayASBDInfo : NSObject

@property (nonatomic, assign) int32_t trackId;
@property (nonatomic, assign) CGFloat sampleRate;
@property (nonatomic, assign) uint32_t bytesPerPacket;
@property (nonatomic, assign) int32_t bytesPerFrame;
@property (nonatomic, assign) int32_t channelsPerFrame;
@property (nonatomic, assign) int32_t bitsPerChannel;
@property (nonatomic, assign) AudioFormatFlags formatFlags;

@property (nonatomic, assign) uint64_t timeStamp;
@property (nonatomic, assign) CGFloat volume;

+ (instancetype)formatInfoWithDesc:(AudioStreamBasicDescription)desc;

-(void)updateInfoWithDesc:(AudioStreamBasicDescription)desc;

@end

NS_ASSUME_NONNULL_END
