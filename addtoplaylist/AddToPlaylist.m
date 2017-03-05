#import "AddToPlaylist.h"

@implementation AddToPlaylist

UIActionSheet *playlistSheet;
NSString *chosenPlaylist;

+ (void)load {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"])
        [(LAActivator *)[%c(LAActivator) sharedInstance] registerListener:[self new] forName:@"se.nosskirneh.addtoplaylist"];
    [pool release];
}

- (id)init {
    self = [super init];

    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addToPlaylistStartNotificationReceived:) name:@"addtoplaylist.start" object:nil];
    }

    // Init settings file
    preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];
    if (!preferences) preferences = [[NSMutableDictionary alloc] init];
    
    return self;
}

// Called when the user-defined action is recognized, shows selection sheet
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
    [event setHandled:YES];
    [self addToPlaylistStartNotificationReceived:nil];
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event {
    [self dismiss];
}

- (void)activator:(LAActivator *)activator otherListenerDidHandleEvent:(LAEvent *)event {
    [self dismiss];
}

- (void)activator:(LAActivator *)activator receiveDeactivateEvent:(LAEvent *)event {
    [self dismiss];
}

// Restricts action to only be paired with other non-modal-ui actions
- (NSArray *)activator:(LAActivator *)activator requiresExclusiveAssignmentGroupsForListenerName:(NSString *)listenerName {
    return @[@"modal-ui"];
}

- (void)addToPlaylistStartNotificationReceived:(NSNotification *)notification {
    if (playlistSheet) {
        HBLogDebug(@"Already presenting an action sheet, so we'll ignore this subsequent call");
        return;
    }

    SBApplication* app = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:spotifyBundleIdentifier];
    int pid = [app pid];
    
    playlistSheet = [[UIActionSheet alloc] initWithTitle:@"Current track\nAdd to which playlist?" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];

    if (pid >= 0) { // Spotify is running
        // Update preferences
        preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];

        if ([[preferences objectForKey:isCurrentTrackNullKey] boolValue]) {
            playlistSheet.destructiveButtonIndex = [playlistSheet addButtonWithTitle:@"Play some music"];
        } else {
            playlists = [preferences objectForKey:playlistsKey];
            
            for (int i = 0; i < playlists.count; i++) {
                [playlistSheet addButtonWithTitle:[playlists[i] objectForKey:@"name"]];
            }
        }

    } else {
        playlistSheet.destructiveButtonIndex = [playlistSheet addButtonWithTitle:@"Launch Spotify"];
    }

    playlistSheet.cancelButtonIndex = [playlistSheet addButtonWithTitle:@"Cancel"];
    
    [playlistSheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)dismiss {
    if (playlistSheet) {
        [playlistSheet dismissWithClickedButtonIndex:playlistSheet.cancelButtonIndex animated:YES];
    } else {
        HBLogDebug(@"Cannot dismiss non-existent action sheet");
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if (buttonIndex < 0 || [buttonTitle isEqualToString:@"Cancel"]) { // Cancel
        HBLogDebug(@"Dismissing action sheet after cancel button press");
    } else if ([buttonTitle isEqualToString:@"Launch Spotify"] || [buttonTitle isEqualToString:@"Play some music"]) { // Launch Spotify
        HBLogDebug(@"Trying to launch Spotify");
        [[%c(UIApplication) sharedApplication] launchApplicationWithIdentifier:spotifyBundleIdentifier suspended:NO];
    } else {
        //NSString *selectedPlaylistName = playlistNames[[playlistNames indexOfObject:buttonTitle]];
        NSString *selectedPlaylistName = [playlists[buttonIndex] objectForKey:@"name"];
        
        HBLogDebug(@"Trying to add current track to: %@", selectedPlaylistName);
        [preferences setObject:selectedPlaylistName forKey:chosenPlaylistKey];
        
        // Save to .plist
        if (![preferences writeToFile:prefPath atomically:YES]) {
            HBLogError(@"Could not save preferences!");
        }
        // Send notification that a playlist was choosen
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)addCurrentTrackNotification, NULL, NULL, YES);
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    playlistSheet = nil;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [playlists release];
    [playlistSheet release];
    
    [super dealloc];
}

@end
