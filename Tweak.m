#import "include/Header.h"

SPCore *core;
SPTNowPlayingPlaybackController *playbackController;
BOOL isCurrentViewOfflineView;

// What happens when a notification from flipswitch was recieved?
void goOnline(CFNotificationCenterRef center,
                    void *observer,
                    CFStringRef name,
                    const void *object,
                    CFDictionaryRef userInfo) {
    [core setForcedOffline:NO];
}

void goOffline(CFNotificationCenterRef center,
              void *observer,
              CFStringRef name,
              const void *object,
              CFDictionaryRef userInfo) {
    [core setForcedOffline:YES];
}

//void offlineModeChanged(CFNotificationCenterRef center,
//                        void *observer,
//                        CFStringRef name,
//                        const void *object,
//                        CFDictionaryRef userInfo) {
//    //BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:offlineModeKey];
//    
//    [userDefaults synchronize];
//    BOOL enabled = [userDefaults boolForKey:offlineModeKey];
//    
//    HBLogDebug(@"enabled flag: %d", enabled);
//    [core setForcedOffline:enabled];
//}
//
// The code above doesn't work since they don't share the same NSUserDefaults.
// I have also tried with `CFPreferencesSetAppValue` as
// https://github.com/PoomSmart/Spotlight-Flipswitch but without results.
// I also tried creating a `settings = [NSMutableDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", nsDomainString]];`
// in here and read from the same file as `Switch.xm`.
// That didn't either work since unlike the file, the dict was never updated.
//

void shuffleOn(CFNotificationCenterRef center,
              void *observer,
              CFStringRef name,
              const void *object,
              CFDictionaryRef userInfo) {
    [playbackController setGlobalShuffleMode:YES];
}

void shuffleOff(CFNotificationCenterRef center,
               void *observer,
               CFStringRef name,
               const void *object,
               CFDictionaryRef userInfo) {
    [playbackController setGlobalShuffleMode:NO];
}


// Class that forces Offline Mode
%hook SPCore

- (id)init {
    // Add observers
    // Offline:
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &goOffline, CFStringRef(onlineNotification), NULL, 0);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &goOnline, CFStringRef(offlineNotification), NULL, 0);
    //CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &offlineModeChanged, CFStringRef(offlineModeChanged), NULL, 0);
    
    // Shuffle:
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &shuffleOn, CFStringRef(shuffleOnNotification), NULL, 0);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &shuffleOff, CFStringRef(shuffleOffNotification), NULL, 0);
    //CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &shuffleChanged, CFStringRef(shuffleChanged), NULL, 0);
    
    // Save core
    return core = %orig;
}

- (void)setForcedOffline:(BOOL)arg {
    if (!isCurrentViewOfflineView) {
        return %orig;
    }
    return;
}

%end



%hook SPTNowPlayingPlaybackController

- (id)initWithPlayer:(id)arg1 trackPosition:(id)arg2 adsManager:(id)arg3 trackMetadataQueue:(id)arg4 {
    HBLogDebug(@"Found Playback Controller!");
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
            isCurrentViewOfflineView = YES;
        }
    }
}

%end


// Saves updated Offline Mode value (both through flipswitch and manually)
//%hook Adjust // Use this when you've solved the the shared settings problem.
//
//- (void)setOfflineMode:(BOOL)arg {
//    // Save value to NSUSerDefaults here
//    %orig;
//}
//
//%end


// Reset state after going back from "Playback" setting view
%hook SPNavigationController

- (void)viewWillLayoutSubviews {
    %orig;
    isCurrentViewOfflineView = NO;
}

%end

