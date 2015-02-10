export ARCHS = armv7 armv7s
export TARGET = iphone:clang:8.1:8.1

include theos/makefiles/common.mk

TOOL_NAME = memscan
memscan_FILES = main.mm

ADDITIONAL_CFLAGS = -Wno-format -Wno-error -Wno-unused-variable -Wno-c++11-compat-deprecated-writable-strings

include $(THEOS_MAKE_PATH)/tool.mk
