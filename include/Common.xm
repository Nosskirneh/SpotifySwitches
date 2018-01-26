#import "Common.h"

extern NSMutableDictionary *preferences;

// Method that updates changes to .plist
void writeToSettings(NSString *path) {
    if (![preferences writeToFile:path atomically:NO]) {
        HBLogError(@"Could not save %@ to path %@", preferences, path);
    }
}
