#import "../include/FSSwitchDataSource.h"
#import "../include/FSSwitchPanel.h"
#import "../include/Header.h"

@interface SpotifyShuffleSwitch : NSObject <FSSwitchDataSource>
@end

@implementation SpotifyShuffleSwitch

- (id)init {
    // Init settings file
    preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];
    if (!preferences) preferences = [[NSMutableDictionary alloc] init];
    return self;
}

- (NSString *)titleForSwitchIdentifier:(NSString *)switchIdentifier {
	return @"Spotify Shuffle";
}

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier {
    // Update setting
    preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];

    BOOL enabled = [[preferences objectForKey:shuffleKey] boolValue];
	return (enabled) ? FSSwitchStateOn : FSSwitchStateOff;
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier {
    if (newState == FSSwitchStateIndeterminate) {
            return;
    }

    // Send notification
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)doToggleShuffleNotification, NULL, NULL, YES);
    return;
}

@end
