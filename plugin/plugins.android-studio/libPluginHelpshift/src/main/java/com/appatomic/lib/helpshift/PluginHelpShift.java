package com.appatomic.lib.helpshift;


import java.io.IOException;
import java.util.Hashtable;

import android.app.Activity;
import android.content.Context;

import android.util.Log;

import org.json.JSONObject;
import org.cocos2dx.plugin.*;
import com.helpshift.Core;
import com.helpshift.support.Support;


public class PluginHelpShift implements InterfaceAnalytics{

	private final static String LOG_TAG = "PluginHelpShift";
	private static Activity mContext = null;
	private static boolean bDebug = true;
    private static String apiKey;
    private static String domain;
    private static String appid;

    public void Initialize(JSONObject info) {
        //TODO:
        LogD("Initialize invoked " + info.toString());

        try {
            final String appKey	 = info.getString("Param1");
            final String domain = info.getString("Param2");
            final String appid = info.getString("Param3");

            PluginWrapper.runOnMainThread(new Runnable() {
                @Override
                public void run() {
                    Initialize(appKey, domain, appid);
                }
            });
        } catch (Exception e) {
            LogE("HelpShift Initialization Failed ", e);
        }
    }

    public void Initialize(String iapiKey, String idomain, String iappid)
    {
        apiKey = iapiKey;
        domain = idomain;
        appid = iappid;
        LogD("apiKey: " + apiKey + " domain: " + domain + " appid: " + appid);

        java.util.HashMap config = new java.util.HashMap();
        Core.init(Support.getInstance());
        Core.install(mContext.getApplication(), apiKey, domain, appid, config);
        LogD("finished Core.install()");
    }

    protected static void LogE(String msg, Exception e) {
		Log.e(LOG_TAG, msg, e);
		e.printStackTrace();
	}

	protected static void LogD(String msg) {
		if (bDebug) {
			Log.d(LOG_TAG, msg);
		}
	}

	public PluginHelpShift(Context context) {
		mContext = (Activity) context;
	}

    void addDeviceToken(String ptrDeviceToken)
    {
        Support.getInstance()._registerDeviceToken(mContext, ptrDeviceToken);
    }

    void ShowFAQ()
    {
        Support.showFAQs(mContext);
    }

    void ShowHelp()
    {
        Support.showSingleFAQ(mContext, "QUESTION_PUBLISH_ID");
    }

    void HandleRemoteNotification(String strNotificationInfo)
    {
    }

    void HandleLocalNotification(String ptrNotification)
    {
    }

    @Override
    public void startSession(String s)
    {
    }

    public void stopSession()
    {
    }

    @Override
    public void setSessionContinueMillis(int i) {

    }

    @Override
    public void setCaptureUncaughtException(boolean b) {

    }

    public void setDebugMode(boolean isDebugMode)
    {
        bDebug = isDebugMode;
    }

    @Override
    public void logError(String s, String s1) {
        LogD("PluginApsalar error s1: " + s + " s2: " + s1);
    }

    @Override
    public void logEvent(String eventId)
    {
    }

    @Override
    public void logEvent(String s, Hashtable<String, String> hashtable)
    {
    }

    @Override
    public void logTimedEventBegin(String s) {

    }

    @Override
    public void logTimedEventEnd(String s) {

    }

    @Override
    public String getSDKVersion() {
        return null;
    }

    @Override
    public String getPluginVersion() {
        return null;
    }
}
