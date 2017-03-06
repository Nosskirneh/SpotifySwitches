#import "Connectify.h"

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
                                             HBLogDebug(@"Launching Spotify...");
                                             [[%c(UIApplication) sharedApplication] launchApplicationWithIdentifier:spotifyBundleIdentifier suspended:NO];
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
