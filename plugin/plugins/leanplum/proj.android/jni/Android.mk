LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE    := libPluginLeanPlum
LOCAL_SRC_FILES := libPluginLeanPlum.cpp

include $(BUILD_SHARED_LIBRARY)
