export TARGET_CODESIGN_FLAGS="-Sentitlements.xml"
export ARCHS = armv7 armv7s
export TARGET = iphone:clang:8.2:8.1
GO_EASY_ON_ME=1

include theos/makefiles/common.mk

TOOL_NAME = memscan
memscan_FILES = main.mm

ADDITIONAL_CFLAGS = -Wno-format -Wno-error -Wno-unused-variable -Wno-c++11-compat-deprecated-writable-strings

include $(THEOS_MAKE_PATH)/tool.mk

before-package::
	touch -r _/usr/bin/memscan _
	touch -r _/usr/bin/memscan _/DEBIAN
	touch -r _/usr/bin/memscan _/DEBIAN/*
	touch -r _/usr/bin/memscan _/usr
	touch -r _/usr/bin/memscan _/usr/bin
	chmod 0755 _/usr/bin/memscan*

after-package::
	rm -fr .theos/packages/*
