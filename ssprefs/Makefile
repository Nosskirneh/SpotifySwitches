include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = SSPrefs
SSPrefs_FILES = SpotifySwitchesRootListController.m
SSPrefs_INSTALL_PATH = /Library/PreferenceBundles
SSPrefs_FRAMEWORKS = UIKit
SSPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/SSPrefs.plist$(ECHO_END)
