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

// Add to playlist
NSString *const addCurrentTrackToPlaylistNotification = @"se.nosskirneh.spotifyswitches/addCurrentTrackToPlaylist";
#define specifiedPlaylistName [preferences objectForKey:@"specifiedPlaylistName"]

// Add to collection
NSString *const toggleCurrentTrackInCollectionNotification = @"se.nosskirneh.spotifyswitches/toggleCurrentTrackInCollection";

// Incognito Mode
NSString *const toggleIncognitoModeNotification = @"se.nosskirneh.spotifyswitches/toggleIncognitoMode";

// Preferences
NSString *const preferencesChangedNotification = @"se.nosskirneh.spotifyswitches/preferencesChanged";



// Connectify and AddToPlaylist arrays
NSMutableArray<NSString *> *deviceNames;
NSMutableArray *playlists;
NSMutableDictionary *playlist;

// Lookup keys
NSString *const offlineKey = @"OfflineMode";
NSString *const shuffleKey = @"Shuffle";
NSString *const repeatKey  = @"Repeat";
NSString *const devicesKey = @"ConnectDevices";
NSString *const activeDeviceKey = @"ActiveConnectDevice";
NSString *const playlistsKey = @"Playlists";
NSString *const chosenPlaylistKey = @"ChosenPlaylist";
NSString *const isCurrentTrackNullKey = @"isCurrentTrackNull";
NSString *const isCurrentTrackInCollectionKey = @"isCurrentTrackInCollection";
NSString *const incognitoKey = @"IncognitoMode";

// Other
NSString *const spotifyBundleIdentifier = @"com.spotify.client";


@interface SPCore : NSObject
- (void)setForcedOffline:(BOOL)arg;
@end


@interface SPTNowPlayingPlaybackController : NSObject
- (void)setGlobalShuffleMode:(BOOL)arg;
- (void)setRepeatMode:(NSUInteger)value;
- (void)setPaused:(BOOL)arg;
- (BOOL)isPaused;
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


@interface SPPlayerTrack : NSObject
@property (nonatomic, assign, readwrite) NSURL *URI;
@property (nonatomic, assign, readwrite) NSString *showTitle;
@end

@interface SPPlaylist : NSObject
- (void)addTrackURLs:(id)arg;
- (id)trackURLSet;
@property (nonatomic, assign, readwrite) NSURL *URL;
@property (nonatomic, assign, readwrite) NSString *name;
@property (nonatomic, assign, readwrite) BOOL isWriteable;
@end


@interface SPPlaylistContainer : NSObject
@property (nonatomic, assign, readwrite) NSArray *actualPlaylists;
@end


@interface SPPlaylistContainerCallbacksHolder : NSObject
- (id)playlists;
- (void)retrievePlaylists;
@end


@interface SPTStatefulPlayer : NSObject
- (id)currentTrack;
@end


@interface SPTNowPlayingAuxiliaryActionsModel : NSObject
- (BOOL)isInCollection;
- (void)addToCollection;
- (void)removeFromCollection;
@end


@interface SPSession : NSObject
- (void)enableIncognitoMode;
- (void)disableIncognitoMode;
- (BOOL)isIncognitoModeEnabled;
@end

#endif
