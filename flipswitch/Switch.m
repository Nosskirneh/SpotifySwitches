#import "FSSwitchDataSource.h"
#import "FSSwitchPanel.h"
#import "../OfflineManager.h"

@interface NSUserDefaults (Tweak_Category)
- (id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
- (void)setObject:(id)value forKey:(NSString *)key inDomain:(NSString *)domain;
@end

static NSString *nsDomainString = @"se.nosskirneh.sos";
static NSString *nsNotificationString = @"se.nosskirneh.sos/preferences.changed";

@interface SpotifyOfflineSwitchSwitch : NSObject <FSSwitchDataSource>
@end

@implementation SpotifyOfflineSwitchSwitch

- (NSString *)titleForSwitchIdentifier:(NSString *)switchIdentifier {
	return @"Spotify Offline";
}

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier {
	NSNumber *n = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"enabled" inDomain:nsDomainString];
	BOOL enabled = (n)? [n boolValue]:YES;
	return (enabled) ? FSSwitchStateOn : FSSwitchStateOff;
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier {
    switch (newState) {
        case FSSwitchStateIndeterminate:
            break;
        case FSSwitchStateOn:
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"enabled" inDomain:nsDomainString];
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)nsNotificationString, NULL, NULL, YES);
            
            HBLogDebug(@"%d", ([%c(OfflineManager) si].isCurrentViewOfflineView)); // This is always '0'
            HBLogDebug(@"Flipswitch ON");
            // Set spotify offline
            [[%c(OfflineManager) si] setOffline:YES];
            break;
        case FSSwitchStateOff:
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"enabled" inDomain:nsDomainString];
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)nsNotificationString, NULL, NULL, YES);
            
            HBLogDebug(@"%d", ([%c(OfflineManager) si].isCurrentViewOfflineView)); // This is always '0'
            HBLogDebug(@"Flipswitch OFF");
            // Set spotify online
            [[%c(OfflineManager) si] setOffline:NO];
            break;
    }
	return;
}

@end
