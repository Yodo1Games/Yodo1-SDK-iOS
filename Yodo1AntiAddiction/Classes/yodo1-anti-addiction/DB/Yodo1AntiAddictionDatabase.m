//
//  Yodo1AntiAddictionDatabase.m
//  yodo1-anti-Addiction-ios
//
//  Created by ZhouYuzhen on 2020/10/3.
//

#import "Yodo1AntiAddictionDatabase.h"
#import "Yd1OnlineParameter.h"
#import "Yodo1Tool.h"
#import "Yodo1Tool+Commons.h"
#import "Yodo1Tool+Storage.h"

#import "Yodo1AntiAddictionUser.h"
#import "Yodo1AntiAddictionRecord.h"
#import "Yodo1AntiAddictionBehaviour.h"

@interface Yodo1AntiAddictionDatabase()

@property (nonatomic, strong) FMDatabase *database;

@end

@implementation Yodo1AntiAddictionDatabase

+ (Yodo1AntiAddictionDatabase *)shared {
    static Yodo1AntiAddictionDatabase *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Yodo1AntiAddictionDatabase alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *appKey = [Yd1OnlineParameter shared].appKey;
        NSString *path = [[[Yodo1Tool shared] documents] stringByAppendingFormat:@"/yodo1-anti-Addiction-%@.db", appKey];
        _database = [FMDatabase databaseWithPath:path];
        
        if ([_database open]) {
#ifdef DEBUG
            _database.traceExecution = YES;
#endif
            // 创建表
            NSMutableString *statements = [NSMutableString string];
            [statements appendFormat:@"%@\n", [Yodo1AntiAddictionUser createSql]];
            [statements appendFormat:@"%@\n", [Yodo1AntiAddictionRecord createSql]];
            [statements appendFormat:@"%@\n", [Yodo1AntiAddictionBehaviour createSql]];
            [_database executeStatements:statements];
        }
    }
    return self;
}

//insert
- (long long)insertInto:(NSString *)table content:(NSDictionary *)content {
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"INSERT INTO %@ ", table];
    NSMutableString *colums = [NSMutableString string];
    NSMutableString *values = [NSMutableString string];
    NSMutableArray *args = [NSMutableArray array];
    
    for (id key in content) {
        [colums appendFormat:@"%@,", key];
        [values appendString:@"?,"];
        [args addObject:[content objectForKey:key]];
    }
    
    NSRange rangCol;
    rangCol.location = colums.length - 1;
    rangCol.length = 1;
    [colums deleteCharactersInRange:rangCol];
    
    NSRange rangValue;
    rangValue.location = values.length - 1;
    rangValue.length = 1;
    [values deleteCharactersInRange:rangValue];
    
    [sql appendFormat:@"(%@) VALUES(%@)", colums, values ];
    if ([_database executeUpdate:sql withArgumentsInArray:args]) {
        return  [_database lastInsertRowId];
    }
    if ([_database hadError]) {
        NSLog(@"insert failed! reason: %@", [_database lastErrorMessage]);
    }
    return 0;
}

//delete
- (int)deleteFrom:(NSString *)table where:(NSString * _Nullable)where {
    return [self deleteFrom:table where:where args:nil];
}

- (int)deleteFrom:(NSString *)table where:(NSString * _Nullable)where args:(NSArray * _Nullable)args {
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"DELETE FROM  %@  ", table];
    
    if (where != nil) {
        [sql appendFormat:@" WHERE %@ ", where ];
    }
    
    if ([_database executeUpdate:sql withArgumentsInArray:args]) {
        return [_database changes];
    }
    return 0 ;
}

//query
- (FMResultSet *)query:(NSString *)table projects:(NSArray * _Nullable)projects where:(NSString * _Nullable)where args:(NSArray * _Nullable)args order:(NSString * _Nullable)order {
    return [self query:table projects:projects where:where args:args order:order limitSize:0 offset:0];
}

- (FMResultSet *)query:(NSString *)table projects:(NSArray * _Nullable)projects where:(NSString * _Nullable)where args:(NSArray * _Nullable)args order:(NSString * _Nullable)order limitSize:(int)size offset:(int)offset {
    
    NSMutableString * sqlQuery = [NSMutableString stringWithFormat:@"SELECT "];
    
    if(projects != nil){
        NSMutableString *prj = [NSMutableString string];
        
        for (id key in projects) {
            [prj appendFormat:@"%@,", key];
        }
        
        NSRange rangCol;
        rangCol.location = prj.length - 1;
        rangCol.length = 1;
        [prj deleteCharactersInRange:rangCol];
        
        [sqlQuery appendFormat:@" %@ ", prj];
    } else {
        [sqlQuery appendString:@" * "];
    }
    
    [sqlQuery appendFormat:@" FROM %@ ", table ];
    if (where != nil) {
        [sqlQuery appendFormat:@" WHERE %@ ", where];
    }
    
    if (order != nil) {
        [sqlQuery appendFormat:@" ORDER BY %@ ", order];
    }
    
    if (size != 0) {
        [sqlQuery appendFormat:@" LIMIT %d ", size];
        if (offset != 0) {
            [sqlQuery appendFormat:@" OFFSET %d ", offset];
        }
    }
    
    FMResultSet *rs = [_database executeQuery:sqlQuery withArgumentsInArray:args];
    return rs;
}

//update
- (int)update:(NSString *)table content:(NSDictionary *)content where:(NSString *)where args:(NSArray *)args {
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"UPDATE  %@ SET ", table];
    NSMutableString *sets = [NSMutableString string];
    NSMutableArray *tempargs = [NSMutableArray array];
    
    for (id key in content) {
        [sets appendFormat:@"%@ = ?,", key];
        [tempargs addObject:[content objectForKey:key]];
    }
    
    NSRange rangCol;
    rangCol.location = sets.length - 1;
    rangCol.length = 1;
    [sets deleteCharactersInRange:rangCol];
    
    [tempargs addObjectsFromArray:args];
    if(where != nil) {
        [sql appendFormat:@" %@  WHERE %@", sets, where];
    } else {
        [sql appendFormat:@" %@ ", sets];
    }
    
    if ([_database executeUpdate:sql withArgumentsInArray:tempargs]) {
        return [_database changes];
    }
    return 0 ;
}

- (NSString *)genInSubstringFromArray:(NSArray *) array {
    NSMutableString *names = [NSMutableString string];
    [names appendString:@"("];
    for (int i = 0; i < array.count; i++) {
        [names appendFormat:@"'%@'", array[i] ];
        if (i < array.count - 1) {
            [names appendString:@","];
        }
    }
    [names appendString:@")"];
    return  names;
}

@end
