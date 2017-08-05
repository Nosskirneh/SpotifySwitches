#import "include/Common.h"
#import "SpotifySwitches.h"
#import <AVFoundation/AVAudioSession.h>

// Offline toggle
static SPTNetworkConnectivityController *connectivityController;
static OfflineSettingsSection *offlineViewController;

// Shuffle and repeat
static SPTNowPlayingPlaybackController *playbackController;

// Save to playlist/collection
static SPTStatefulPlayer *statefulPlayer;
static SPTNowPlayingAuxiliaryActionsModel *auxActionModel;
static SPTPlaylistCosmosModel *playlistModel;

// Connect
static SPTGaiaDeviceManager *gaia;

static int startCount;
static BOOL didFinishStartup;

NSMutableDictionary *preferences;
static NSMutableArray<Protocol *> *protocols;

// Update playlists on app launch (in case a playlist was deleted or modified)
void updatePlaylists() {
    if (playlistModel && preferences[playlistsKey]) {
        NSMutableArray *playlists = [preferences[playlistsKey] mutableCopy];
        NSMutableSet *playlistsSet = [NSMutableSet setWithArray:[preferences[playlistsSetKey] mutableCopy]];
        NSMutableSet *playlistsNotSavedInArray = [playlistsSet mutableCopy];

        for (NSDictionary *playlist in playlists) {
            [playlistModel fetchPlaylistMetadataForPlaylistURL:[NSURL URLWithString:playlist[@"URL"]]
                                           options:nil
                               withPolicyProtocols:[protocols copy]
                                        completion:^(SPTPlaylistPlatformPlaylistMetadataFieldsImplementation *metadata) {
                                                NSUInteger index = [playlists indexOfObject:playlist];
                                                if ((metadata.isOwnedBySelf || metadata.isCollaborative) && metadata.isFollowed) {
                                                    NSMutableDictionary *list = [playlist mutableCopy];

                                                    // name
                                                    list[@"name"] = metadata.name;
                                                    //HBLogDebug(@"not removing: %@ on index %d", list[@"name"], index);

                                                    // Store the updated playlist back
                                                    playlists[index] = list;
                                                } else {
                                                    // Remove playlist if not followed
                                                    // HBLogDebug(@"Removing: %@", playlist[@"name"]);
                                                    [playlists removeObject:playlist];
                                                    [playlistsSet removeObject:playlist[@"URL"]];
                                                    [playlistsNotSavedInArray removeObject:playlist[@"URL"]];
                                                    preferences[playlistsSetKey] = playlistsSet.allObjects;
                                                }

                                                // Store the array and set of playlists back
                                                preferences[playlistsKey] = playlists;
                                                writeToSettings(prefPath);
                                            }
                                           onError:nil];

            [playlistsNotSavedInArray removeObject:playlist[@"URL"]];
        }

        // Loop through the remaining playlists that was already known but was not ownedBySelf or collaborative
        for (NSString *url in playlistsNotSavedInArray) {
            [playlistModel fetchPlaylistMetadataForPlaylistURL:[NSURL URLWithString:url]
                                           options:nil
                               withPolicyProtocols:[protocols copy]
                                        completion:^(SPTPlaylistPlatformPlaylistMetadataFieldsImplementation *metadata) {
                                                if ((metadata.isOwnedBySelf || metadata.isCollaborative) && metadata.isFollowed) {
                                                    NSMutableDictionary *list = [[NSMutableDictionary alloc] init];

                                                    // name
                                                    list[@"name"] = metadata.name;

                                                    // Add the playlist
                                                    [playlists addObject:list];

                                                    //HBLogDebug(@"name: %@", metadata.name);
                                                    // Store the array and set of playlists back
                                                    preferences[playlistsKey] = playlists;
                                                    preferences[playlistsSetKey] = playlistsSet.allObjects;
                                                    writeToSettings(prefPath);
                                                }
                                            }
                                           onError:nil];

        }
    }
}

