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
//import java.util.Iterator;

import org.json.JSONObject;

import android.app.Activity;
import android.content.Context;
import android.util.Log;
//import android.widget.AnalogClock;

import com.google.android.gms.analytics.*;

import org.cocos2dx.libGoogleAnalytics.*;

public class PIGoogleAnalytics implements InterfaceAnalytics {

    private Context m_pContext = null;
    protected static String TAG = "GoogleAnalytics";
    protected static Tracker s_pGlobalTracker = null;
    
    protected static void LogE(String msg, Exception e) {
        Log.e(TAG, msg, e);
        e.printStackTrace();
    }

    private static boolean isDebug = false;
    protected static void LogD(String msg) {
        if (isDebug) {
            Log.d(TAG, msg);
        }
    }

    public PIGoogleAnalytics(Context context) {
    	m_pContext = context;
    }
    
    synchronized Tracker getGlobalTracker() {
    	
    	if (s_pGlobalTracker == null) {
    		GoogleAnalytics analytics = GoogleAnalytics.getInstance(m_pContext);
    		
    		if (m_pContext instanceof Activity) {
                analytics.enableAutoActivityReports(((Activity) m_pContext).getApplication());
    		}
    		
    		s_pGlobalTracker = analytics.newTracker("UA-55285017-1");
    		s_pGlobalTracker.setSessionTimeout(300);
    		s_pGlobalTracker.enableAutoActivityTracking(true);
    	}
    	
        return s_pGlobalTracker;
      }
    
    @Override
    public void startSession(String appKey) {
        LogD("startSession invoked!");
        //final String curKey = appKey;
        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                try {
                    Class.forName("android.os.AsyncTask");
                } catch (ClassNotFoundException e) {
                   e.printStackTrace();
                }
                getGlobalTracker();
                
                if (m_pContext instanceof Activity) {
                	GoogleAnalytics analytics = GoogleAnalytics.getInstance(m_pContext);
                    analytics.reportActivityStart((Activity) m_pContext);
        		}
            }
            
        });
    }

    @Override
    public void stopSession() {
        LogD("stopSession invoked!");
        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
            	if (m_pContext instanceof Activity) {
            		GoogleAnalytics analytics = GoogleAnalytics.getInstance(m_pContext);
            		analytics.reportActivityStop((Activity) m_pContext);
            	}
            }
        });
    }

    @Override
    public void setCaptureUncaughtException(boolean isEnabled) {
        LogD("setCaptureUncaughtException invoked!");
        final boolean curEnable = isEnabled;
        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
            	getGlobalTracker().enableExceptionReporting(curEnable);
            }
        });
    }

    @Override
    public void setDebugMode(boolean isDebugMode) {
        isDebug = isDebugMode;
        final boolean curDebugMode = isDebug;
        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
            	GoogleAnalytics analytics = GoogleAnalytics.getInstance(m_pContext);
            	analytics.getLogger().setLogLevel(curDebugMode ? Logger.LogLevel.VERBOSE : Logger.LogLevel.VERBOSE);
            }
        });
    }

    @Override
    public void logError(String errorId, String message) {
        LogD("logError invoked!");
        final String curID = errorId;
        final String curMsg = message;
        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
            	getGlobalTracker().send(new HitBuilders.EventBuilder()
										                .setCategory("error")
										                .setAction(curID)
										                .setLabel(curMsg)
										                .build());
            }
        });
    }

    @Override
    public void logEvent(String eventId) {
        LogD("logEvent(eventId) invoked!");
        final String curID = eventId;
        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
            	getGlobalTracker().send(new HitBuilders.EventBuilder()
										                .setCategory("event")
										                .setAction(curID)
										                .build());
            }
        });
    }

    @Override
    public String getSDKVersion() {
        return "v4 rev19";
    }

    @Override
    public String getPluginVersion() {
        return "0.0.1";
    }
    
    protected void longLogEvent(JSONObject eventInfo) {
        LogD("logTimedEventBegin invoked!");
        final JSONObject curInfo = eventInfo;
        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                try{
                	getGlobalTracker().send(new HitBuilders.EventBuilder()
											                .setCategory(curInfo.getString("Param1"))
											                .setAction(curInfo.getString("Param2"))
											                .setLabel(curInfo.getString("Param3"))
											                .setValue(curInfo.getLong("Param4"))
											                .build());
                } catch(Exception e){
                    LogE("Exception in logTimedEventBegin", e);
                }
            }
        });
    }

	@Override
	public void setSessionContinueMillis(int millis) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void logEvent(String eventId, Hashtable<String, String> paramMap) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void logTimedEventBegin(String eventId) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void logTimedEventEnd(String eventId) {
		// TODO Auto-generated method stub
		
	}
}
