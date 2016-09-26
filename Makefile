ARCHS = armv7 arm64
THEOS_BUILD_DIR = debs

include $(THEOS)/makefiles/common.mk

SOURCE_FILES=$(wildcard source/*.m source/*.mm source/*.x source/*.xm)

TWEAK_NAME = WatchNotifications
WatchNotifications_FILES = $(SOURCE_FILES)
WatchNotifications_FRAMEWORKS = UIKit CoreGraphics QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"

SUBPROJECTS += preferences

include $(THEOS_MAKE_PATH)/aggregate.mk
