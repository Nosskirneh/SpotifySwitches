#ifndef SPCORE_H
#define SPCORE_H

@interface SPCore : NSObject

- (void)setForcedOffline:(BOOL)arg;
@property (nonatomic, assign, readwrite) BOOL forcedOffline;

@end

#endif
