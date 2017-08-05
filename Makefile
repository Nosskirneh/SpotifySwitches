include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SpotifySwitches
SpotifySwitches_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

# Sometimes theos replaces my symlink :(
before-stage::
	rm tweak.xm; ln -s Tweak.m Tweak.xm
	find . -name ".DS_Store" -delete

before-install::
	~/Dropbox/bin/updateIP.sh && source ~/Dropbox/bin/theos.sh

internal-after-install::
	install.exec "killall -9 SpringBoard"

SUBPROJECTS += spotifyofflinemode
SUBPROJECTS += spotifyshuffle
SUBPROJECTS += spotifyrepeat
SUBPROJECTS += connectify
SUBPROJECTS += addtoplaylist
SUBPROJECTS += addtocollection
SUBPROJECTS += spotifyincognito
SUBPROJECTS += preferences
include $(THEOS_MAKE_PATH)/aggregate.mk
