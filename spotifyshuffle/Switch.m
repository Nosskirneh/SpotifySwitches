#import "../include/FSSwitchDataSource.h"
#import "../include/FSSwitchPanel.h"
#import "../include/Common.h"

@interface SpotifyShuffleSwitch : NSObject <FSSwitchDataSource>
@end

@implementation SpotifyShuffleSwitch

- (NSString *)titleForSwitchIdentifier:(NSString *)switchIdentifier {
	return @"Spotify Shuffle";
}

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier {
    // Update setting
    NSMutableDictionary *preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];

    BOOL enabled = [[preferences objectForKey:shuffleKey] boolValue];
	return (enabled) ? FSSwitchStateOn : FSSwitchStateOff;
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier {
    if (newState == FSSwitchStateIndeterminate) {
            return;
    }

    // Send notification
    notify(doToggleShuffleNotification);
    return;
}

@end
