#import <libactivator/libactivator.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBApplicationController.h>
#import "../include/Common.h"
#import "../include/UIAlertController.h"
#import "../include/Unlock.h"

@interface AddToPlaylist : NSObject <LAListener>
@property (nonatomic, readwrite, retain) NSMutableDictionary *preferences;

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event;
+ (void)load;

@end
