#import "Header.h"


static SPCore *core;
static BOOL isCurrentViewOfflineView;

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
//    NSNumber *n = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"enabled" inDomain:nsDomainString];
//    HBLogDebug(@"%@", n); // always null
}

// Below should work, but doens't?
//static NSString *nsNotificationString = @"se.nosskirneh.sos/preferences.changed";
//
//void offlineModeChanged(CFNotificationCenterRef center,
//                        void *observer,
//                        CFStringRef name,
//                        const void *object,
//                        CFDictionaryRef userInfo) {
//    NSNumber *n = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"enabled" inDomain:nsDomainString];
//    BOOL enabled = (n)? [n boolValue]:YES;
//    [core setForcedOffline:enabled];
//}



%hook SPCore

- (id)init {
    HBLogDebug(@"Found SPCore");
    
    // Add observers
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &goOffline, CFStringRef(onlineNotification), NULL, 0);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &goOnline, CFStringRef(offlineNotification), NULL, 0);
    //CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &offlineModeChanged, CFStringRef(nsNotificationString), NULL, 0);
    
    // Save core
    return core = %orig;
}

- (void)setForcedOffline:(BOOL)arg {
    // Save arg to [NSUserDefaults standardUserDefaults] here...
    if (!isCurrentViewOfflineView) {
        return %orig;
    }
    return;
}

%end


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


// Reset state after going back from "Playback" setting view
%hook SPNavigationController

- (void)viewWillLayoutSubviews {
    %orig;
    isCurrentViewOfflineView = NO;
}

%end

