TARGET := iphone:clang:latest:12.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = vegitoTweakPrefBundle

vegitoTweakPrefBundle_FILES = VEGITOPREFRootListController.m
vegitoTweakPrefBundle_FRAMEWORKS = UIKit
vegitoTweakPrefBundle_PRIVATE_FRAMEWORKS = Preferences
vegitoTweakPrefBundle_INSTALL_PATH = /Library/PreferenceBundles
vegitoTweakPrefBundle_LIBRARIES = gcuniversal

vegitoTweakPrefBundle_CFLAGS = -fobjc-arc


include $(THEOS_MAKE_PATH)/bundle.mk
