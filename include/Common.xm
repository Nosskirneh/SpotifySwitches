#import "Common.h"

extern NSMutableDictionary *preferences;

// Method that updates changes to .plist
void writeToSettings(NSString *path) {
    if (![preferences writeToFile:path atomically:YES]) {
        HBLogError(@"Could not save preferences to path %@", path);
    }
}
