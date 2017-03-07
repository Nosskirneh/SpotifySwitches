#import "include/Header.h"

// Connect
SPTGaiaDeviceManager *gaia;

// Shuffle and repeat
SPTNowPlayingPlaybackController *playbackController;

// Offline toggle
SPCore *core;
SettingsViewController *offlineViewController;
BOOL isCurrentViewOfflineView;

// Save to playlist/collection
SPTStatefulPlayer *statefulPlayer;
SPPlaylistContainer *playlistContainer;
SPPlaylistContainerCallbacksHolder *callbacksHolder;
SPTNowPlayingAuxiliaryActionsModel *auxActionModel;

// Notifications methods
// Offline
void doEnableOfflineMode(CFNotificationCenterRef center,
                     void *observer,
                     CFStringRef name,
                     const void *object,
                     CFDictionaryRef userInfo) {
    
    [core setForcedOffline:YES];
}

void doDisableOfflineMode(CFNotificationCenterRef center,
                         void *observer,
                         CFStringRef name,
                         const void *object,
                         CFDictionaryRef userInfo) {
    
    [core setForcedOffline:NO];
}

// Shuffle
void doToggleShuffle(CFNotificationCenterRef center,
                     void *observer,
                     CFStringRef name,
                     const void *object,
                     CFDictionaryRef userInfo) {
    
    // Update state
    preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];
    BOOL next = ![[preferences objectForKey:shuffleKey] boolValue];
    [playbackController setGlobalShuffleMode:next];
}

// Repeat
void doEnableRepeat(CFNotificationCenterRef center,
                     void *observer,
                     CFStringRef name,
                     const void *object,
                     CFDictionaryRef userInfo) {
    [playbackController setRepeatMode:2];
}

void doDisableRepeat(CFNotificationCenterRef center,
                    void *observer,
                    CFStringRef name,
                    const void *object,
                    CFDictionaryRef userInfo) {
    [playbackController setRepeatMode:0];
}

// Connect
void doChangeConnectDevice(CFNotificationCenterRef center,
                           void *observer,
                           CFStringRef name,
                           const void *object,
                           CFDictionaryRef userInfo) {
    // Update device
    preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];
    NSString *deviceName = [preferences objectForKey:activeDeviceKey];

    for (SPTGaiaDevice *device in [gaia devices]) {
        if ([device.name isEqualToString:deviceName]) {
            [gaia activateDevice:device withCallback:nil];
            HBLogDebug(@"Sending device %@ to Gaia", device);
            return;
        }
    }

     // No matching names
     HBLogDebug(@"Found no matching device names, disconnecting");
     [gaia activateDevice:nil withCallback:nil];
}

// Add to playlist
void addCurrentTrackToPlaylist(CFNotificationCenterRef center,
                           void *observer,
                           CFStringRef name,
                           const void *object,
                           CFDictionaryRef userInfo) {
    // Update chosen playlist
    preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];
    NSString *chosenPlaylist = [preferences objectForKey:chosenPlaylistKey];

    for (SPPlaylist *playlist in playlistContainer.actualPlaylists) {
        if ([playlist.name isEqualToString:chosenPlaylist]) {
            SPPlayerTrack *track = ((SPPlayerTrack *)[statefulPlayer currentTrack]);
                HBLogDebug(@"Trying to add track '%@' to playlist '%@'", track.URI, playlist.name);
                NSArray *tracks = [[NSArray alloc] initWithObjects:track.URI, nil];
                [playlist addTrackURLs:tracks];
                [tracks release];
        }
    }
}

// Add to collection
void toggleCurrentTrackInCollection(CFNotificationCenterRef center,
                               void *observer,
                               CFStringRef name,
                               const void *object,
                               CFDictionaryRef userInfo) {
    BOOL inCollection = [auxActionModel isInCollection];
    inCollection ? [auxActionModel removeFromCollection] : [auxActionModel addToCollection];
}



// Class that forces Offline Mode
%hook SPCore

- (id)init {
    // Init settings file
    preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];
    if (!preferences) preferences = [[NSMutableDictionary alloc] init];
    
    
    // Add observers
    // Offline:
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &doEnableOfflineMode, CFStringRef(doEnableOfflineModeNotification), NULL, 0);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &doDisableOfflineMode, CFStringRef(doDisableOfflineModeNotification), NULL, 0);
    
    // Shuffle:
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &doToggleShuffle, CFStringRef(doToggleShuffleNotification), NULL, 0);
        
    // Repeat:
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &doEnableRepeat, CFStringRef(doEnableRepeatNotification), NULL, 0);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &doDisableRepeat, CFStringRef(doDisableRepeatNotification), NULL, 0);
    
    // Connect:
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &doChangeConnectDevice, CFStringRef(doChangeConnectDeviceNotification), NULL, 0);
        
    // Add to playlist:
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &addCurrentTrackToPlaylist, CFStringRef(addCurrentTrackToPlaylistNotification), NULL, 0);
        
    // Add to collection:
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &toggleCurrentTrackInCollection, CFStringRef(toggleCurrentTrackInCollectionNotification), NULL, 0);
    

    // Save core
    return core = %orig;
}

