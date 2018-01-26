include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AddToCollection
AddToCollection_FILES = AddToCollection.xm ../include/Unlock.xm
AddToCollection_LIBRARIES = activator
AddToCollection_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
