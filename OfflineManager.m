#import "OfflineManager.h"

@implementation OfflineManager : NSObject

+ (OfflineManager *)si {
    // structure used to test whether the block has completed or not
    static dispatch_once_t p = 0;
    
    // initialize sharedObject as nil (first call only)
    __strong static OfflineManager *_sharedObject = nil;
    
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    // returns the same object each time
    return _sharedObject;
}

- (void)setOffline:(BOOL)arg {
    HBLogDebug(@"Method setOffline called!");
    if (self.spotifyCore != nil && !self.isCurrentViewOfflineView) {
        [self.spotifyCore setForcedOffline:arg];
    }
}

- (void)toggleOffline {
    HBLogDebug(@"Method toggle called!");
    if (self.spotifyCore != nil && !self.isCurrentViewOfflineView) {
        if (self.spotifyCore.forcedOffline) {
            HBLogDebug(@"SPCore ON");
            [self.spotifyCore setForcedOffline:NO];
        } else {
            HBLogDebug(@"SPCore OFF");
            [self.spotifyCore setForcedOffline:YES];
        }
    }
}

@end
