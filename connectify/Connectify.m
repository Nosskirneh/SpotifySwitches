#import "Connectify.h"

static id lockscreenContext = nil;

%group main

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

-(void)setPasscodeVisible:(BOOL)arg1 animated:(BOOL)arg2 {
    %orig;
    if(kCFCoreFoundationVersionNumber >= 1348.0 && !arg1 && !self.lockScreenViewController.isAuthenticated && [self.lockScreenViewController._customLockScreenActionContext isEqual:lockscreenContext]) {
        HBLogInfo(@"User canceled passcode prompt. Cancelling Action");
        [self.lockScreenViewController setCustomLockScreenActionContext:nil];
    }
}

%end


%end


%ctor {
    @autoreleasepool {
        %init(main);
    }
}



@implementation Connectify

NSString *activeDevice;

+ (void)load {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"])
        [(LAActivator *)[%c(LAActivator) sharedInstance] registerListener:[self new] forName:@"se.nosskirneh.connectify"];
    [pool release];
}

- (id)init {
    self = [super init];

    // Init settings file
    preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];
    if (!preferences) preferences = [[NSMutableDictionary alloc] init];
    
    return self;
}

- (UIAlertAction *)createConnectDeviceAction:(NSString *)title atIndex:(NSInteger)index {
    return [UIAlertAction
            actionWithTitle:title
            style:UIAlertActionStyleDefault
            handler:^(UIAlertAction *action) {
                [self clickedDeviceAtIndex:index];
            }];
}

// Called when the user-defined action is recognized, shows selection sheet
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
    [event setHandled:YES];
    [self connectStartNotificationReceived:nil];
}

- (void)connectStartNotificationReceived:(NSNotification *)notification {
    UIAlertController *connectAlert = [UIAlertController
                                        alertControllerWithTitle:@"Connectify"
                                        message:@"Change Spotify Connect device"
                                        preferredStyle:UIAlertControllerStyleActionSheet
                                        ];

    SBApplication* app = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:spotifyBundleIdentifier];
    
    if ([app pid] >= 0) { // Spotify is running
        // Update preferences
        preferences  = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];
        bool offline = [[preferences objectForKey:offlineKey] boolValue];

        if (offline) {
            UIAlertAction *goOnlineAction = [UIAlertAction
                                              actionWithTitle:@"Go online"
                                              style:UIAlertActionStyleDestructive
                                              handler:^(UIAlertAction *action) {
                                                  HBLogDebug(@"Trying to go online");
                                                  CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)doDisableOfflineModeNotification, NULL, NULL, YES);
                                              }];
            
            [connectAlert addAction:goOnlineAction];
        }

        deviceNames  = [preferences objectForKey:devicesKey];
        activeDevice = [preferences objectForKey:activeDeviceKey];
        
        for (int i = 0; i < deviceNames.count; i++) {
            UIAlertAction *deviceAction;
            if ([activeDevice isEqualToString:deviceNames[i]]) {
                deviceAction = [self createConnectDeviceAction:[@"●  " stringByAppendingString:deviceNames[i]] atIndex:i];
            } else {
                deviceAction = [self createConnectDeviceAction:deviceNames[i] atIndex:i];
            }
            [connectAlert addAction:deviceAction];
        }
    } else {
        UIAlertAction *launchAppAction = [UIAlertAction
                                         actionWithTitle:@"Launch Spotify"
                                         style:UIAlertActionStyleDestructive
                                         handler:^(UIAlertAction *action) {
                                             HBLogDebug(@"Trying to launch Spotify...");
                                             checkLocked();
                                         }];
        
        [connectAlert addAction:launchAppAction];
    }

    
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * action)
                             {
                                 [connectAlert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [connectAlert addAction:cancel];
    [connectAlert show];
}

- (void)clickedDeviceAtIndex:(NSInteger)index {
    NSString *selectedDeviceName = deviceNames[index];
    
    if ([activeDevice isEqualToString:selectedDeviceName]) {
        HBLogDebug(@"Trying to disconnected from: %@", selectedDeviceName);
        [preferences setObject:@"" forKey:activeDeviceKey];
    } else {
        HBLogDebug(@"Trying to connect to: %@", selectedDeviceName);
        [preferences setObject:selectedDeviceName forKey:activeDeviceKey];
    }
    
    // Save to .plist
    if (![preferences writeToFile:prefPath atomically:YES]) {
        HBLogError(@"Could not save preferences!");
    } else {
        // Send notification that device was changed
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)doChangeConnectDeviceNotification, NULL, NULL, YES);
    }
}

- (void)dealloc {
    [deviceNames release];
    
    [super dealloc];
}

@end
