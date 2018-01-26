#import "Connectify.h"

@implementation Connectify

+ (void)load {
    if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"])
        [(LAActivator *)[%c(LAActivator) sharedInstance] registerListener:[self new] forName:@"se.nosskirneh.connectify"];
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
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Connectify"
                                                                   message:@"Change Spotify Connect device"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UIWindow *view = [UIApplication sharedApplication].keyWindow;
        alert.popoverPresentationController.sourceView = view;
        alert.popoverPresentationController.sourceRect = CGRectMake([[UIScreen mainScreen] bounds].size.width / 2,
                                                                    [[UIScreen mainScreen] bounds].size.height,
                                                                    0, 0);
    }

    SBApplication* app = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:spotifyBundleIdentifier];
    
    if ([app pid] >= 0) { // Spotify is running
        // Update preferences
        self.preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];
        BOOL offline = [[self.preferences objectForKey:offlineKey] boolValue];

        if (offline) {
            UIAlertAction *goOnlineAction = [UIAlertAction
                                              actionWithTitle:@"Go online"
                                              style:UIAlertActionStyleDestructive
                                              handler:^(UIAlertAction *action) {
                                                  HBLogDebug(@"Trying to go online");
                                                  notify(doDisableOfflineModeNotification);
                                              }];
            
            [alert addAction:goOnlineAction];
        }

        NSArray *deviceNames  = [self.preferences objectForKey:devicesKey];
        NSString *activeDevice = [self.preferences objectForKey:activeDeviceKey];
        
        for (int i = 0; i < deviceNames.count; i++) {
            UIAlertAction *deviceAction;
            if ([activeDevice isEqualToString:deviceNames[i]]) {
                deviceAction = [self createConnectDeviceAction:[@"●  " stringByAppendingString:deviceNames[i]] atIndex:i];
            } else {
                deviceAction = [self createConnectDeviceAction:deviceNames[i] atIndex:i];
            }
            [alert addAction:deviceAction];
        }
    } else {
        UIAlertAction *launchAppAction = [UIAlertAction
                                         actionWithTitle:@"Launch Spotify"
                                         style:UIAlertActionStyleDestructive
                                         handler:^(UIAlertAction *action) {
                                             HBLogDebug(@"Trying to launch Spotify...");
                                             launchSpotifyWithUnlock();
                                         }];
        
        [alert addAction:launchAppAction];
    }

    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
    
    [alert addAction:cancel];
    [alert show];
}

- (void)clickedDeviceAtIndex:(NSInteger)index {
    NSArray *deviceNames = [self.preferences objectForKey:devicesKey];
    NSString *selectedDeviceName = deviceNames[index];
    NSString *activeDevice = [self.preferences objectForKey:activeDeviceKey];
    
    if ([activeDevice isEqualToString:selectedDeviceName]) {
        HBLogDebug(@"Trying to disconnected from: %@", selectedDeviceName);
        [self.preferences setObject:@"" forKey:activeDeviceKey];
    } else {
        HBLogDebug(@"Trying to connect to: %@", selectedDeviceName);
        [self.preferences setObject:selectedDeviceName forKey:activeDeviceKey];
    }
    
    // Save to .plist
    if (![self.preferences writeToFile:prefPath atomically:YES]) {
        HBLogError(@"Could not save preferences!");
    } else {
        // Send notification that device was changed
        notify(doChangeConnectDeviceNotification);
    }
}

@end
