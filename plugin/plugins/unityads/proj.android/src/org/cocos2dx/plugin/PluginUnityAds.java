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
package org.cocos2dx.plugin;

import java.util.Hashtable;

import android.app.Activity;
import android.content.Context;
import android.util.Log;

import com.unity3d.ads.android.UnityAds;

public class PluginUnityAds implements InterfaceAds {

    // Debug tag, for logging
    static final String TAG = "PluginUnityAds";

    // (arbitrary) request code for the purchase flow

    static boolean bDebug = false;
    Context mContext;

	private String m_GameIdString;
	
	private UnityAdsListener m_AdsListener;
	
    static InterfaceAds mAdapter;

    public static void LogE(String msg, Exception e) {
        Log.e(TAG, msg, e);
        e.printStackTrace();
    }

    public static void LogD(String msg) {
        if (bDebug) {
            Log.d(TAG, msg);
        }
    }

    public PluginUnityAds(Context context) {
        mContext = context;
        mAdapter = this;
    }

    @Override
    public void configDeveloperInfo(Hashtable<String, String> cpInfo) {
        LogD("initDeveloperInfo invoked " + cpInfo.toString());
        try {
            
        } catch (Exception e) {
            LogE("Developer info is wrong!", e);
        }
    }

    @Override
    public void setDebugMode(boolean debug) {
        //TODO: fix this
        //It's possible setDebug don't work at the first time because init was happening on another thread
    }

    @Override
    public String getSDKVersion() {
        return "IAPv3Jan2014";
    }

    @Override
    public String getPluginVersion() {
        return "0.3.0";
    }

	@Override
	public void hideAds(Hashtable<String, String> arg0) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void queryPoints() {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void showAds(Hashtable<String, String> arg0, int arg1) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void spendPoints(int arg0) {
		// TODO Auto-generated method stub
		
	}
	
	public void Initialize(String eventInfo) {
		LogD("Initialize invoked! event : " + eventInfo);
		
		try {
			m_GameIdString	= eventInfo;
			
			m_AdsListener = new UnityAdsListener();
			m_AdsListener.setAdsInterface(this);
			
			UnityAds.init((Activity)PluginWrapper.getContext(), m_GameIdString, m_AdsListener);
			UnityAds.setListener(m_AdsListener);
			UnityAds.setDebugMode(bDebug);
	    
	    } catch (Exception e) {
	    	LogE("Exception in Initialize", e);
	    }
	}
	
	public void ShowVideoAd(String eventInfo) {
		LogD("ShowVideoAd invoked! event : " + eventInfo);
		
		UnityAds.setZone(eventInfo);
		
		if (UnityAds.canShow()) {
			
			AdsWrapper.onAdsResult(this, AdsWrapper.RESULT_CODE_AdsReceived, "PluginUnityAds: Video Ad available!");
			
			UnityAds.show();
		}
		else {
			AdsWrapper.onAdsResult(this, AdsWrapper.RESULT_CODE_AdNotAvailable, "PluginUnityAds: Video Ad not available!");
		}
	}
	
	public boolean HasCachedVideoAd() {
		return UnityAds.canShow();
	}
}