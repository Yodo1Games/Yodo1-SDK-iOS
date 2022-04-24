//
//  Yodo1AntiAddictionDatabase.h
//  yodo1-anti-Addiction-ios
//
//  Created by ZhouYuzhen on 2020/10/3.
//

#import <Foundation/Foundation.h>
#import "Yodo1FMDB.h"

NS_ASSUME_NONNULL_BEGIN

@interface Yodo1AntiAddictionDatabase : NSObject

+ (Yodo1AntiAddictionDatabase *)shared;

//insert
- (long long)insertInto:(NSString *)table content:(NSDictionary *)content;

//delete
- (int)deleteFrom:(NSString *)table where:( NSString * _Nullable)where;
- (int)deleteFrom:(NSString *)table where:(NSString * _Nullable)where args:(NSArray * _Nullable)args;

//query
- (Yodo1FMResultSet *)query:(NSString *)table projects:(NSArray * _Nullable)projects where:(NSString * _Nullable)where args:(NSArray * _Nullable)args order:(NSString * _Nullable)order;
- (Yodo1FMResultSet *)query:(NSString *)table projects:(NSArray * _Nullable)projects where:(NSString * _Nullable)where args:(NSArray * _Nullable)args order:(NSString * _Nullable)order limitSize:(int)size offset:(int)offset;

//update
- (int)update:(NSString *)table content:(NSDictionary *)content where:(NSString *)where args:(NSArray *)args;

@end

NS_ASSUME_NONNULL_END
