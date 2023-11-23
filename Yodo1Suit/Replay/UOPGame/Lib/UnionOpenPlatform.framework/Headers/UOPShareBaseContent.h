//
//  UOPShareBaseContent.h
//  UnionOpenPlatform
//
//  Created by ByteDance on 2021/6/8.
//

#import <Foundation/Foundation.h>
#import <UnionOpenPlatform/UOPServiceShareProtocol.h>

NS_ASSUME_NONNULL_BEGIN

@interface UOPShareBaseContent : NSObject<UOPServiceShareBaseContentProtocol>

- (NSString *_Nonnull)platformTypeString;

- (NSString *_Nullable)contentTypeString;

@end

NS_ASSUME_NONNULL_END
