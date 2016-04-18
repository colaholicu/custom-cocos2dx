/****************************************************************************
Copyright (c) 2013 nickflink
Copyright (c) 2014 martell malone <martell malone at  mail dot com>
Copyright (c) 2014 cocos2d-x.org
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

// NB. All Util classes are From google Jan 2014 and a subject to their respective Apache License 
// (We can update to newer versions when they are added)

package com.appatomic.lib.leanplum;

import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.util.Log;

import com.leanplum.Leanplum;
import com.leanplum.LeanplumApplication;
import com.leanplum.LeanplumPushService;
import com.leanplum.annotations.Parser;
import com.leanplum.annotations.Variable;
import com.leanplum.callbacks.VariablesChangedCallback;
import com.leanplum.messagetemplates.MessageTemplates;

import org.cocos2dx.plugin.InterfaceAnalytics;
import org.cocos2dx.plugin.PluginListener;
import org.cocos2dx.plugin.PluginWrapper;
import org.json.JSONObject;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;

import xmlwise.Plist;
import xmlwise.XmlParseException;


public class PluginLeanplum extends LeanplumApplication implements InterfaceAnalytics, PluginListener {

    // Debug tag, for logging
    static final String TAG = "Leanplum";

    static boolean bDebug = false;
    Context mContext;
    static InterfaceAnalytics mAdapter;
    
    static Map<String, Object> __pricesDict = new HashMap<String, Object>();
	static Map<String, Object> __varsDict = new HashMap<String, Object>();
    
    @Variable public static Map<String, Object> Prices;
	@Variable public static Map<String, Object> Variables;
        
    // MAIN FUNCTIONS FOR LEANPLUM
    protected static Map<String, Object> cachedPrices() {
    	return __pricesDict;
    }
    
    protected static void setCachedPrices(Map<String, Object> prices) {
    	__pricesDict.clear();
    	__pricesDict.putAll(prices);
    }

	protected static Map<String, Object> cachedVars() {
		return __varsDict;
	}

	protected static void setCachedVars(Map<String, Object> vars) {
		__varsDict.clear();
		__varsDict.putAll(vars);
	}
    
    protected static void setPluginDebugMode(boolean isDebugMode) {
    	bDebug = isDebugMode;
    }
    
    protected static boolean pluginDebugMode() {
    	return bDebug;
    }
    
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
    
    public void Initialize(String appKey, String secretKey) {
    	
    	LogD("initializing LeanPlum android plugin..");
    	// load prices file first
    	LoadPrices();
    	
    	Leanplum.setApplicationContext(PluginWrapper.getContext());
    	Parser.parseVariables(this);
    	
    	MessageTemplates.register(PluginWrapper.getContext());
    	
    	Leanplum.setAppIdForDevelopmentMode(appKey, secretKey);

		LeanplumPushService.setGcmSenderId("1033341036899");

//    	LeanplumPushService.setCustomizer( new LeanplumPushNotificationCustomizer() {
//    		
//			@Override
//			public void customize(Builder builder, Bundle bundle) {
//				LogD("On Handle intent");
//			}
//		});
//    	
    	Leanplum.start( PluginWrapper.getContext() );
    	
    	Leanplum.addVariablesChangedHandler( new VariablesChangedCallback() {
    		
			@Override
			public void variablesChanged() {
				
				LogD("onVariablesChangedCallback..");
				
				Map<String, Object> allPrices = new HashMap<String, Object>( Prices );
				setCachedPrices(allPrices);

				List<String> keysPrices = new ArrayList<String>(allPrices.keySet());
				for (String key: keysPrices) {
				    LogD(key + ": " + allPrices.get(key));
				}
				
				// write this file to disk
				File pricesFile = new File( PluginWrapper.getContext().getFilesDir().getAbsolutePath() + "prices.plist" );


				Map<String, Object> allVars = new HashMap<String, Object>( Variables );
				setCachedVars(allVars);

				List<String> keysVars = new ArrayList<String>(allVars.keySet());
				for (String key: keysVars) {
					LogD(key + ": " + allVars.get(key));
				}

				// write this file to disk
				File varsFile = new File( PluginWrapper.getContext().getFilesDir().getAbsolutePath() + "variables.plist" );

				try {
					
					LogD("Writing new Plist file to disk");
					
					Plist.store(PluginLeanplum.cachedPrices(), pricesFile);
					Plist.store(PluginLeanplum.cachedVars(), varsFile);
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
		} );
    }
    
    public void LoadPrices() {
    	LogD( "loading prices and variables..." );
    	try {
			initObjects();
		} catch (IOException e) {
			e.printStackTrace();
		}
    	LogD( "loading prices and variables completed!" );
    }
    
    private void initObjects() throws IOException {
    	
    	LogD("PluginWrapper.getContext().getFilesDir().getAbsolutePath() = " + PluginWrapper.getContext().getFilesDir().getAbsolutePath());
    	
    	//get prices plist file
    	File pricesFile = new File( PluginWrapper.getContext().getFilesDir().getAbsolutePath() + "prices.plist" );
		File varsFile = new File( PluginWrapper.getContext().getFilesDir().getAbsolutePath() + "variables.plist" );

		//PRICES
    	//copy file from apk to docs dir
    	if (!pricesFile.exists()) {
    		LogD("price config file not in documents directory...creating and encrypting file!");
    		
    		try {
				InputStream inputStream = PluginWrapper.getContext().getAssets().open("configs/prices.plist");
				try {
					FileOutputStream outputStream = new FileOutputStream(pricesFile);
					try {
						byte[] buf = new byte[1024];
	                    int len;
	                    while ((len = inputStream.read(buf)) > 0) {
	                        outputStream.write(buf, 0, len);
	                    }
					} finally {
						outputStream.close();
					}
				}  finally {
					inputStream.close();
				}
    		} catch (IOException e) {
				throw new IOException("Cound not open file prices.plist! ", e);
			}
    		
    		LogD("plist price config copied to documents directory!");
    		
    		//encrypt this file maybe
    		
    	} 
    	
    	//get this plist convert it to map and save it as cached
    	pricesFile = new File( PluginWrapper.getContext().getFilesDir().getAbsolutePath() + "prices.plist" );
    	
    	if (pricesFile.exists())
    	{
    		LogD("plist price config found in documents directory!");
    		
    		Map<String, Object> properties = null;
    		properties = getMapFromPlist(pricesFile);
    		
    		PluginLeanplum.setCachedPrices(properties);
    	}
    	
    	Prices = new HashMap<String, Object>( PluginLeanplum.cachedPrices() );

		//VARIABLES
		//copy file from apk to docs dir
		if (!varsFile.exists()) {
			LogD("variables config file not in documents directory...creating and encrypting file!");

			try {
				InputStream inputStream = PluginWrapper.getContext().getAssets().open("configs/variables.plist");
				try {
					FileOutputStream outputStream = new FileOutputStream(varsFile);
					try {
						byte[] buf = new byte[1024];
						int len;
						while ((len = inputStream.read(buf)) > 0) {
							outputStream.write(buf, 0, len);
						}
					} finally {
						outputStream.close();
					}
				}  finally {
					inputStream.close();
				}
			} catch (IOException e) {
				throw new IOException("Cound not open file variables.plist! ", e);
			}

			LogD("plist variable config copied to documents directory!");

			//encrypt this file maybe

		}

		//get this plist convert it to map and save it as cached
		varsFile = new File( PluginWrapper.getContext().getFilesDir().getAbsolutePath() + "variables.plist" );

		if (varsFile.exists())
		{
			LogD("plist variable config found in documents directory!");

			Map<String, Object> properties = null;
			properties = getMapFromPlist(varsFile);

			PluginLeanplum.setCachedVars(properties);
		}

		Variables = new HashMap<String, Object>( PluginLeanplum.cachedVars() );
	}

	private Map<String, Object> getMapFromPlist(File pricesFile) {
		
		Map<String, Object> properties = null;
		try {
			properties = Plist.load(pricesFile);
		} catch (XmlParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		return properties;
	}

	public String getPriceForItem(String item) {
		LogD("getting price for "+ item );

		String priceId = "0";

		if (PluginLeanplum.cachedPrices().containsKey(item))
		{
			priceId = PluginLeanplum.cachedPrices().get(item).toString();
		}

    	return priceId;
    }

	public String getStringVar(String item) {
		LogD("getting variable value for "+ item );

		String retVal = "0";

		if (PluginLeanplum.cachedVars().containsKey(item))
		{
			retVal = PluginLeanplum.cachedVars().get(item).toString();
		}

		return retVal;
	}

	public int getIntVar(String item) {
		LogD("getting variable value for " + item);

		String value = PluginLeanplum.cachedVars().get(item).toString();

		int retval = Integer.parseInt(value);

		return retval;
	}

    protected static void LogE(String msg, Exception e) {
        Log.e(TAG, msg, e);
        e.printStackTrace();
    }

    protected static void LogD(String msg) {
        if (true) {
            Log.d(TAG, msg);
        }
    }

    public PluginLeanplum(Context context) {
        mContext = context;
        mAdapter = this;
    }

    @Override
    public void setDebugMode(boolean debug) {
        bDebug = debug;
    }

    @Override
    public String getSDKVersion() {
        return "IAPv3Jan2014";
    }

    @SuppressWarnings("unused")
	private boolean networkReachable() {
        boolean bRet = false;
        try {
            ConnectivityManager conn = (ConnectivityManager)mContext.getSystemService(Context.CONNECTIVITY_SERVICE);
            NetworkInfo netInfo = conn.getActiveNetworkInfo();
            bRet = (null == netInfo) ? false : netInfo.isAvailable();
        } catch (Exception e) {
            LogE("Fail to check network status", e);
        }
        LogD("NetWork reachable : " + bRet);
        return bRet;
    }

    @Override
    public String getPluginVersion() {
        return "0.3.0";
    }

	@Override
	public void onDestroy() {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void onPause() {		
		// TODO Auto-generated method stub
	}

	@Override
	public void onResume() {
		// TODO Auto-generated method stub
	}

	@Override
	public void logError(String arg0, String arg1) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void logEvent(String arg0) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void logEvent(String arg0, Hashtable<String, String> arg1) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void logTimedEventBegin(String arg0) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void logTimedEventEnd(String arg0) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void setCaptureUncaughtException(boolean arg0) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void setSessionContinueMillis(int arg0) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void startSession(String arg0) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void stopSession() {
		// TODO Auto-generated method stub
		
	}

	@Override
	public boolean onActivityResult(int arg0, int arg1, Intent arg2) {
		// TODO Auto-generated method stub
		return false;
	}
}