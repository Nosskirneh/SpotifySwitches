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
// Repeat
NSString *const doEnableRepeatNotification = @"se.nosskirneh.spotifyswitches/doEnableRepeat";
NSString *const doDisableRepeatNotification = @"se.nosskirneh.spotifyswitches/doDisableRepeat";

// Connect
NSString *const doChangeConnectDeviceNotification = @"se.nosskirneh.spotifyswitches/doChangeConnectDevice";

// Connectify settings
NSMutableArray<NSString *> *deviceNames;

// Lookup keys
NSString *const offlineKey = @"OfflineMode";
NSString *const shuffleKey = @"Shuffle";
NSString *const repeatKey  = @"Repeat";
NSString *const devicesKey = @"ConnectDevices";
NSString *const activeDeviceKey = @"ActiveConnectDevice";

// Other
NSString *const spotifyBundleIdentifier = @"com.spotify.client";


@interface SPCore : NSObject
- (void)setForcedOffline:(BOOL)arg;
@end


@interface SPTNowPlayingPlaybackController : NSObject
- (void)setGlobalShuffleMode:(BOOL)arg;
- (void)setRepeatMode:(NSUInteger)value;
@end


@interface SettingsSection : NSObject
@end


@interface SettingsViewController : UIViewController
@property (weak, nonatomic) NSArray<SettingsSection *> *sections;
@end


@interface SPTPlayerFeatureImplementation : NSObject
- (id)gaiaDeviceManager;
@end


@interface SPTGaiaDevice : NSObject <NSCoding>
@property (nonatomic, strong, readwrite) NSString *name;
@end


@interface SPTGaiaDeviceManager : NSObject
- (NSArray *)devices;
- (id)activeDevice;
- (void)activateDevice:(id)device withCallback:(id)callback;
@end


#endif
