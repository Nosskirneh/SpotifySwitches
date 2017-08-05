#import <libactivator/libactivator.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBApplicationController.h>
#import <UIKit/UIApplication2.h>
#import "../include/Common.h"
#import "../include/UIAlertController.h"

@interface AddToCollection : NSObject <LAListener>

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event;
+ (void)load;

@end
