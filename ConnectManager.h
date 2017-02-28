@interface SPTGaiaDeviceManager : NSObject
- (id)devices;
- (id)activeDevice;
- (void)activateDevice:(id)device withCallback:(id)callback;
@end

@interface SPTGaiaDevice : NSObject
@property (nonatomic, strong, readwrite) NSString *name;
// not sure if these are needed:
@property (nonatomic, strong, readwrite) NSString *attachId;
@property (nonatomic, strong, readwrite) NSString *deviceId;
@end


@interface ConnectManager : NSObject

+ (id)sharedInstance;
@property (nonatomic, assign, readwrite) NSArray<SPTGaiaDevice *> *devices;
@property (nonatomic, assign, readwrite) SPTGaiaDeviceManager *gaia;

@end
