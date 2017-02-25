#ifndef HEADER
#define HEADER

// Settings file
NSMutableDictionary *preferences;
NSString *const prefPath = @"/var/mobile/Library/Preferences/se.nosskirneh.spotifyswitches.plist";

// Notification strings
NSString *const nsDomainString = @"se.nosskirneh.spotifyswitches";
NSString *const doEnableOfflineModeNotification = @"se.nosskirneh.spotifyswitches/doEnableOfflineMode";
NSString *const doDisableOfflineModeNotification = @"se.nosskirneh.spotifyswitches/doDisableOfflineMode";
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

@interface SPBarViewController : UIViewController
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


// Use this when you've solved the shared settings problem.
//@interface Adjust : NSObject
//- (void)setOfflineMode:(BOOL)arg;
//@end


@interface SPNavigationController : UIViewController
@end


@interface NSUserDefaults (Tweak_Category)
- (id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
- (void)setObject:(id)value forKey:(NSString *)key inDomain:(NSString *)domain;
@end

#endif
