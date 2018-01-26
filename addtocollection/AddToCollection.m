#import "AddToCollection.h"

@implementation AddToCollection

+ (void)load {
    if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"])
        [(LAActivator *)[%c(LAActivator) sharedInstance] registerListener:[self new] forName:@"se.nosskirneh.addtocollection"];
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
    // Update preferences
    NSMutableDictionary *preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];
    
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
            if ([[preferences objectForKey:isCurrentTrackInCollectionKey] boolValue]) {
                // Present UIAlertController that says "already in collection - add anyway?"
                alert.message = @"Track already in collection! Do you want to keep it there or remove it?";
                UIAlertAction* remove = [UIAlertAction
                                         actionWithTitle:@"Remove"
                                         style:UIAlertActionStyleDestructive
                                         handler:^(UIAlertAction * action) {
                                             // Change the message of the alert here
                                             notify(toggleCurrentTrackInCollectionNotification);
                                         }];
                [alert addAction:remove];
            }
        }
    } else  {
        UIAlertAction *launchAppAction = [self createLaunchAppAction:@"Launch Spotify"];
        [alert addAction:launchAppAction];
    }

    if (alert.actions.count != 0) {
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleCancel
                                 handler:^(UIAlertAction * action) {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                 }];

        [alert addAction:cancel];
        [alert show];
    } else {
        // Send notification
        notify(toggleCurrentTrackInCollectionNotification);
    }
}

@end