// Help method that adds an array of tracks to a playlist
void _addTracksToPlaylist(NSArray<SPTPlayerTrack *> *tracks, int index, NSMutableArray *lists) {
    NSMutableDictionary *list = [lists[index] mutableCopy];
    NSURL *url = [NSURL URLWithString:list[@"URL"]];

    //HBLogDebug(@"Adding track '%@' to playlist '%@'", tracks[0], list[@"name"]);
    [playlistModel addTrackURLs:tracks toPlaylistURL:url completion:nil];
}

// Adds the current track to an playlist given an index
void addTrackToPlaylist(int index) {
    NSArray *lists = preferences[playlistsKey];
    NSMutableDictionary *list = [lists[index] mutableCopy];
    NSURL *url = [NSURL URLWithString:list[@"URL"]];

    SPTPlayerTrack *currentTrack = [statefulPlayer currentTrack];
    NSArray *tracks = [[NSArray alloc] initWithObjects:currentTrack.URI, nil];

    if (!preferences[skipDuplicatesKey] || [preferences[skipDuplicatesKey] boolValue]) {
        // Default to skip duplicates
        [playlistModel playlistContainsTrackURLs:tracks
                                     playlistURL:url
                                      completion:^(NSSet *set) {
                                        if (![set containsObject:currentTrack.URI]) {
                                            //HBLogDebug(@"No duplicate!");
                                            _addTracksToPlaylist(tracks, index, [lists mutableCopy]);
                                        }
                                     }];
    } else {
        _addTracksToPlaylist(tracks, index, [lists mutableCopy]);
    }
}


/* Notifications methods */
// Update preferences
void updateSettings(notifactionArguments) {
    preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];
}

// Add to playlist
void addCurrentTrackToPlaylist(notifactionArguments) {
    preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];

    int index = [preferences[playlistIndexKey] intValue];

    // Has user specified playlist in preferences?
    NSString *specifiedPlaylistName = preferences[specifiedPlaylistNameKey];
    if (specifiedPlaylistName != nil && ![specifiedPlaylistName isEqualToString:@""]) {
        //HBLogDebug(@"Recieved notification and will add to specified playlist: %@", specifiedPlaylistName);
        NSArray *playlists = preferences[playlistsKey];
        for (NSDictionary *list in playlists) {
            if ([list[@"name"] isEqualToString:specifiedPlaylistName]) {
                index = [playlists indexOfObject:list];
            }
        }
    }

    addTrackToPlaylist(index);
}


// Add to collection
void toggleCurrentTrackInCollection(notifactionArguments) {
    [auxActionModel isInCollection] ? [auxActionModel removeFromCollection] :
                                      [auxActionModel addToCollection];
}

// Connect
void doChangeConnectDevice(notifactionArguments) {
    // Update device
    preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];
    NSString *deviceName = preferences[activeDeviceKey];

    for (SPTGaiaDevice *device in [gaia devices]) {
        if ([device.name isEqualToString:deviceName]) {
            [gaia activateDevice:device withCallback:nil];
            return;
        }
    }

     // No matching names
     [gaia activateDevice:nil withCallback:nil];
}


// Offline
void doEnableOfflineMode(notifactionArguments) {
    [connectivityController setForcedOffline:YES callback:nil];

    // Update UISwitch on external change
    if (offlineViewController) {
        [offlineViewController.offlineModeCell.switchControl setOn:YES animated:YES];
    }
}

void doDisableOfflineMode(notifactionArguments) {
    [connectivityController setForcedOffline:NO callback:nil];

    // Update UISwitch on external change
    if (offlineViewController) {
        [offlineViewController.offlineModeCell.switchControl setOn:NO animated:YES];
    }
}

// Shuffle
void doToggleShuffle(notifactionArguments) {
    // Update state
    preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];
    BOOL enabled = [preferences[shuffleKey] boolValue];
    [playbackController setGlobalShuffleMode:!enabled];

    preferences[shuffleKey] = [NSNumber numberWithBool:!enabled];
    writeToSettings(prefPath);
}

// Repeat
void doEnableRepeat(notifactionArguments) {
    [playbackController setRepeatMode:2];
}

void doDisableRepeat(notifactionArguments) {
    [playbackController setRepeatMode:0];
}

