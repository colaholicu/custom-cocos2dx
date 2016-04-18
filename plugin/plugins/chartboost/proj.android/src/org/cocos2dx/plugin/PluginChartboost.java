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

import org.json.JSONObject;

import com.chartboost.sdk.*;

import android.content.Context;
import android.util.Log;


public class PluginChartboost implements InterfaceAds {

    // Debug tag, for logging
    static final String TAG = "PluginChartboost";

    // (arbitrary) request code for the purchase flow

    static boolean bDebug = true;
    Context mContext;

	private String m_AppIdString;
	private String m_AppSigString;
	
    static InterfaceAds mAdapter;

    protected static void LogE(String msg, Exception e) {
        Log.e(TAG, msg, e);
        e.printStackTrace();
    }

    protected static void LogD(String msg) {
        if (bDebug) {
            Log.d(TAG, msg);
        }
    }

    public PluginChartboost(Context context) {
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
	
	public void Initialize(JSONObject eventInfo) {
		LogD("Initialize invoked! event : " + eventInfo.toString());
		
		try
	    {
			m_AppIdString	= eventInfo.getString("Param1");
			m_AppSigString	= eventInfo.getString("Param2");
	    
	    } catch (Exception e) {
	    	LogE("Exception in Initialize", e);
	    }
	}
}