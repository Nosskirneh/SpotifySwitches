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
//- (void)toggleRepeatMode;
- (void)setRepeatMode:(NSUInteger)value;
@end


@interface SettingsSection : NSObject
@end


@interface SettingsViewController : UIViewController
@property (weak, nonatomic) NSArray<SettingsSection *> *sections;
@end


// Testing
@interface SPTPlayerFeatureImplementation : NSObject
- (id)gaiaDeviceManager;
@end


@interface SPTGaiaDevice : NSObject <NSCoding>
@property (nonatomic, strong, readwrite) NSString *name;
// not sure if these are needed:
@property (nonatomic, strong, readwrite) NSString *attachId;
@property (nonatomic, strong, readwrite) NSString *deviceId;
@end


@interface SPTGaiaDeviceManager : NSObject
- (NSArray *)devices;
- (id)activeDevice;
- (void)activateDevice:(id)device withCallback:(id)callback;
@end


#endif
