include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AddToPlaylist
AddToPlaylist_FILES = AddToPlaylist.xm ../include/Unlock.xm
AddToPlaylist_LIBRARIES = activator
AddToPlaylist_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
