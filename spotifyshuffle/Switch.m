#import "../include/FSSwitchDataSource.h"
#import "../include/FSSwitchPanel.h"
#import "../include/Header.h"

@interface SpotifyShuffleSwitch : NSObject <FSSwitchDataSource>
@end

@implementation SpotifyShuffleSwitch

- (NSString *)titleForSwitchIdentifier:(NSString *)switchIdentifier {
	return @"Spotify Shuffle";
}

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier {
	NSNumber *n = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:shuffleKey inDomain:nsDomainString];
	BOOL enabled = (n)? [n boolValue]:YES;
	return (enabled) ? FSSwitchStateOn : FSSwitchStateOff;
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier {
	switch (newState) {
	case FSSwitchStateIndeterminate:
		break;
	case FSSwitchStateOn:
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:shuffleKey inDomain:nsDomainString];
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)shuffleOnNotification, NULL, NULL, YES);
		break;
	case FSSwitchStateOff:
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:shuffleKey inDomain:nsDomainString];
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)shuffleOffNotification, NULL, NULL, YES);
		break;
	}
	return;
}

@end