- (void)setForcedOffline:(BOOL)arg {
    if (!isCurrentViewOfflineView) {
        return %orig;
    }
    // Else show alert saying why you cannot toggle in this menu
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Not allowed in this view"
                                                                             message:@"Toggling the flipswitch while here crashes Spotify. I have therefore disabled this so you can continue enjoying the music uninterrupted!"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Fine by me" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }]];
    [offlineViewController presentViewController:alertController animated:YES completion:nil];
    return;
}

%end


%hook SPBarViewController

// A little later in app launch
- (void)viewDidLoad {
    %orig;
    
    // Set activeDevice to null
    [preferences setObject:@"" forKey:activeDeviceKey];

    // Override Spotify values to current flipswitch values
    [playbackController setRepeatMode:[[preferences objectForKey:repeatKey] intValue]];
    [playbackController setGlobalShuffleMode:[[preferences objectForKey:shuffleKey] boolValue]];
    [core setForcedOffline:[[preferences objectForKey:offlineKey] boolValue]];

    // Save changes
    if (![preferences writeToFile:prefPath atomically:YES]) {
        HBLogError(@"Could not save preferences!");
    }
}

%end


BOOL didRetrievePlaylists = NO;

// A little more later in app launch
%hook SPTTabBarController

- (void)viewDidAppear:(BOOL)arg {
    %orig;

    if (!didRetrievePlaylists) { // Only retrieve playlists once
        didRetrievePlaylists = YES;
        
        // Retrieve playlists
        [callbacksHolder retrievePlaylists];
    }
}

%end



%hook SPTNowPlayingPlaybackController

// Saves controller
- (id)initWithPlayer:(id)arg1 trackPosition:(id)arg2 adsManager:(id)arg3 trackMetadataQueue:(id)arg4 {
    return playbackController = %orig;
}

// Method that changes repeat mode
- (void)setRepeatMode:(NSUInteger)value {
    %orig;

    // Update value
    [preferences setObject:[NSNumber numberWithInteger:value] forKey:repeatKey];
    if (![preferences writeToFile:prefPath atomically:YES]) {
        HBLogError(@"Could not save preferences!");
    }
}

%end



%hook SettingsViewController

// Prevents crash at Offline view in Settings
- (void)viewDidLayoutSubviews {
    %orig;
    if (self.sections.count >= 1) {
        NSString *className = NSStringFromClass([self.sections[1] class]);
        
        // Is current SettingsViewController the one with offline settings?
        // in that case, set isCurrentViewOFflineView to YES so that we
        // cannot toggle offline mode - Spotify will then crash!
        if ([className isEqualToString:@"OfflineSettingsSection"]) {
            offlineViewController = self;
            isCurrentViewOfflineView = YES;
        }
    }
}

%end


%hook SPNavigationController

// Reset state after going back from "Playback" setting view
- (void)viewWillLayoutSubviews {
    %orig;
    offlineViewController = nil;
    isCurrentViewOfflineView = NO;
}

%end


%hook Adjust

// Saves updated Offline Mode value (both through flipswitch and manually)
- (void)setOfflineMode:(BOOL)arg {
    %orig;

    // Update flipswitch state
    [preferences setObject:[NSNumber numberWithBool:arg] forKey:offlineKey];
    // Update Connectify settings
    [preferences setObject:@"" forKey:activeDeviceKey];
    [preferences setObject:@[] forKey:devicesKey];
    
    if (![preferences writeToFile:prefPath atomically:YES]) {
        HBLogError(@"Could not save preferences!");
    }
}

%end


%hook SPTNowPlayingMusicHeadUnitViewController

