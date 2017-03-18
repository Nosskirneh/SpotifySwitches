
@interface SBAlert
@end

@interface SBDeviceLockController : NSObject
+ (SBDeviceLockController *)sharedController;
- (BOOL)isPasscodeLocked;
@end

@interface SBLockScreenViewControllerBase: SBAlert
-(void)setCustomLockScreenActionContext:(id)arg1 ;
-(void)setCustomUnlockActionContext:(id)arg1;
-(id)_customLockScreenActionContext;
-(void)deactivate;
-(void)prepareForUIUnlock;
-(void)prepareForExternalUIUnlock;
-(void)finishUIUnlockFromSource:(int)arg1 ;
-(void)attemptToUnlockUIFromNotification;
-(void)_transitionWallpaperFromLock;

- (void)setPasscodeLockVisible:(BOOL)visibile animated:(BOOL)animated completion:(void (^)())completion;
//@property (assign,nonatomic) id<SBLockScreenViewControllerDelegate> delegate;              //@synthesize delegate=_delegate - In the implementation block
//-(id<SBLockScreenViewControllerDelegate>)delegate;
-(id)activeLockScreenPluginController;
-(BOOL)isUnlockDisabled;
-(BOOL)isMainPageVisible;
-(BOOL)isPasscodeLockVisible;
-(void)noteMenuButtonDown;
-(void)noteMenuButtonUp;
-(BOOL)handleMenuButtonTap;
-(void)willBeginDeactivationForTransitionToApps:(id)arg1 animated:(BOOL)arg2 ;
-(void)didCompleteTransitionOutOfLockScreen;
-(void)handleBiometricEvent:(unsigned long long)arg1 ;
-(BOOL)shouldUnlockUIOnKeyDownEvent;
-(BOOL)isAuthenticated;
-(BOOL)isLockScreenVisible;
@end

@interface SBLockScreenManager : NSObject
+ (SBLockScreenManager *)sharedInstance;
- (BOOL)isUILocked;
- (SBLockScreenViewControllerBase *)lockScreenViewController;
- (void)noteMenuButtonSinglePress;
- (void)attemptUnlockWithMesa;
-(BOOL)isLockScreenActive;
-(BOOL)_isUnlockDisabled;
-(BOOL)_finishUIUnlockFromSource:(int)arg1 withOptions:(id)arg2 ;
-(BOOL)isLockScreenVisible;

@end

@interface SBUnlockActionContext : NSObject
- (id)initWithLockLabel:(NSString *)lockLabel shortLockLabel:(NSString *)label unlockAction:(void (^)())action identifier:(NSString *)id;
- (void)setDeactivateAwayController:(BOOL)deactivate;
@end

@interface SBLockScreenActionContext : NSObject
-(id)initWithLockLabel:(id)arg1 shortLockLabel:(id)arg2 action:(/*^block*/id)arg3 identifier:(id)arg4 ;
- (void)setDeactivateAwayController:(BOOL)deactivate;
-(void)setAction:(id)arg1 ;
@end