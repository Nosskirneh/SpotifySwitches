#import "AddToCollection.h"

@implementation AddToCollection

+ (void)load {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"])
        [(LAActivator *)[%c(LAActivator) sharedInstance] registerListener:[self new] forName:@"se.nosskirneh.addtocollection"];
    [pool release];
}

- (id)init {
    self = [super init];

    // Init settings file
    preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];
    if (!preferences) preferences = [[NSMutableDictionary alloc] init];
    
    return self;
}

- (UIAlertAction *)createLaunchAppAction:(NSString *)title {
    return [UIAlertAction
            actionWithTitle:title
            style:UIAlertActionStyleDestructive
            handler:^(UIAlertAction *action) {
                [[%c(UIApplication) sharedApplication] launchApplicationWithIdentifier:spotifyBundleIdentifier suspended:NO];
            }];
}

// Called when the user-defined action is recognized
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
    [event setHandled:YES];
    
    UIAlertController *alert = [UIAlertController
                                        alertControllerWithTitle:@"Ohoh"
                                        message:@"Couldn't find current track!"
                                        preferredStyle:UIAlertControllerStyleActionSheet
                                        ];
    
    SBApplication* app = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:spotifyBundleIdentifier];
    
    if ([app pid] >= 0) { // Spotify is running

        if ([[preferences objectForKey:isCurrentTrackNullKey] boolValue]) {
            // Not listening to music
            UIAlertAction *launchAppAction = [self createLaunchAppAction:@"Play some music"];
            [alert addAction:launchAppAction];
        } else {
            // Add song;
        }
    } else  {
        UIAlertAction *launchAppAction = [self createLaunchAppAction:@"Launch Spotify"];
        [alert addAction:launchAppAction];
    }
    
    if (alert.actions.count != 0) {
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleCancel
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];

        [alert addAction:cancel];
        [alert show];
    } else {
        // Send notification
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)addCurrentTrackToCollectionNotification, NULL, NULL, YES);
    }
}

@end
