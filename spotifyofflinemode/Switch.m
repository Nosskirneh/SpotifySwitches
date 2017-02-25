#import "../include/FSSwitchDataSource.h"
#import "../include/FSSwitchPanel.h"
#import "../include/Header.h"

@interface SpotifyOfflineSwitchSwitch : NSObject <FSSwitchDataSource>
@end

@implementation SpotifyOfflineSwitchSwitch

- (id)init {
    // Init settings file
    preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];
    if (!preferences) preferences = [[NSMutableDictionary alloc] init];
    return self;
}

- (NSString *)titleForSwitchIdentifier:(NSString *)switchIdentifier {
    return @"Spotify Offline";
}

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier {
    // Update setting
    preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];

    BOOL enabled = [[preferences objectForKey:offlineKey] boolValue];
    return (enabled) ? FSSwitchStateOn : FSSwitchStateOff;
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier {
    switch (newState) {
        case FSSwitchStateIndeterminate:
            return;
            
        case FSSwitchStateOn:
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)doEnableOfflineModeNotification, NULL, NULL, YES);
            break;
            
        case FSSwitchStateOff:
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)doDisableOfflineModeNotification, NULL, NULL, YES);
            break;
    }
    
    return;
}

@end
