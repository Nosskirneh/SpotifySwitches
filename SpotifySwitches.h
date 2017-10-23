// MobileGestalt stuff for UDID
extern "C" CFPropertyListRef MGCopyAnswer(CFStringRef property);

@interface SPTPlayerTrack : NSObject
@property (nonatomic, assign, readwrite) NSURL *URI;
- (NSString *)trackTitle;
@end



@interface SPTRecentlyPlayedEntityList : NSObject
@property (nonatomic, readwrite, assign) NSMutableArray *allEntities;
@end


@interface SPTPlaylistPlatformPlaylistMetadataFieldsImplementation : NSObject
@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, assign, readwrite) BOOL isOwnedBySelf;
@property (nonatomic, assign, readwrite) BOOL isCollaborative;
@property (nonatomic, assign, readwrite) BOOL isFollowed;
@property (nonatomic, assign, readwrite) NSURL *URL;
@end

@interface Protocol : NSObject
@end

@interface __NSSingleEntryDictionaryI : NSDictionary {
    id  _key;
    id  _obj;
}
@end

@interface SPTRecentlyPlayedEntity : NSObject
@property (nonatomic, assign, readwrite) NSUInteger contentType;
@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, copy, readwrite) NSURL *navigatableEntityURL;
@end


@interface SPTNetworkConnectivityController : NSObject
@property (nonatomic, readwrite, assign) BOOL forcedOffline;
- (void)setForcedOffline:(BOOL)arg1 callback:(id)arg2;
@end


@interface SettingsSection : NSObject
@end

@interface SettingsSwtichTableViewCell : UITableViewCell
@property (nonatomic, readwrite, assign) UISwitch *switchControl;
@end

@interface OfflineSettingsSection : SettingsSection
@property (nonatomic, readwrite, assign) SettingsSwtichTableViewCell *offlineModeCell;
@end

@interface SettingsViewController : UIViewController
@property (weak, nonatomic) NSArray<SettingsSection *> *sections;
@property (nonatomic, readwrite, assign) UITableView *tableView;
@end


@interface SPUser : NSObject
@property (nonatomic, readwrite, assign) NSString *username;
@end


@interface SPTNowPlayingPlaybackController : NSObject
- (void)setGlobalShuffleMode:(BOOL)arg;
- (void)setRepeatMode:(NSUInteger)value;
- (void)setPaused:(BOOL)arg;
- (BOOL)isPaused;
- (BOOL)isShuffling;
- (NSUInteger)repeatMode;
@end


@interface SPTIncognitoModeHandler : NSObject
@end

@interface NSObject (Incognito)
- (BOOL)isIncognitoModeEnabled;
- (void)disableIncognitoMode;
- (void)enableIncognitoMode;
@end

@interface SPSession : NSObject
// < 8.4.24
- (void)enableIncognitoMode;
- (void)disableIncognitoMode;
- (BOOL)isIncognitoModeEnabled;

// >= 8.4.24
- (id)incognitoModeHandler;
@end


@interface SPCore : NSObject
+ (id)sharedCore;
- (SPSession *)session;
@end


@interface SPTStatefulPlayer : NSObject
- (SPTPlayerTrack *)currentTrack;
@end


@interface SPTNowPlayingAuxiliaryActionsModel : NSObject
- (BOOL)isInCollection;
- (void)addToCollection;
- (void)removeFromCollection;
@end


@interface SPTPlaylistCosmosModel : NSObject
- (void)fetchPlaylistMetadataForPlaylistURL:(id)arg1 options:(id)arg2 withPolicyProtocols:(NSArray<Protocol *> *)arg3 completion:(id)arg4 onError:(id)arg5;
- (void)playlistContainsTrackURLs:(NSArray *)tracks playlistURL:(NSURL *)url completion:(id)block;
- (void)createPlaylistWithName:(NSString *)name completion:(id)arg;
- (void)addTrackURLs:(id)URLs toPlaylistURL:(id)URL completion:(id)arg;
@end

@interface SPTPlaylistCosmosViewModel : NSObject
@property (nonatomic, assign, readwrite) NSURL *entityURL;
@property (nonatomic, assign, readwrite) SPTPlaylistPlatformPlaylistMetadataFieldsImplementation *metadata;
@end


// Connect devices
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


@interface SPTGaiaManagerImplementation : NSObject
@property (nonatomic, strong, readwrite) NSString *activeDeviceName;
@property (nonatomic, assign, readwrite) NSInteger activeConnectionType;
@end


// Popups
@interface ANSApplication : NSObject
@property (nonatomic, readwrite, assign) NSString *bundleVersion;
@property (nonatomic, readwrite, assign) NSString *shortVersionString;
+ (ANSApplication *)hostApplication;
@end

@interface SPTPopupManager : NSObject
@property (nonatomic, readwrite, assign) NSMutableArray *presentationQueue;
+ (SPTPopupManager *)sharedManager;
- (void)presentNextQueuedPopup;
@end

@interface SPTPopupDialog : UIViewController
@property (nonatomic, readwrite, assign) SPTPopupManager *presentingPopupManager;
+ (id)popupWithTitle:(NSString *)title message:(NSString *)message dismissButtonTitle:(NSString *)buttonTitle;
+ (id)popupWithTitle:(NSString *)title message:(NSString *)message buttons:(id)buttons;
@end

/* ----- */
