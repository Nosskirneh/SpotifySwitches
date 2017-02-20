include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SpotifyOfflineSwitch
SpotifyOfflineSwitch_FILES = Tweak.xm
SpotifyOfflineSwitch_CFLAGS += -I.

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"

SUBPROJECTS += flipswitch
include $(THEOS_MAKE_PATH)/aggregate.mk
