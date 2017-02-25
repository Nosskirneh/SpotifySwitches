#import "include/Header.h"

SPCore *core;
SPSession *session;
SPTNowPlayingPlaybackController *playbackController;
SettingsViewController *offlineViewController;
BOOL isCurrentViewOfflineView;

// What should happen on triggered flipswitch event?
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

void doToggleShuffle(CFNotificationCenterRef center,
                     void *observer,
                     CFStringRef name,
                     const void *object,
                     CFDictionaryRef userInfo) {
    
    // Update setting
    preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];
    BOOL next = ![[preferences objectForKey:shuffleKey] boolValue];
    
    [playbackController setGlobalShuffleMode:next];
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


// Has property isOffline and isOnline. Used setting start values.
%hook SPSession

- (id)initWithCore:(id)arg1 coreCreateOptions:(id)arg2 session:(id)arg3 clientVersionString:(id)arg4 acceptLanguages:(id)arg5 {
    return session = %orig;
}

%end


%hook SPBarViewController

- (void)viewDidLoad {
    %orig;

    // Set default values for flipswitches
    if (session.isOffline) {
        [preferences setObject:[NSNumber numberWithBool:YES] forKey:offlineKey];
        [preferences setObject:[NSNumber numberWithBool:NO] forKey:shuffleKey];

    } else {
        [preferences setObject:[NSNumber numberWithBool:YES] forKey:offlineKey];
        
    }
    
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

