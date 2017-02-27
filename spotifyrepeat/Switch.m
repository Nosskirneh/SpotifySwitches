#import "../include/FSSwitchDataSource.h"
#import "../include/FSSwitchPanel.h"
#import "../include/Header.h"

@interface SpotifyRepeatSwitch : NSObject <FSSwitchDataSource>
@end

@implementation SpotifyRepeatSwitch

- (id)init {
    // Init settings file
    preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];
    if (!preferences) preferences = [[NSMutableDictionary alloc] init];
    return self;
}

- (NSString *)titleForSwitchIdentifier:(NSString *)switchIdentifier {
    return @"Spotify Repeat";
}

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier {
    // Update setting
    preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];
    
    BOOL enabled = [[preferences objectForKey:repeatKey] boolValue];
    return (enabled) ? FSSwitchStateOn : FSSwitchStateOff;
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier {
    switch (newState) {
        case FSSwitchStateIndeterminate:
            return;
            
        case FSSwitchStateOn:
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)doEnableRepeatNotification, NULL, NULL, YES);
            break;
            
        case FSSwitchStateOff:
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)doDisableRepeatNotification, NULL, NULL, YES);
            break;
    }
    return;
}

@end
