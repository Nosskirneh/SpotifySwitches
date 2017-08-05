include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Connectify
Connectify_FILES = Connectify.xm
Connectify_LIBRARIES = activator
Connectify_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
