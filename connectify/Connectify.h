#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBApplicationController.h>
#import <libactivator/libactivator.h>
#import <UIKit/UIApplication2.h>
#import "../include/Header.h"
#import "../include/UIAlertController.h"
#import <Foundation/Foundation.h>
#import "../include/Unlock.h"

@interface Connectify : NSObject <LAListener>

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event;
+ (void)load;

@end
