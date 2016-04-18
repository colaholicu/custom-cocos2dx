/****************************************************************************
Copyright (c) 2012-2013 cocos2d-x.org

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
#include "PluginJniHelper.h"
#include <android/log.h>
#include <string.h>
#include <pthread.h>

#if 1
#define  LOG_TAG    "PluginJniHelper"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
#else
#define  LOGD(...) 
#endif

#define JAVAVM    cocos2d::PluginJniHelper::getJavaVM()

using namespace std;

extern "C"
{
    //////////////////////////////////////////////////////////////////////////
    // java vm helper function
    //////////////////////////////////////////////////////////////////////////

    static jclass _getClassIDByLoader(const char *className) {
        if (NULL == className) {
            return NULL;
        }

        JNIEnv* env = cocos2d::PluginJniHelper::getEnv();

        jstring _jstrClassName = env->NewStringUTF(className);

        jclass _clazz = (jclass) env->CallObjectMethod(cocos2d::PluginJniHelper::classloader,
                                                       cocos2d::PluginJniHelper::loadclassMethod_methodID,
                                                       _jstrClassName);

        if (NULL == _clazz) {
            LOGD("Classloader failed to find class of %s", className);
        }

        env->DeleteLocalRef(_jstrClassName);

        return _clazz;
    }

    static jclass _getClassID(const char *className, JNIEnv *env)
    {
        JNIEnv *pEnv = env;
        jclass ret = 0;

        do 
        {
            if (cocos2d::PluginJniHelper::classloader)
            {
                ret = _getClassIDByLoader(className);
                break;
            }

            if (! pEnv)
            {
                pEnv = cocos2d::PluginJniHelper::getEnv();
                if (! pEnv)
                {
                    break;
                }
            }

            ret = pEnv->FindClass(className);
            if (! ret)
            {
                 LOGD("Failed to find class of %s", className);
                break;
            }
        } while (0);

        return ret;
    }
}

namespace cocos2d {

static void _detachCurrentThread(void* a) {
    cocos2d::PluginJniHelper::getJavaVM()->DetachCurrentThread();
}

static pthread_key_t pjh_g_key;
JavaVM* PluginJniHelper::_psJavaVM = NULL;
jmethodID PluginJniHelper::loadclassMethod_methodID = NULL;
jobject PluginJniHelper::classloader = NULL;

JavaVM* PluginJniHelper::getJavaVM() {
    pthread_t thisthread = pthread_self();
    //LOGD("JniHelper::getJavaVM(), pthread_self() = %ld", thisthread);
    return _psJavaVM;
}

void PluginJniHelper::setJavaVM(JavaVM *javaVM) {
    pthread_t thisthread = pthread_self();
    LOGD("JniHelper::setJavaVM(%p), pthread_self() = %ld", javaVM, thisthread);
    _psJavaVM = javaVM;

    pthread_key_create(&pjh_g_key, _detachCurrentThread);
}

JNIEnv* PluginJniHelper::cacheEnv(JavaVM* jvm) {
    JNIEnv* _env = nullptr;
    // get jni environment
    jint ret = jvm->GetEnv((void**)&_env, JNI_VERSION_1_4);

    switch (ret) {
        case JNI_OK :
            // Success!
            pthread_setspecific(pjh_g_key, _env);
            return _env;

        case JNI_EDETACHED :
            // Thread not attached
            if (jvm->AttachCurrentThread(&_env, nullptr) < 0)
            {
                LOGD("Failed to get the environment using AttachCurrentThread()");

                return nullptr;
            } else {
                // Success : Attached and obtained JNIEnv!
                pthread_setspecific(pjh_g_key, _env);
                return _env;
            }

        case JNI_EVERSION :
            // Cannot recover from this error
            LOGD("JNI interface version 1.4 not supported");
        default :
            LOGD("Failed to get the environment using GetEnv()");
            return nullptr;
    }
}

JNIEnv* PluginJniHelper::getEnv() {
    JNIEnv *_env = (JNIEnv *)pthread_getspecific(pjh_g_key);
    if (_env == nullptr)
        _env = PluginJniHelper::cacheEnv(_psJavaVM);
    return _env;
}

bool PluginJniHelper::getStaticMethodInfo(PluginJniMethodInfo &methodinfo, const char *className, const char *methodName, const char *paramCode)
{
    if ((NULL == className) ||
        (NULL == methodName) ||
        (NULL == paramCode)) {
        return false;
    }

    JNIEnv *pEnv = PluginJniHelper::getEnv();
    if (!pEnv) {
        LOGD("Failed to get JNIEnv");
        return false;
    }

    jclass classID = _getClassID(className, pEnv);
    if (! classID) {
        LOGD("Failed to find class %s", className);
        return false;
    }

    jmethodID methodID = pEnv->GetStaticMethodID(classID, methodName, paramCode);
    if (! methodID) {
        if(pEnv->ExceptionCheck())
        {
            pEnv->ExceptionClear();
        }
        LOGD("Failed to find static method id of %s", methodName);
        return false;
    }

    methodinfo.classID = classID;
    methodinfo.env = pEnv;
    methodinfo.methodID = methodID;
    return true;
}

bool PluginJniHelper::getMethodInfo(PluginJniMethodInfo &methodinfo, const char *className, const char *methodName, const char *paramCode)
{
    if ((NULL == className) ||
        (NULL == methodName) ||
        (NULL == paramCode)) {
        return false;
    }

    JNIEnv *pEnv = PluginJniHelper::getEnv();
    if (!pEnv) {
        return false;
    }

    jclass classID = _getClassID(className, pEnv);
    if (! classID) {
        LOGD("Failed to find class %s", className);
        return false;
    }

    jmethodID methodID = pEnv->GetMethodID(classID, methodName, paramCode);
    if (! methodID) {
        if(pEnv->ExceptionCheck())
        {
            pEnv->ExceptionClear();
        }
        LOGD("Failed to find static method id of %s in class %s with params %s", methodName, className, paramCode);
        return false;
    }

    methodinfo.classID = classID;
    methodinfo.env = pEnv;
    methodinfo.methodID = methodID;

    return true;
}

string PluginJniHelper::jstring2string(jstring jstr)
{
    if (jstr == NULL) {
        LOGD("PluginJniHelper jstring2string jstr is null");
        return "";
    }

    JNIEnv *pEnv = PluginJniHelper::getEnv();
    if (! pEnv) {
        LOGD("PluginJniHelper jstring2string pEnv is null");
        return "";
    }

    //LOGD("PluginJniHelper jstring2string GetStringUTFChars");
    const char* chars = pEnv->GetStringUTFChars(jstr, NULL);
    std::string ret(chars);
    pEnv->ReleaseStringUTFChars(jstr, chars);
    //LOGD("PluginJniHelper jstring2string ReleaseStringUTFChars %s", ret.c_str());

    return ret;
}

std::shared_ptr<std::map<std::string, std::string> > PluginJniHelper::JSONObject2Map(jobject json)
{
	auto stdmap = std::make_shared<std::map<std::string, std::string> >();
	JNIEnv* env = getEnv();
	jclass c_json = env->FindClass("org/json/JSONObject");
	jclass c_iterator = env->FindClass("java/util/Iterator");
	jmethodID m_keys = env->GetMethodID(c_json, "keys", "()Ljava/util/Iterator;");
	jmethodID m_hasNext = env->GetMethodID(c_iterator, "hasNext", "()Z");
	jmethodID m_next = env->GetMethodID(c_iterator, "next", "()Ljava/lang/Object;");
	jmethodID m_getString = env->GetMethodID(c_json, "getString", "(Ljava/lang/String;)Ljava/lang/String;");
	jstring jKeyString = NULL;
	jstring jValueString = NULL;
	jobject jKeys = env->CallObjectMethod(json, m_keys);
	
	while(env->CallBooleanMethod(jKeys, m_hasNext))
	{
		jKeyString = (jstring)(env->CallObjectMethod(jKeys, m_next));
		jValueString = (jstring)(env-> CallObjectMethod(json, m_getString, jKeyString));

		stdmap->insert(std::make_pair(jstring2string(jKeyString), jstring2string(jValueString)));
	}

	env->DeleteLocalRef(jKeys);
	if(jKeyString)
		env->DeleteLocalRef(jKeyString);
	if(jValueString)
		env->DeleteLocalRef(jValueString);
	env->DeleteLocalRef(c_json);
	env->DeleteLocalRef(c_iterator);

	return stdmap;
}

std::shared_ptr<std::map<std::string, std::string> > PluginJniHelper::jsonString2Map(jstring jsonstring)
{
    JNIEnv* env = getEnv();
    jclass clazz = env->FindClass("org/json/JSONObject");
    jmethodID constructor = env->GetMethodID(clazz, "<init>", "(Ljava/lang/String;)V");
    jobject jsonobj = env->NewObject(clazz, constructor, jsonstring);

    auto map = JSONObject2Map(jsonobj);

    env->DeleteLocalRef(jsonobj);
    env->DeleteLocalRef(clazz);

    return map;
}

bool PluginJniHelper::setClassLoaderFrom(jobject nativeactivityinstance) {
    PluginJniMethodInfo _getclassloaderMethod;
    if (!PluginJniHelper::getMethodInfo_DefaultClassLoader(_getclassloaderMethod,
                                                     "android/app/NativeActivity",
                                                     "getClassLoader",
                                                     "()Ljava/lang/ClassLoader;")) {
        return false;
    }

    jobject _c = cocos2d::PluginJniHelper::getEnv()->CallObjectMethod(nativeactivityinstance,
                                                                _getclassloaderMethod.methodID);

    if (NULL == _c) {
        return false;
    }

    PluginJniMethodInfo _m;
    if (!PluginJniHelper::getMethodInfo_DefaultClassLoader(_m,
                                                     "java/lang/ClassLoader",
                                                     "loadClass",
                                                     "(Ljava/lang/String;)Ljava/lang/Class;")) {
        return false;
    }

    PluginJniHelper::classloader = _c;
    PluginJniHelper::loadclassMethod_methodID = _m.methodID;

    return true;
}

bool PluginJniHelper::getMethodInfo_DefaultClassLoader(PluginJniMethodInfo &methodinfo,
                                                     const char *className,
                                                     const char *methodName,
                                                     const char *paramCode)
{
    if ((NULL == className) ||
        (NULL == methodName) ||
        (NULL == paramCode)) {
        return false;
    }

    JNIEnv *pEnv = PluginJniHelper::getEnv();
    if (!pEnv) {
        return false;
    }

    jclass classID = pEnv->FindClass(className);
    if (! classID) {
        LOGD("Failed to find class %s", className);
        return false;
    }

    jmethodID methodID = pEnv->GetMethodID(classID, methodName, paramCode);
    if (! methodID) {
        LOGD("Failed to find the method id of %s in class %s with params %s", methodName, className, paramCode);
        return false;
    }

    methodinfo.classID = classID;
    methodinfo.env = pEnv;
    methodinfo.methodID = methodID;

    pEnv->DeleteLocalRef(classID);
    return true;
}

} // end of namespace cocos2d
