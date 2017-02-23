include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = SpotifyShuffle
SpotifyShuffle_FILES = Switch.xm
SpotifyShuffle_FRAMEWORKS = UIKit
SpotifyShuffle_LIBRARIES = flipswitch
SpotifyShuffle_INSTALL_PATH = /Library/Switches

include $(THEOS_MAKE_PATH)/bundle.mk

after-install::
	install.exec "killall -9 SpringBoard"
