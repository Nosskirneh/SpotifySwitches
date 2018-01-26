#import "AddToPlaylist.h"

@implementation AddToPlaylist

+ (void)load {
    if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"])
        [(LAActivator *)[%c(LAActivator) sharedInstance] registerListener:[self new] forName:@"se.nosskirneh.addtoplaylist"];
}

// Called when the user-defined action is recognized, shows selection alert
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
    [event setHandled:YES];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add to Playlist"
                                                                   message:@"Add current track to which playlist?"
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
        
        if ([[self.preferences objectForKey:isCurrentTrackNullKey] boolValue]) {
            // Not listening to music
            UIAlertAction *launchAppAction = [self createLaunchAppAction:@"Play some music"];
            [alert addAction:launchAppAction];
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
                [alert addAction:playlistAction];
            }
        }
        
    } else {
        UIAlertAction *launchAppAction = [self createLaunchAppAction:@"Launch Spotify"];
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
