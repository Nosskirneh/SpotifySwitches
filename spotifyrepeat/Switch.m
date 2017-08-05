#import "../include/FSSwitchDataSource.h"
#import "../include/FSSwitchPanel.h"
#import "../include/Common.h"

@interface SpotifyRepeatSwitch : NSObject <FSSwitchDataSource>
@end

@implementation SpotifyRepeatSwitch

- (NSString *)titleForSwitchIdentifier:(NSString *)switchIdentifier {
    return @"Spotify Repeat";
}

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier {
    // Update setting
    NSMutableDictionary *preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];
    
    BOOL enabled = [[preferences objectForKey:repeatKey] boolValue];
    return (enabled) ? FSSwitchStateOn : FSSwitchStateOff;
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier {
    switch (newState) {
        case FSSwitchStateIndeterminate:
            return;
            
        case FSSwitchStateOn:
            notify(doEnableRepeatNotification);
            break;
            
        case FSSwitchStateOff:
            notify(doDisableRepeatNotification);
            break;
    }
    return;
}

@end
