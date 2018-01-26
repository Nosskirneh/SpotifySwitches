#import "AddToPlaylist.h"

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
                launchSpotifyWithUnlock();
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
