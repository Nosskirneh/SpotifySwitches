include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SpotifySwitches
SpotifySwitches_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

# Sometimes theos replaces my symlink :(
before-stage::
	rm tweak.xm; ln -s Tweak.m Tweak.xm

before-install::
	~/Dropbox/bin/updateIP.sh && source ~/Dropbox/bin/theos.sh

after-install::
	install.exec "killall -9 SpringBoard"

SUBPROJECTS += spotifyofflinemode
SUBPROJECTS += spotifyshuffle
SUBPROJECTS += spotifyrepeat
include $(THEOS_MAKE_PATH)/aggregate.mk
