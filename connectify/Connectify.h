#import <libactivator/libactivator.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBApplicationController.h>
#import <UIKit/UIApplication.h>
#import "../include/Header.h"

@interface UIWindow (Private)
- (void)_setSecure:(BOOL)arg1;
@end

@interface Connectify : NSObject <LAListener, UIActionSheetDelegate>

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event;
- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event;
- (void)activator:(LAActivator *)activator otherListenerDidHandleEvent:(LAEvent *)event;
- (void)activator:(LAActivator *)activator receiveDeactivateEvent:(LAEvent *)event;
+ (void)load;

@end
