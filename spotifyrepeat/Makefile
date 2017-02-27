include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = SpotifyRepeat
SpotifyRepeat_FILES = Switch.xm
SpotifyRepeat_FRAMEWORKS = UIKit
SpotifyRepeat_LIBRARIES = flipswitch
SpotifyRepeat_INSTALL_PATH = /Library/Switches

include $(THEOS_MAKE_PATH)/bundle.mk

before-stage::
	rm switch.xm; ln -s Switch.m Switch.xm