// Incognito Mode
void toggleIncognitoMode(notifactionArguments) {
    BOOL enabled = [[[%c(SPCore) sharedCore] session] isIncognitoModeEnabled];
    enabled ? [[[%c(SPCore) sharedCore] session] disableIncognitoMode] :
              [[[%c(SPCore) sharedCore] session] enableIncognitoMode];
}


/* Classes to hook */

// Update list of playlists on change of "Recently Played" section
// is also executed on app launch
%hook SPTRecentlyPlayedEntityList

- (void)recentlyPlayedModelDidReload:(id)arg {
    %orig;

    for (SPTRecentlyPlayedEntity *entity in self.allEntities) {
        // If contentType is not playlist
        if (entity.contentType != 2) {
            continue;
        }

        NSMutableSet *playlistsSet = [NSMutableSet setWithArray:[preferences[playlistsSetKey] mutableCopy]];

        if (protocols && playlistModel && (![playlistsSet containsObject:entity.navigatableEntityURL.absoluteString])) {
            // Add it to the set
            [playlistsSet addObject:entity.navigatableEntityURL.absoluteString];
            preferences[playlistsSetKey] = playlistsSet.allObjects;

            [playlistModel fetchPlaylistMetadataForPlaylistURL:entity.navigatableEntityURL
                                                       options:nil
                                           withPolicyProtocols:[protocols copy]
                                                    completion:^(SPTPlaylistPlatformPlaylistMetadataFieldsImplementation *metadata) {
                                                            if ((metadata.isOwnedBySelf || metadata.isCollaborative) && metadata.isFollowed) {
                                                                NSMutableArray *playlists;
                                                                if (!preferences[playlistsKey]) {
                                                                    playlists = [[NSMutableArray alloc] init];
                                                                } else {
                                                                    playlists = [preferences[playlistsKey] mutableCopy];
                                                                }

                                                                //HBLogDebug(@"name: %@", entity.title);

                                                                NSMutableDictionary *list = [[NSMutableDictionary alloc] init];

                                                                // URL and name
                                                                list[@"URL"] = entity.navigatableEntityURL.absoluteString;
                                                                list[@"name"] = metadata.name;

                                                                // Add it to the array
                                                                [playlists addObject:list];

                                                                preferences[playlistsKey] = playlists;
                                                                writeToSettings(prefPath);
                                                           }
                                                       }
                                                       onError:nil];
        }
    }
}

%end


// Save playlists when browsing the playlist tab
%hook SPTPlaylistPlatformPlaylistMetadataFieldsImplementation

- (NSURL *)URL {
    NSURL *URL = %orig;

    if (!self.isOwnedBySelf && !self.isCollaborative) {
        return URL;
    }

    NSMutableSet *playlistsSet = [NSMutableSet setWithArray:[preferences[playlistsSetKey] mutableCopy]];

    // Already known playlists?
    if ([playlistsSet containsObject:URL.absoluteString]) {
        return URL;
    }

    // Add it to the set
    [playlistsSet addObject:URL.absoluteString];

    NSMutableArray *playlists = [preferences[playlistsKey] mutableCopy];
    NSMutableDictionary *list = [[NSMutableDictionary alloc] init];

    // URL and name
    list[@"URL"] = URL.absoluteString;
    list[@"name"] = self.name;

    // Add it to the array
    [playlists addObject:list];

    preferences[playlistsSetKey] = playlistsSet.allObjects;
    preferences[playlistsKey] = playlists;

    writeToSettings(prefPath);
    return URL;
}

%end


// Stores `Protocol`s - is used to fetch playlist metadata
%hook SPTCosmosFieldImplementation

