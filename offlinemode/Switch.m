#import "../include/FSSwitchDataSource.h"
#import "../include/FSSwitchPanel.h"
#import "../include/Header.h"

@interface SpotifyOfflineSwitchSwitch : NSObject <FSSwitchDataSource>
@end

@implementation SpotifyOfflineSwitchSwitch

- (NSString *)titleForSwitchIdentifier:(NSString *)switchIdentifier {
	return @"Spotify Offline";
}

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier {
    NSNumber *n = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:offlineKey inDomain:nsDomainString];
    BOOL enabled = (n)? [n boolValue]:YES;
    return (enabled) ? FSSwitchStateOn : FSSwitchStateOff;
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier {
        switch (newState) {
            case FSSwitchStateIndeterminate:
                break;
            case FSSwitchStateOn:
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:offlineKey inDomain:nsDomainString];
                CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)offlineNotification, NULL, NULL, YES);
                break;
            case FSSwitchStateOff:
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:offlineKey inDomain:nsDomainString];
                CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)onlineNotification, NULL, NULL, YES);
                break;
        }
    
	return;
}

@end
