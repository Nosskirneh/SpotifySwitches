#import "ConnectManager.h"

@implementation ConnectManager

+ (id)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t token = 0;
    dispatch_once(&token, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

@end

%ctor {
    [ConnectManager sharedInstance];
}
