LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE    := libIAPGooglePlay
LOCAL_SRC_FILES := libIAPGooglePlay.cpp

include $(BUILD_SHARED_LIBRARY)
