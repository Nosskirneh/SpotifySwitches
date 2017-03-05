include $(THEOS)/makefiles/common.mk

TWEAK_NAME = addToPlaylist
addToPlaylist_FILES = AddToPlaylist.xm
addToPlaylist_LIBRARIES = activator

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
