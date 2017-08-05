#import "../include/FSSwitchDataSource.h"
#import "../include/FSSwitchPanel.h"
#import "../include/Common.h"

@interface SpotifyIncognitoSwitch : NSObject <FSSwitchDataSource>
@end

@implementation SpotifyIncognitoSwitch

- (NSString *)titleForSwitchIdentifier:(NSString *)switchIdentifier {
	return @"Spotify Incognito";
}

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier {
    // Update setting
    NSMutableDictionary *preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];

    BOOL enabled = [[preferences objectForKey:incognitoKey] boolValue];
	return (enabled) ? FSSwitchStateOn : FSSwitchStateOff;
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier {
    if (newState == FSSwitchStateIndeterminate) {
            return;
    }

    // Send notification
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)toggleIncognitoModeNotification, NULL, NULL, YES);
    return;
}

@end
