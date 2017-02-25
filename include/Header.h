#ifndef HEADER
#define HEADER

// Settings file
NSMutableDictionary *preferences;
NSString *const prefPath = @"/var/mobile/Library/Preferences/se.nosskirneh.spotifyswitches.plist";

// Notification strings
// Offline Mode
NSString *const nsDomainString = @"se.nosskirneh.spotifyswitches";
NSString *const doEnableOfflineModeNotification = @"se.nosskirneh.spotifyswitches/doEnableOfflineMode";
NSString *const doDisableOfflineModeNotification = @"se.nosskirneh.spotifyswitches/doDisableOfflineMode";
// Shuffle
NSString *const doToggleShuffleNotification = @"se.nosskirneh.spotifyswitches/doToggleShuffle";

// Lookup keys
NSString *const offlineKey = @"SpotifyOfflineMode";
NSString *const shuffleKey = @"SpotifyShuffle";


@interface SPCore : NSObject
- (void)setForcedOffline:(BOOL)arg;
@end


@interface SPSession : NSObject
@property (nonatomic, assign, readwrite) BOOL isOffline;
@property (nonatomic, assign, readwrite) BOOL isOnline;
@end


@interface SPTNowPlayingPlaybackController : NSObject
- (void)setGlobalShuffleMode:(BOOL)arg;
- (BOOL)isShuffling;
@end


@interface SettingsSection : NSObject
@end


@interface SettingsViewController : UIViewController
@property (weak, nonatomic) NSArray<SettingsSection *> *sections;
@end

#endif