// Saves updated shuffle value
- (void)shuffleButtonPressed:(id)arg {
    %orig;
    BOOL current = [[preferences objectForKey:shuffleKey] boolValue];
    [preferences setObject:[NSNumber numberWithBool:current] forKey:shuffleKey];
    
    if (![preferences writeToFile:prefPath atomically:YES]) {
        HBLogError(@"Could not save preferences!");
    }

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
    if ([[self devices] count] > 0) {
        deviceNames = [[NSMutableArray alloc] init];
        for (SPTGaiaDevice *device in self.devices) {
            [deviceNames addObject:device.name];
        }
        [preferences setObject:deviceNames forKey:devicesKey];
        [deviceNames release];
    }

    SPTGaiaDevice *currentDevice = [self activeDevice];
    if (currentDevice != nil) {
        [preferences setObject:currentDevice.name forKey:activeDeviceKey];
    }
    
    // Save to .plist    
    if (![preferences writeToFile:prefPath atomically:YES]) {
        HBLogError(@"Could not save preferences!");
    }
}

// Method that changes Connect device
- (void)activateDevice:(SPTGaiaDevice *)device withCallback:(id)arg {
    %orig;
    if (device != nil) {
        [preferences setObject:device.name forKey:activeDeviceKey];
    } else {
        [preferences setObject:@"" forKey:activeDeviceKey];
    }

    // Save to .plist
    if (![preferences writeToFile:prefPath atomically:YES]) {
        HBLogError(@"Could not save preferences!");
    }
}

%end



// Add to playlist

BOOL didRetrieveCallbacksHolder = NO;

%hook SPPlaylistContainerCallbacksHolder

- (id)initWithObjc:(id)arg {
    if (!didRetrieveCallbacksHolder) {
        didRetrieveCallbacksHolder = YES;
        return callbacksHolder = %orig;
    }
    
    return %orig;
}

%new
- (void)retrievePlaylists {
    playlistContainer = [self playlists];
    playlists = [[NSMutableArray alloc] init];

    for (SPPlaylist *list in playlistContainer.actualPlaylists) {
        if (list.isWriteable && ![list.name isEqualToString:@""]) {
            playlist = [[NSMutableDictionary alloc] init];
            [playlist setObject:[list.URL absoluteString] forKey:@"URL"];
            [playlist setObject:list.name forKey:@"name"];
            [playlists addObject:playlist];
        }
    }
    
    // Save playlists to plist in order to share with SpringBoard
    [preferences setObject:playlists forKey:playlistsKey];
    [playlists release];
    [playlist release];
    
    if (![preferences writeToFile:prefPath atomically:YES]) {
        HBLogError(@"Could not save preferences!");
    }
}

%end


%hook SPTPlaylistCosmosModel

// Fortunately the URL is given, so we can match it against the smaller array
// and remove the matching playlist.
- (void)removePlaylistOrFolderURL:(id)url inFolderURL:(id)arg2 completion:(id)arg3 {
    %orig;
    HBLogDebug(@"Trying to remove playlist with url: %@", url);
    
    playlists = [preferences objectForKey:playlistsKey];
    for (int i = 0; i < playlists.count; i++) {
        NSMutableDictionary *playlist = [playlists objectAtIndex:i];
        if ([[playlist objectForKey:@"URL"] isEqualToString:[url absoluteString]]) {
            [playlists removeObjectAtIndex:i];
            HBLogDebug(@"Removed a playlist!");
        }
    }
}

%end


// Update playlists list on change of "Recently Played" section
%hook SPTRecentlyPlayedEntityList

- (void)recentlyPlayedModelDidReload:(id)arg {
    %orig;
    // Update playlists
    [callbacksHolder retrievePlaylists];
}

%end


// Class that stores current track
%hook SPTStatefulPlayer

- (id)initWithPlayer:(id)arg {
    return statefulPlayer = %orig;
}

%end


// Save updated track
%hook SPTNowPlayingBarModel

- (void)setCurrentTrackURL:(SPPlayerTrack *)track {
    %orig;
    
    [preferences setObject:[NSNumber numberWithBool:[auxActionModel isInCollection]] forKey:isCurrentTrackInCollectionKey];
    [preferences setObject:[NSNumber numberWithBool:!track] forKey:isCurrentTrackNullKey];
    
    if (![preferences writeToFile:prefPath atomically:YES]) {
        HBLogError(@"Could not save preferences!");
    }
}

%end


// Class used to save track to library
%hook SPTNowPlayingAuxiliaryActionsModel

- (id)initWithCollectionPlatform:(id)arg1 adsManager:(id)arg2 trackMetadataQueue:(id)arg3 showsFollowService:(id)arg4 {
    return auxActionModel = %orig;
}

- (void)setInCollection:(BOOL)arg {
    %orig;
    // Update preferences
    [preferences setObject:[NSNumber numberWithBool:arg] forKey:isCurrentTrackInCollectionKey];
        if (![preferences writeToFile:prefPath atomically:YES]) {
            HBLogError(@"Could not save preferences!");
        }
}

%end
