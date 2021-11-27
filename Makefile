TARGET := iphone:clang:latest:12.0
INSTALL_TARGET_PROCESSES = SpringBoard


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Vegito

Vegito_FILES = Tweak.x
Vegito_CFLAGS = -fobjc-arc

export ARCHS = arm64 arm64e 
Vegito_FRAMEWORKS += UIKit CoreGraphics AVFoundation MobileCoreServices
export Vegito_LIBRARIES = gcuniversal

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += vegitotweakprefbundle
include $(THEOS_MAKE_PATH)/aggregate.mk
