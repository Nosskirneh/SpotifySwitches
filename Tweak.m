// Offline toggle

#import "SPCore.h"
#import "OfflineManager.h"

%hook SPCore

- (id)init {
    HBLogDebug(@"Found SPCore");
    return [OfflineManager si].spotifyCore = %orig;
    //return spotifyCore = %orig;
}

%end


@interface SettingsSection : NSObject

@end


@interface SettingsViewController : UIViewController

@property (weak, nonatomic) NSArray<SettingsSection *> *sections;

@end

static BOOL didLoadSubviews = NO;

%hook SettingsViewController

- (void)viewDidLoad {
    // Only call viewDidLayoutSubviews once
    didLoadSubviews = NO;
    HBLogDebug(@"Found a SettingsViewController");
}

- (void)viewDidLayoutSubviews {
    %orig;
    if (!didLoadSubviews) {
        [OfflineManager si].isCurrentViewOfflineView = NO;
        didLoadSubviews = YES;
        if (self.sections.count >= 1) {
            NSString *className = NSStringFromClass([self.sections[1] class]);
            
            // Is current SettingsViewController the one with offline settings?
            // in that case, set isCurrentViewOFflineView to YES so that we
            // cannot toggle offline mode - Spotify will then crash!
            if ([className isEqualToString:@"OfflineSettingsSection"]) {
                [OfflineManager si].isCurrentViewOfflineView = YES;
                HBLogDebug(@"Setting isCurrentViewOfflineView to %d", [OfflineManager si].isCurrentViewOfflineView);
            }
        }
    }
}

- (void)viewDidDisappear {
    [OfflineManager si].isCurrentViewOfflineView = NO;
    HBLogDebug(@"Setting isCurrentViewOfflineView to %d", [OfflineManager si].isCurrentViewOfflineView);
}

%end
