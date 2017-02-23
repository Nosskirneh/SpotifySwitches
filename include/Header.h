#ifndef HEADER
#define HEADER

// Notification strings
NSString *const nsDomainString = @"se.nosskirneh.spotifyswitches";
NSString *const onlineNotification = @"se.nosskirneh.spotifyswitches/online";
NSString *const offlineNotification = @"se.nosskirneh.spotifyswitches/offline";
//NSString *const offlineModeChanged = @"se.nosskirneh.spotifyswitches/toggledOffline";
NSString *const shuffleOnNotification = @"se.nosskirneh.spotifyswitches/shuffleOn";
NSString *const shuffleOffNotification = @"se.nosskirneh.spotifyswitches/shuffleOff";
//NSString *const shuffleChanged = @"se.nosskirneh.spotifyswitches/toggledShuffle";

// Lookup keys
NSString *const offlineKey = @"SpotifyOfflineMode";
NSString *const shuffleKey = @"SpotifyShuffle";


@interface SPCore : NSObject
- (void)setForcedOffline:(BOOL)arg;
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
