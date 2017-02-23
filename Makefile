include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SpotifySwitches
SpotifySwitches_FILES = Tweak.xm
SpotifySwitches_CFLAGS += -I.

include $(THEOS_MAKE_PATH)/tweak.mk

# Sometimes theos replaces my symlink :(
before-stage::
	rm tweak.xm; ln -s Tweak.m Tweak.xm

after-install::
	install.exec "killall -9 SpringBoard"

SUBPROJECTS += spotifyofflinemode
SUBPROJECTS += spotifyshuffle
include $(THEOS_MAKE_PATH)/aggregate.mk
