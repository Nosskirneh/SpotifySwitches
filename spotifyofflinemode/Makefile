include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = SpotifyOfflineFlipswitch
SpotifyOfflineFlipswitch_FILES = Switch.xm
SpotifyOfflineFlipswitch_FRAMEWORKS = UIKit
SpotifyOfflineFlipswitch_LIBRARIES = flipswitch
SpotifyOfflineFlipswitch_INSTALL_PATH = /Library/Switches

include $(THEOS_MAKE_PATH)/bundle.mk

before-stage::
	rm switch.xm; ln -s Switch.m Switch.xm