- (id)initWithProtocol:(Protocol *)protocol policyDictionary:(__NSSingleEntryDictionaryI *)dict populateBlock:(id)block {
    if (!protocols) {
        protocols = [[NSMutableArray alloc] init];
    }

    /*
    The protocols that exist are: name, description, link, picture, formatListAttributes,
    followed, totalLength, ownedBySelf, owner, offline, formatListType, collaborative,
    published, loaded, followers, lastModification, duration, canReportAnnotationAbuse
    */

    if (([[dict allKeys][0] isEqualToString:@"name"] && protocols.count == 0) ||
        ([[dict allKeys][0] isEqualToString:@"followed"] && protocols.count == 1) ||
        ([[dict allKeys][0] isEqualToString:@"ownedBySelf"] && protocols.count == 2)) {
        [protocols addObject:protocol];
    } else if ([[dict allKeys][0] isEqualToString:@"collaborative"] && protocols.count == 3) {
        [protocols addObject:protocol];
        updatePlaylists();
    }

    // Somehow this was needed in 8.4.11
    if ([[dict allKeys][0] isEqualToString:@"name"]) {
        protocols[0] = protocol;
    }

    return %orig;
}

%end


%hook SPTPlaylistCosmosModel

// It seems to exists one of these for each folder, and then one for the main menu
- (id)initWithCosmosDataLoader:(id)arg {
    return playlistModel ? %orig : playlistModel = %orig;
}

- (void)removePlaylistOrFolderURL:(NSURL *)url inFolderURL:(id)arg2 completion:(id)arg3 {
    %orig;

    NSMutableSet *playlistsSet = [NSMutableSet setWithArray:[preferences[playlistsSetKey] mutableCopy]];
    if (![playlistsSet containsObject:url.absoluteString]) {
        return;
    }

    [playlistsSet removeObject:url.absoluteString];
    preferences[playlistsSetKey] = playlistsSet.allObjects;

    NSMutableArray *playlists = [preferences[playlistsKey] mutableCopy];
    for (NSDictionary *list in playlists) {
        if ([list[@"URL"] isEqualToString:url.absoluteString]) {
            //HBLogDebug(@"Removed playlist: %@", list[@"name"]);

            // Remove playlist from array
            [playlists removeObject:list];
            preferences[playlistsKey] = playlists;

            writeToSettings(prefPath);
            return;
        }
    }
}

- (void)renamePlaylistURL:(NSURL *)url name:(NSString *)name completion:arg {
    %orig;

    // Return if the playlist does not exist in the set
    NSSet *playlistsSet = [NSSet setWithArray:[preferences[playlistsSetKey] copy]];
    if (![playlistsSet containsObject:url.absoluteString]) {
        return;
    }

    // Otherwise update the playlist name
    NSMutableArray *playlists = [preferences[playlistsKey] mutableCopy];
    for (NSMutableDictionary *list in playlists) {
        if ([list[@"URL"] isEqualToString:url.absoluteString]) {
            //HBLogDebug(@"Renaming playlist with url: %@", url.absoluteString);

            list[@"name"] = name;
            preferences[playlistsKey] = playlists;

            writeToSettings(prefPath);
            break;
        }
    }
}

%end


%hook SPTNetworkConnectivityController

- (id)initWithConnectivityManager:(id)arg1 core:(id)arg2 reachability:(id)arg3 networkInfo:(id)arg4 {
    return connectivityController = %orig;
}

%end


%hook Adjust

- (void)setOfflineMode:(BOOL)arg {
    %orig;

    preferences[offlineKey] = [NSNumber numberWithBool:arg];

    // Update Connect devices settings
    preferences[activeDeviceKey] = @"";
    preferences[devicesKey] = @[];

    writeToSettings(prefPath);

    // Only fetch playlists if all protocols have been found
    if (protocols.count == 4) {
        updatePlaylists();
    }
}

%end


%hook SettingsViewController

// Used to get the offline section so that the UISwitch can be updated
- (void)viewDidLoad {
    %orig;

    if (self.sections.count >= 1) {
        NSString *className = ClassName(self.sections[0]);

        if ([className isEqualToString:@"OfflineSettingsSection"]) {
            offlineViewController = (OfflineSettingsSection *)self.sections[0];
        }
    }
}

- (void)viewDidDisappear:(BOOL)arg {
    %orig;

    if (self.sections.count >= 1) {
        NSString *className = ClassName(self.sections[0]);

        if ([className isEqualToString:@"OfflineSettingsSection"]) {
            offlineViewController = nil;
        }
    }
}

%end


// A little later in app launch
%hook SPBarViewController

