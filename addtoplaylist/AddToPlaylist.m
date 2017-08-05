#import "AddToPlaylist.h"

static id lockscreenContext = nil;

void checkLocked() {
    SBLockScreenManager *manager = (SBLockScreenManager *)[objc_getClass("SBLockScreenManager") sharedInstance];
    SBLockScreenViewControllerBase *controller = [(SBLockScreenManager *)[objc_getClass("SBLockScreenManager") sharedInstance] lockScreenViewController];

    void (^action)() = ^() {
        //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1. * NSEC_PER_SEC), dispatch_get_main_queue(), ^{ // Uncomment if you need to wait for the unlock animation to finish
        [[%c(UIApplication) sharedApplication] launchApplicationWithIdentifier:spotifyBundleIdentifier suspended:NO];
        //});
    };

    if ([manager isUILocked]) { // Check if device is locked
        
        if (kCFCoreFoundationVersionNumber > 900.00) { // iOS 8+
            lockscreenContext = [[objc_getClass("SBLockScreenActionContext") alloc] initWithLockLabel:nil shortLockLabel:nil action:action identifier:nil];
            [controller setCustomLockScreenActionContext:lockscreenContext];
        } else {
            lockscreenContext = [[objc_getClass("SBUnlockActionContext") alloc] initWithLockLabel:nil shortLockLabel:nil unlockAction:action identifier:nil];
            [controller setCustomUnlockActionContext:lockscreenContext];
        }

        if (kCFCoreFoundationVersionNumber >= 1348.0) { // iOS 10+
            if (![controller isAuthenticated]) { // Check if the passcode is set
                [lockscreenContext setDeactivateAwayController:YES];
                [controller setPasscodeLockVisible:YES animated:YES completion:nil];
                return;
            } else {
                [manager attemptUnlockWithMesa];
                return;
            }
        } else {
            [lockscreenContext setDeactivateAwayController:YES];
            
            if ([[objc_getClass("SBDeviceLockController") sharedController] isPasscodeLocked]) { // Check if the passcode is set
                [controller setPasscodeLockVisible:YES animated:YES completion:nil];
                return;
            } else {
                [controller attemptToUnlockUIFromNotification];
                return;
            }
        }
    }
   	else {
        [[%c(UIApplication) sharedApplication] launchApplicationWithIdentifier:spotifyBundleIdentifier suspended:NO];
   	}
}

%hook SBLockScreenManager // This part is only needed on iOS10

- (void)setPasscodeVisible:(BOOL)arg1 animated:(BOOL)arg2 {
    %orig;

    if(kCFCoreFoundationVersionNumber >= 1348.0 && !arg1 && !self.lockScreenViewController.isAuthenticated &&
       [self.lockScreenViewController._customLockScreenActionContext isEqual:lockscreenContext]) {
        HBLogInfo(@"User canceled passcode prompt. Cancelling Action");
        [self.lockScreenViewController setCustomLockScreenActionContext:nil];
    }
}

%end



@implementation AddToPlaylist

+ (void)load {
    if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"])
        [(LAActivator *)[%c(LAActivator) sharedInstance] registerListener:[self new] forName:@"se.nosskirneh.addtoplaylist"];
}

// Called when the user-defined action is recognized, shows selection alert
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
    [event setHandled:YES];
    
    UIAlertController *playlistAlert = [UIAlertController
                                        alertControllerWithTitle:@"Add to Playlist"
                                        message:@"Add current track to which playlist?"
                                        preferredStyle:UIAlertControllerStyleActionSheet
                                        ];
    
    SBApplication* app = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:spotifyBundleIdentifier];
    
    if ([app pid] >= 0) { // Spotify is running
        // Update preferences
        self.preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];
        
        if ([[self.preferences objectForKey:isCurrentTrackNullKey] boolValue]) {
            // Not listening to music
            UIAlertAction *launchAppAction = [self createLaunchAppAction:@"Play some music"];
            [playlistAlert addAction:launchAppAction];
        } else {
            
            // Has user specified playlist in Preferences?
            NSString *specifiedPlaylistName = self.preferences[specifiedPlaylistNameKey];
            if (specifiedPlaylistName != nil && ![specifiedPlaylistName isEqualToString:@""]) {
                HBLogDebug(@"Found non-empty specified playlist!");
                
                notify(addCurrentTrackToPlaylistNotification);
                return;
            }
            
            NSArray *playlists = [self.preferences objectForKey:playlistsKey];
            
            UIAlertAction *playlistAction;
            for (int i = 0; i < playlists.count; i++) {
                playlistAction = [UIAlertAction
                                  actionWithTitle:[playlists[i] objectForKey:@"name"]
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action) {
                                      [self clickedPlaylistAtIndex:i];
                                  }];
                [playlistAlert addAction:playlistAction];
            }
        }
        
    } else {
        UIAlertAction *launchAppAction = [self createLaunchAppAction:@"Launch Spotify"];
        [playlistAlert addAction:launchAppAction];
    }
    
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * action) {
                                 [playlistAlert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [playlistAlert addAction:cancel];
    [playlistAlert show];
}

- (UIAlertAction *)createLaunchAppAction:(NSString *)title {
    return [UIAlertAction
            actionWithTitle:title
            style:UIAlertActionStyleDestructive
            handler:^(UIAlertAction *action) {
                //[[%c(UIApplication) sharedApplication] launchApplicationWithIdentifier:spotifyBundleIdentifier suspended:NO];
                checkLocked();
            }];
}

- (void)clickedPlaylistAtIndex:(NSInteger)index {
    self.preferences[playlistIndexKey] = [NSNumber numberWithInteger:index];

    if (![self.preferences writeToFile:prefPath atomically:YES]) {
        HBLogError(@"Could not save preferences!");
    } else {
        // Send notification that device was changed
        notify(addCurrentTrackToPlaylistNotification);
    }
}

@end
