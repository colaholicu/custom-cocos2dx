package com.appatomic.lib.apsalar;


import java.io.IOException;
import java.util.Hashtable;

import android.app.Activity;
import android.content.Context;

import android.util.Log;

import org.json.JSONObject;
import org.cocos2dx.plugin.*;
import com.apsalar.sdk.Apsalar;


public class PluginApsalar implements InterfaceAnalytics{

	private final static String LOG_TAG = "PluginApsalar";
	private static Activity mContext = null;
	private static boolean bDebug = true;
    private static String apiKey;
    private static String apiSecret;

    public void Initialize(JSONObject info) {
        //TODO:
        LogD("Initialize invoked " + info.toString());

        try {
            final String appKey	 = info.getString("Param1");
            final String secretKey = info.getString("Param2");

            PluginWrapper.runOnMainThread(new Runnable() {
                @Override
                public void run() {
                    Initialize(appKey, secretKey);
                }
            });
        } catch (Exception e) {
            LogE("LeanPlum Initialization Failed ", e);
        }
    }

    public void Initialize(String iapiKey, String iapiSecret)
    {
        apiKey = iapiKey;
        apiSecret = iapiSecret;
        LogD("apiKey: " + apiKey + " apiSecret: " + apiSecret);

        Apsalar.startSession(mContext, apiKey, apiSecret);
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

	public PluginApsalar(Context context) {
		mContext = (Activity) context;
	}

    @Override
    public void startSession(String s) {
        Apsalar.startSession(mContext, apiKey, apiSecret);
    }

    public void stopSession()
    {
        Apsalar.endSession();
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
        Apsalar.event(eventId);
    }

    @Override
    public void logEvent(String s, Hashtable<String, String> hashtable) {
        Apsalar.event(s);
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
