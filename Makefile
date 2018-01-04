TARGET = iphone:clang:9.2

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SpotifySwitches
SpotifySwitches_FILES = SpotifySwitches.xm include/Common.xm
SpotifySwitches_LIBRARIES = MobileGestalt

include $(THEOS_MAKE_PATH)/tweak.mk

internal-after-install::
	install.exec "killall -9 Spotify"

SUBPROJECTS += spotifyofflinemode
SUBPROJECTS += spotifyshuffle
SUBPROJECTS += spotifyrepeat
SUBPROJECTS += connectify
SUBPROJECTS += addtoplaylist
SUBPROJECTS += addtocollection
SUBPROJECTS += spotifyincognito
SUBPROJECTS += preferences
include $(THEOS_MAKE_PATH)/aggregate.mk
