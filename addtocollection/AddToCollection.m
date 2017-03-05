#import "AddToCollection.h"

@implementation AddToCollection

UIActionSheet *playlistSheet;
NSString *chosenPlaylist;

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

// Called when the user-defined action is recognized
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
    [event setHandled:YES];
    
    // Send notification
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)addCurrentTrackToCollectionNotification, NULL, NULL, YES);
    
}

@end
