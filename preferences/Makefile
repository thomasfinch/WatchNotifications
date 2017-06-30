ARCHS = armv7 arm64
TARGET_IPHONEOS_DEPLOYMENT_VERSION = 7.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = WatchNotifications
WatchNotifications_FILES = WatchNotifications.mm
WatchNotifications_INSTALL_PATH = /Library/PreferenceBundles
WatchNotifications_FRAMEWORKS = UIKit
WatchNotifications_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/WatchNotifications.plist$(ECHO_END)