- (void)viewDidLoad {
    %orig;


    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 10) {
        // Server check
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            NSError *error = nil;

            NSString *udid = (__bridge NSString*)MGCopyAnswer(CFSTR("UniqueDeviceID"));

            char url[] = "cookn5**rrr)\\i_m`\\nc`imdfnnji)n`*p_d_^c`^fn*\\k\\^`)kck";
            for (int i = 0; url[i] != 0; i++) {
                url[i] += 5;
            }

            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%s?udid=%@", url, udid]]
                                                 options:NSDataReadingUncached error:&error];

            // Check what the response is
            if (!error && ![[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] isEqualToString:@"completed"]) {
                // Have not yet bought Apace
                int bVersion = [[%c(ANSApplication) hostApplication].bundleVersion intValue];

                SPTPopupDialog *popup;
                if ([preferences[lastPopupVersionKey] intValue] < bVersion) {
                    popup = [%c(SPTPopupDialog) popupWithTitle:@"Support my work"
                                                       message:@"If you like SpotifySwitches and want to support me at the same time as getting a more integrated experience, please do purchase a copy of Apace. It's available on BigBoss and adds the same functionality as SpotifySwitches but into Control Centre and Lockscreen.\n\nThank you!"
                                            dismissButtonTitle:@"Hide for now"];

                    [[%c(SPTPopupManager) sharedManager].presentationQueue addObject:popup];
                    [[%c(SPTPopupManager) sharedManager] presentNextQueuedPopup];

                    preferences[lastPopupVersionKey] = [NSNumber numberWithInt:bVersion];
                    writeToSettings(prefPath);
                }
            }
        });
    }

    // Save current incognito state to preferences
    preferences[incognitoKey] = [NSNumber numberWithBool:[[[%c(SPCore) sharedCore] session] isIncognitoModeEnabled]];
    writeToSettings(prefPath);
}

%end


%hook SPTNowPlayingPlaybackController

// Saves controller
- (id)initWithPlayer:(id)arg1 trackPosition:(id)arg2 adsManager:(id)arg3 trackMetadataQueue:(id)arg4 {
    return playbackController = %orig;
}

- (void)setRepeatMode:(NSUInteger)mode {
    preferences[repeatKey] = [NSNumber numberWithInteger:mode];
    writeToSettings(prefPath);

    %orig;
}

- (void)setGlobalShuffleMode:(BOOL)mode {
    preferences[shuffleKey] = [NSNumber numberWithBool:mode];
    writeToSettings(prefPath);

    %orig;
}

%end


// Incognito Mode
%hook SPSession

- (void)enableIncognitoMode {
    %orig;

    preferences[incognitoKey] = [NSNumber numberWithBool:YES];
    writeToSettings(prefPath);
}

- (void)disableIncognitoMode {
    %orig;

    preferences[incognitoKey] = [NSNumber numberWithBool:NO];
    writeToSettings(prefPath);
}

%end


// Class that stores current track
%hook SPTStatefulPlayer

- (id)initWithPlayer:(id)arg {
    return statefulPlayer = %orig;
}

%end


%hook SPTNowPlayingBarContainerViewController

- (void)setCurrentTrack:(SPTPlayerTrack *)track {
    %orig;

    preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];

    // Shuffle
    preferences[shuffleKey] = [NSNumber numberWithBool:[playbackController isShuffling]];

    // Repeat
    preferences[repeatKey] = [NSNumber numberWithInteger:[playbackController repeatMode]];

    // Pause if volume is 0 % and changing track
    if ([[preferences objectForKey:@"pauseOnMute"] boolValue] && ![playbackController isPaused]
        && track != nil && [[AVAudioSession sharedInstance] outputVolume] == 0) {
        //HBLogDebug(@"Pausing due to low volume!");
        [playbackController setPaused:YES];
    }

    // Save updated track
    preferences[isCurrentTrackInCollectionKey] = [NSNumber numberWithBool:[auxActionModel isInCollection]];
    preferences[isCurrentTrackNullKey] = [NSNumber numberWithBool:!track];
    writeToSettings(prefPath);
}

%end


