#import "Connectify.h"

@implementation Connectify

UIActionSheet *connectSheet;
NSMutableArray *titles;

+ (void)load {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"]) // Do not load into Spotify
        [[%c(LAActivator) sharedInstance] registerListener:[self new] forName:@"se.nosskirneh.connectify"];
    [pool release];
}

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectStartNotificationReceived:) name:@"Connectify.start" object:nil];
    }
    
    return self;
}

// Called when the user-defined action is recognized, shows selection sheet
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
    [event setHandled:YES];
    
    HBLogDebug(@"Listener received call to (activator:receiveEvent:)");
    [self connectStartNotificationReceived:nil];
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event {
    HBLogDebug(@"Listener received call to (activator:abortEvent:)");
    [self dismiss];
}

- (void)activator:(LAActivator *)activator otherListenerDidHandleEvent:(LAEvent *)event {
    HBLogDebug(@"Listener received call to (activator:otherListenerDidHandleEvent:)");
    [self dismiss];
}

- (void)activator:(LAActivator *)activator receiveDeactivateEvent:(LAEvent *)event {
    HBLogDebug(@"Listener received call to (activator:receiveDeactivateEvent:)");
    [self dismiss];
}

// Restricts action to only be paired with other non-modal-ui actions
- (NSArray *)activator:(LAActivator *)activator requiresExclusiveAssignmentGroupsForListenerName:(NSString *)listenerName {
    return @[@"modal-ui"];
}

- (void)connectStartNotificationReceived:(NSNotification *)notification {
    if (connectSheet) {
        HBLogDebug(@"Already presenting an action sheet, so we'll ignore this subsequent call");
        return;
    }
    
    titles = [[NSMutableArray alloc] initWithCapacity:((ConnectManager *)[ConnectManager sharedInstance]).devices.count+1];
    
    connectSheet = [[UIActionSheet alloc] initWithTitle:@"Spotify Connect\nDevices" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    HBLogDebug(@"%@", ((ConnectManager *)[ConnectManager sharedInstance]).gaia);
    for (int i = 0; i < ((ConnectManager *)[ConnectManager sharedInstance]).devices.count; i++) {
        SPTGaiaDevice* device = ((ConnectManager *)[ConnectManager sharedInstance]).devices[i];
        
        if ([((ConnectManager *)[ConnectManager sharedInstance]).gaia activeDevice] == device) {
            [titles addObject:[@"●  " stringByAppendingString:device.name]];
        } else {
            [titles addObject:device.name];
            
            [connectSheet addButtonWithTitle:titles[i]];
        }
    }
    
    connectSheet.cancelButtonIndex = [connectSheet addButtonWithTitle:@"Cancel"];
    
    [connectSheet showInView:[UIApplication sharedApplication].keyWindow];
    HBLogDebug(@"Notification received, presented action sheet (%@) from window: %@", connectSheet, [UIApplication sharedApplication].keyWindow);
}

- (void)dismiss {
    if (connectSheet) {
        [connectSheet dismissWithClickedButtonIndex:connectSheet.cancelButtonIndex animated:YES];
    } else {
        HBLogDebug(@"Cannot dismiss non-existent action sheet");
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    HBLogDebug(@"actionSheet:<%@>clickedButtonAtIndex:<%i>, buttonTitle:%@", actionSheet, (int)buttonIndex, buttonTitle);
    
    if (buttonIndex < 0 || [buttonTitle isEqualToString:@"Cancel"]) { // Cancel
        HBLogDebug(@"Dismissing action sheet after cancel button press");
    } else {
        SPTGaiaDevice *selectedDevice = ((ConnectManager *)[ConnectManager sharedInstance]).devices[[titles indexOfObject:buttonTitle]];
        
        if ([((ConnectManager *)[ConnectManager sharedInstance]).gaia activeDevice] == selectedDevice) {
            HBLogDebug(@"Trying to disconnected from: %@", selectedDevice);
            [((ConnectManager *)[ConnectManager sharedInstance]).gaia activateDevice:nil withCallback:nil];
        } else {
            HBLogDebug(@"Trying to connect to: %@", selectedDevice);
            [((ConnectManager *)[ConnectManager sharedInstance]).gaia activateDevice:selectedDevice withCallback:nil];
        }
    }
    ((ConnectManager *)[ConnectManager sharedInstance]).devices = nil;
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    connectSheet = nil;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [((ConnectManager *)[ConnectManager sharedInstance]).devices release];
    [titles release];
    [connectSheet release];
    
    [super dealloc];
}

@end
