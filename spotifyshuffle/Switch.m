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
    switch (newState) {
        case FSSwitchStateIndeterminate:
            return;
            
        case FSSwitchStateOn:
            [preferences setObject:[NSNumber numberWithBool:YES] forKey:shuffleKey];
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)doToggleShuffleNotification, NULL, NULL, YES);
            break;
            
        case FSSwitchStateOff:
            [preferences setObject:[NSNumber numberWithBool:NO] forKey:shuffleKey];
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)doToggleShuffleNotification, NULL, NULL, YES);
            break;
    }
    
    if (![preferences writeToFile:prefPath atomically:YES]) {
        HBLogError(@"Could not save preferences!");
    }
    
    return;
}

@end
