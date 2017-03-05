#import <libactivator/libactivator.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBApplicationController.h>
#import <UIKit/UIApplication2.h>
#import "../include/Header.h"

@interface AddToCollection : NSObject <LAListener, UIActionSheetDelegate>

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event;
+ (void)load;

@end
