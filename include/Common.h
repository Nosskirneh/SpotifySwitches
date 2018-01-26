#ifndef COMMON
#define COMMON

void writeToSettings(NSString *path);


#define notifactionArguments CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo
#define notify(x) CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)x, NULL, NULL, YES)
#define subscribe(x, y) CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, x, CFStringRef(y), NULL, 0);
#define ClassName(x) NSStringFromClass([x class])

// Settings file
NSString *const prefPath = @"/var/mobile/Library/Preferences/se.nosskirneh.spotifyswitches.plist";

// Notification strings
// Offline Mode
NSString *const nsDomainString = @"se.nosskirneh.spotifyswitches";
NSString *const doEnableOfflineModeNotification = @"se.nosskirneh.spotifyswitches/doEnableOfflineMode";
NSString *const doDisableOfflineModeNotification = @"se.nosskirneh.spotifyswitches/doDisableOfflineMode";
// Shuffle
NSString *const doToggleShuffleNotification = @"se.nosskirneh.spotifyswitches/doToggleShuffle";
// Repeat
NSString *const doEnableRepeatNotification = @"se.nosskirneh.spotifyswitches/doEnableRepeat";
NSString *const doDisableRepeatNotification = @"se.nosskirneh.spotifyswitches/doDisableRepeat";

// Connect
NSString *const doChangeConnectDeviceNotification = @"se.nosskirneh.spotifyswitches/doChangeConnectDevice";

// Add to playlist
NSString *const addCurrentTrackToPlaylistNotification = @"se.nosskirneh.spotifyswitches/addCurrentTrackToPlaylist";
NSString *const specifiedPlaylistNameKey = @"SpecifiedPlaylistName";

// Add to collection
NSString *const toggleCurrentTrackInCollectionNotification = @"se.nosskirneh.spotifyswitches/toggleCurrentTrackInCollection";

// Incognito Mode
NSString *const toggleIncognitoModeNotification = @"se.nosskirneh.spotifyswitches/toggleIncognitoMode";

// Preferences
NSString *const preferencesChangedNotification = @"se.nosskirneh.spotifyswitches/preferencesChanged";

// Lookup keys
NSString *const offlineKey = @"OfflineMode";
NSString *const shuffleKey = @"Shuffle";
NSString *const repeatKey  = @"Repeat";
NSString *const devicesKey = @"ConnectDevices";
NSString *const activeDeviceKey = @"ActiveConnectDevice";
NSString *const playlistsKey = @"Playlists";
NSString *const playlistsSetKey = @"PlaylistsBySet";
NSString *const playlistIndexKey = @"playlistIndex";
NSString *const skipDuplicatesKey = @"skipDuplicates";
NSString *const isCurrentTrackNullKey = @"isCurrentTrackNull";
NSString *const isCurrentTrackInCollectionKey = @"isCurrentTrackInCollection";
NSString *const incognitoKey = @"IncognitoMode";
NSString *const lastPopupVersionKey = @"lastPopupVersion";

// Other
NSString *const spotifyBundleIdentifier = @"com.spotify.client";

#endif
