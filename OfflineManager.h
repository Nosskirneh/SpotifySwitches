#import "SPCore.h"

#ifndef OFFLINEMANAGER_H
#define OFFLINEMANAGER_H

@interface OfflineManager : NSObject

- (void)setOffline:(BOOL)arg;
- (void)toggleOffline;
@property (nonatomic, assign, readwrite) SPCore *spotifyCore;
@property (nonatomic, assign, readwrite) BOOL isCurrentViewOfflineView;

+ (OfflineManager *)si;

@end


#endif
