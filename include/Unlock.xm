#import "Unlock.h"
#import "Common.h"
#import <UIKit/UIApplication2.h>

// Execute action after unlock (if locked, that is)
static id lockscreenContext = nil;

void launchSpotifyWithUnlock() {
    SBLockScreenManager *manager = (SBLockScreenManager *)[%c(SBLockScreenManager) sharedInstance];
    SBLockScreenViewControllerBase *controller = [manager lockScreenViewController];

    void (^action)() = ^() {
        // Uncomment if you need to wait for the unlock animation to finish
        //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1. * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [[%c(UIApplication) sharedApplication] launchApplicationWithIdentifier:spotifyBundleIdentifier suspended:NO];
        //});
    };
    
    // Check if device is locked
    if ([manager isUILocked]) {
        if (kCFCoreFoundationVersionNumber > 900.00) { // iOS 8+
            lockscreenContext = [[%c(SBLockScreenActionContext) alloc] initWithLockLabel:nil shortLockLabel:nil action:action identifier:nil];
            [controller setCustomLockScreenActionContext:lockscreenContext];
        } else {
            lockscreenContext = [[%c(SBUnlockActionContext) alloc] initWithLockLabel:nil shortLockLabel:nil unlockAction:action identifier:nil];
            [controller setCustomUnlockActionContext:lockscreenContext];
        }
        
        if (kCFCoreFoundationVersionNumber >= 1348.0) { // iOS 10+
            // Check if the passcode is set
            if (![controller isAuthenticated]) {
                [lockscreenContext setDeactivateAwayController:YES];
                [controller setPasscodeLockVisible:YES animated:YES completion:nil];
                return;
            } else {
                [manager attemptUnlockWithMesa];
                return;
            }
        } else {
            [lockscreenContext setDeactivateAwayController:YES];
            
            // Check if the passcode is set
            if ([[%c(SBDeviceLockController) sharedController] isPasscodeLocked]) {
                [controller setPasscodeLockVisible:YES animated:YES completion:nil];
                return;
            } else {
                [controller attemptToUnlockUIFromNotification];
                return;
            }
        }
    } else {
        [[%c(UIApplication) sharedApplication] launchApplicationWithIdentifier:spotifyBundleIdentifier suspended:NO];
    }
}

// This part is only needed on iOS 10
%group iOS10
%hook SBLockScreenManager

- (void)setPasscodeVisible:(BOOL)arg1 animated:(BOOL)arg2 {
    %orig;

    if (!arg1 && !self.lockScreenViewController.isAuthenticated &&
       [self.lockScreenViewController._customLockScreenActionContext isEqual:lockscreenContext]) {
        HBLogInfo(@"User canceled passcode prompt. Cancelling Action");
        [self.lockScreenViewController setCustomLockScreenActionContext:nil];
    }
}

%end
%end


%ctor {
    %init;
    if (kCFCoreFoundationVersionNumber >= 1348.0)
        %init(iOS10);
}
