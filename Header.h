#ifndef HEADER
#define HEADER


static NSString *nsDomainString = @"se.nosskirneh.sos";
static NSString *onlineNotification = @"se.nosskirneh.sos/online";
static NSString *offlineNotification = @"se.nosskirneh.sos/offline";


@interface SPCore : NSObject
- (void)setForcedOffline:(BOOL)arg;
@property (nonatomic, assign, readwrite) BOOL forcedOffline;
@end


@interface SettingsSection : NSObject

@end


@interface SettingsViewController : UIViewController
@property (weak, nonatomic) NSArray<SettingsSection *> *sections;
@end


@interface SPNavigationController : UIViewController

@end


@interface NSUserDefaults (Tweak_Category)
- (id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
- (void)setObject:(id)value forKey:(NSString *)key inDomain:(NSString *)domain;
@end



#endif