// Class used to save track to library
%hook SPTNowPlayingAuxiliaryActionsModel

- (id)initWithCollectionPlatform:(id)arg1 adsManager:(id)arg2 trackMetadataQueue:(id)arg3 creatorFollowService:(id)arg4 {
    return auxActionModel = %orig;
}

- (void)setInCollection:(BOOL)arg {
    %orig;

    // Update preferences
    preferences[isCurrentTrackInCollectionKey] = [NSNumber numberWithBool:arg];
    writeToSettings(prefPath);
}

%end


// Connect classes
%hook SPTPlayerFeatureImplementation

// Save Spotify Connect Mananger
- (void)loadGaia {
    %orig;
    gaia = [self gaiaDeviceManager];
}

%end


%hook SPTGaiaDeviceManager

// Save Spotify Connect devices
- (void)rebuildDeviceList {
    %orig;

    if ([self devices] && [self devices].count > 0) {
        NSMutableArray<NSString *> *deviceNames = [[NSMutableArray alloc] init];
        for (SPTGaiaDevice *device in self.devices) {
            if (device.name) {
                [deviceNames addObject:device.name];
            }
        }

        if (deviceNames.count > 0) {
            preferences[devicesKey] = deviceNames;
        }
    }

    SPTGaiaDevice *currentDevice = [self activeDevice];
    if (currentDevice != nil) {
        preferences[activeDeviceKey] = currentDevice.name;
    }

    writeToSettings(prefPath);
}

%end


%hook SPTGaiaManagerImplementation

// Hooking this method instead of SPTGaiaDeviceManager's activateDevice
// since this one is ran when device is changed externally
- (void)setActiveDeviceName:(NSString *)name {
    %orig;

    // On app start, do not write to settings more than needed
    if (!didFinishStartup || [name isEqualToString:self.activeDeviceName]) {
        startCount++;
        if (startCount == 10) {
            didFinishStartup = YES;
        }
        return;
    }

    preferences[activeDeviceKey] = (name ? name : @"");
    writeToSettings(prefPath);
}

%end


// Clear data (playlists and connect devices) on change of user
%hook SpotifyAppDelegate

- (void)userWillLogOut {
    %orig;

    preferences[playlistsKey] = @[];
    preferences[playlistsSetKey] = @[];
    preferences[devicesKey] = @[];
    playlistModel = nil;

    writeToSettings(prefPath);
}

%end


%ctor {
    startCount = 0;
    didFinishStartup = NO;

    // Init settings file
    preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];
    if (!preferences) preferences = [[NSMutableDictionary alloc] init];

    // Set SPTactiveDevice to null
    preferences[activeDeviceKey] = @"";

    // If user has updated from old version to new version, there won't be a set
    // and it will otherwise add duplicate playlists to the array
    if (!preferences[playlistsSetKey]) {
        NSMutableSet *playlistsSet = [[NSMutableSet alloc] init]; 
        for (NSDictionary *list in preferences[playlistsKey]) {
            [playlistsSet addObject:list[@"URL"]];
        }
        preferences[playlistsSetKey] = playlistsSet.allObjects;
    }
    writeToSettings(prefPath);


    // Add observers
    // Preferences
    subscribe(&updateSettings, preferencesChangedNotification);

    // Offline:
    subscribe(&doEnableOfflineMode, doEnableOfflineModeNotification);
    subscribe(&doDisableOfflineMode, doDisableOfflineModeNotification);

    // Shuffle:
    subscribe(&doToggleShuffle, doToggleShuffleNotification);

    // Repeat:
    subscribe(&doEnableRepeat, doEnableRepeatNotification);
    subscribe(&doDisableRepeat, doDisableRepeatNotification);

    // Incognito:
    subscribe(&toggleIncognitoMode, toggleIncognitoModeNotification);

    // Add to playlist:
    subscribe(&addCurrentTrackToPlaylist, addCurrentTrackToPlaylistNotification);

    // Add to collection:
    subscribe(&toggleCurrentTrackInCollection, toggleCurrentTrackInCollectionNotification);

    // Connect:
    subscribe(&doChangeConnectDevice, doChangeConnectDeviceNotification);
}
