#import "AdjustTokenUtils.h"
#import "Yodo1Tool+Commons.h"

@interface AdjustTokenUtils()

@property (nonatomic, strong) NSMutableDictionary* events;

@end

@implementation AdjustTokenUtils

+ (AdjustTokenUtils *)shared {
    static AdjustTokenUtils* _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[AdjustTokenUtils alloc]init];
    });
    return _instance;
}

- (id)init {
    self = [super init];
    if (self) {
        _events = [[NSMutableDictionary alloc] init];
        
        NSString* pathName = @"Yodo1KeyConfig.bundle/Yodo1UAEvents";
        NSString* path=[NSBundle.mainBundle pathForResource:pathName ofType:@"plist"];
        NSDictionary* eventInfo =[NSMutableDictionary dictionaryWithContentsOfFile:path];
        if (eventInfo.count == 0) {
            YD1LOG(@"Not found the events information in Yodo1EventInfo.plist file, please check it.");
        } else {
            for (id key in eventInfo){
                NSDictionary* values = [eventInfo objectForKey:key];
                [_events setObject:values forKey:key];
            }
        }
    }
    return self;
}

- (void)dealloc {
    self.events = nil;
}

- (NSString*)getEventToken:(NSString*) eventName {
    NSString* token = @"";
    if (self.events.count <= 0) {
        return token;
    }
    
    for (NSString *key in self.events) {
        if ([key isEqualToString:eventName]) {
            NSDictionary* values = self.events[key];
            token = values[@"EventToken"];
            break;
        }
    }
    return token;
}

@end
