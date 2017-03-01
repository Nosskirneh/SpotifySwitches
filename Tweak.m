#import "include/Header.h"

SPCore *core;
SPSession *session;
SPTNowPlayingPlaybackController *playbackController;
SPTGaiaDeviceManager *gaia;
SettingsViewController *offlineViewController;
BOOL isCurrentViewOfflineView;

// What should happen on triggered flipswitch event?
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


void doChangeConnectDevice(CFNotificationCenterRef center,
                           void *observer,
                           CFStringRef name,
                           const void *object,
                           CFDictionaryRef userInfo) {
    // Update device
    preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];
    NSString *deviceName = [preferences objectForKey:activeDeviceKey];
    SPTGaiaDevice *device;
    for (device in [gaia devices]) {
        if ([device.name isEqualToString:deviceName]) {
            [gaia activateDevice:device withCallback:nil];
            HBLogDebug(@"Sending device %@ to Gaia", device);
            return;
        }
    }

     // No matching names,
     HBLogDebug(@"Found no matching device names, disconnecting");
     [gaia activateDevice:nil withCallback:nil];
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


// Has propertes isOffline and isOnline. Used to set start values.
%hook SPSession

- (id)initWithCore:(id)arg1 coreCreateOptions:(id)arg2 session:(id)arg3 clientVersionString:(id)arg4 acceptLanguages:(id)arg5 {
    return session = %orig;
}

%end


%hook SPBarViewController

- (void)viewDidLoad {
    %orig;

    // Set default values on app launch
    // Perhaps add settings pane to determine which one should be used.
    // Simply update flipswitch values to Spotify defaults
//    if (session.isOffline) {
//        [preferences setObject:[NSNumber numberWithBool:YES] forKey:offlineKey];
//        [preferences setObject:[NSNumber numberWithBool:NO] forKey:shuffleKey];
//
//    } else {
//        [preferences setObject:[NSNumber numberWithBool:YES] forKey:offlineKey];
//        
//    }
    
    // Set activeDevice to null
    [preferences setObject:@"" forKey:activeDeviceKey];
    
    // Override Spotify values to current flipswitch values
    [playbackController setRepeatMode:[[preferences objectForKey:repeatKey] intValue]];
    [playbackController setGlobalShuffleMode:[[preferences objectForKey:shuffleKey] boolValue]];
    
    // Save changes
    if (![preferences writeToFile:prefPath atomically:YES]) {
        HBLogError(@"Could not save preferences!");
    }
}

%end



%hook SPTNowPlayingPlaybackController

- (id)initWithPlayer:(id)arg1 trackPosition:(id)arg2 adsManager:(id)arg3 trackMetadataQueue:(id)arg4 {
    return playbackController = %orig;
}

- (void)setRepeatMode:(NSUInteger)value {
    %orig;

    // Update value
    [preferences setObject:[NSNumber numberWithInteger:value] forKey:repeatKey];
    if (![preferences writeToFile:prefPath atomically:YES]) {
        HBLogError(@"Could not save preferences!");
    }
}

%end



// Prevents crash
%hook SettingsViewController

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


// Reset state after going back from "Playback" setting view
%hook SPNavigationController

- (void)viewWillLayoutSubviews {
    %orig;
    offlineViewController = nil;
    isCurrentViewOfflineView = NO;
}

%end


// Saves updated Offline Mode value (both through flipswitch and manually)
%hook Adjust

- (void)setOfflineMode:(BOOL)arg {
    [preferences setObject:[NSNumber numberWithBool:arg] forKey:offlineKey];
    
    if (![preferences writeToFile:prefPath atomically:YES]) {
        HBLogError(@"Could not save preferences!");
    }

    %orig;
}

%end


// Saves updated shuffle value
%hook SPTNowPlayingMusicHeadUnitViewController

- (void)shuffleButtonPressed:(id)arg {
    %orig;
    BOOL current = [[preferences objectForKey:shuffleKey] boolValue];
    [preferences setObject:[NSNumber numberWithBool:current] forKey:shuffleKey];
    
    if (![preferences writeToFile:prefPath atomically:YES]) {
        HBLogError(@"Could not save preferences!");
    }

}

%end





// Save Spotify Connect devices

%hook SPTPlayerFeatureImplementation

- (void)loadGaia {
    %orig;
    gaia = [self gaiaDeviceManager];
}
               
%end


%hook SPTGaiaDeviceManager

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

- (void)activateDevice:(SPTGaiaDevice *)device withCallback:(id)arg {
    %orig;
    HBLogDebug(@"Device was changed");
    if (device != nil) {
        [preferences setObject:device.name forKey:activeDeviceKey];
    } else {
        [preferences setObject:@"nil" forKey:activeDeviceKey];
    }

    // Save to .plist
    if (![preferences writeToFile:prefPath atomically:YES]) {
        HBLogError(@"Could not save preferences!");
    }
}

%end
