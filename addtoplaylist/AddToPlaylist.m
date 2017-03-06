#import "AddToPlaylist.h"

@implementation AddToPlaylist

+ (void)load {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"])
        [(LAActivator *)[%c(LAActivator) sharedInstance] registerListener:[self new] forName:@"se.nosskirneh.addtoplaylist"];
    [pool release];
}

- (id)init {
    self = [super init];

    // Init settings file
    preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];
    if (!preferences) preferences = [[NSMutableDictionary alloc] init];
    
    return self;
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
        preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];
        
        if ([[preferences objectForKey:isCurrentTrackNullKey] boolValue]) {
            // Not listening to music
            UIAlertAction *launchAppAction = [self createLaunchAppAction:@"Play some music"];
            [playlistAlert addAction:launchAppAction];
        } else {
            playlists = [preferences objectForKey:playlistsKey];
            
            UIAlertAction *playlistAction;
            for (int i = 0; i < playlists.count; i++) {
                playlistAction = [UIAlertAction
                                  actionWithTitle:[playlists[i] objectForKey:@"name"]
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action) {
                                      [self clickedPlaylistAtIndex:i];
                                  }];
                [playlistAlert addAction:playlistAction];
                HBLogDebug(@"Added a playlist action!");
            }
        }
        
    } else {
        UIAlertAction *launchAppAction = [self createLaunchAppAction:@"Launch Spotify"];
        [playlistAlert addAction:launchAppAction];
    }
    
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * action)
                             {
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
                [[%c(UIApplication) sharedApplication] launchApplicationWithIdentifier:spotifyBundleIdentifier suspended:NO];
            }];
}

- (void)clickedPlaylistAtIndex:(NSInteger)index {
    NSString *selectedPlaylistName = [playlists[index] objectForKey:@"name"];

    HBLogDebug(@"Trying to add current track to: %@", selectedPlaylistName);
    [preferences setObject:selectedPlaylistName forKey:chosenPlaylistKey];

    // Save to .plist
    if (![preferences writeToFile:prefPath atomically:YES]) {
        HBLogError(@"Could not save preferences!");
    }
    // Send notification that a playlist was choosen
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)addCurrentTrackToPlaylistNotification, NULL, NULL, YES);
}

@end
