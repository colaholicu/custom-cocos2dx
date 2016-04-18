LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE    := libPluginUnityAds
LOCAL_SRC_FILES := libPluginUnityAds.cpp


LOCAL_WHOLE_STATIC_LIBRARIES := PluginProtocolStatic

include $(BUILD_SHARED_LIBRARY)

$(call import-module,protocols/android)
