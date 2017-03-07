include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = SpotifyIncognito
SpotifyIncognito_FILES = Switch.xm
SpotifyIncognito_FRAMEWORKS = UIKit
SpotifyIncognito_LIBRARIES = flipswitch
SpotifyIncognito_INSTALL_PATH = /Library/Switches

include $(THEOS_MAKE_PATH)/bundle.mk

before-stage::
	rm switch.xm; ln -s Switch.m Switch.xm
