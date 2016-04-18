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

package com.appatomic.lib.mixpanel;

import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.AsyncTask;
import android.os.Environment;
import android.os.StatFs;
import android.util.Log;

import com.google.android.gms.ads.identifier.AdvertisingIdClient;
import com.google.android.gms.common.GooglePlayServicesNotAvailableException;
import com.google.android.gms.common.GooglePlayServicesRepairableException;
import com.mixpanel.android.mpmetrics.MixpanelAPI;

import org.cocos2dx.plugin.InterfaceAnalytics;
import org.cocos2dx.plugin.PluginListener;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.text.DecimalFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.TimeZone;


public class PluginMixpanel implements InterfaceAnalytics, PluginListener {

    // Debug tag, for logging
    private static final String TAG = "Mixpanel";

    private static boolean bDebug = true;
    private final Context mContext;
    private static InterfaceAnalytics mAdapter;

	private MixpanelAPI mMixpanelAPI;


    protected static void setPluginDebugMode(boolean isDebugMode) {
    	bDebug = isDebugMode;
    }

    protected static boolean pluginDebugMode() {
    	return bDebug;
    }

	///////////////
	// FUNCTIONS //
	//   USED    //
	///////////////

	@Override
	public void startSession(String appKey) {
		mMixpanelAPI = MixpanelAPI.getInstance(mContext, appKey);
	}

	@Override
	public void stopSession() {
		// TODO Auto-generated method stub

	}

	public String DoFirstLaunch() {

        String idfaString = getIDFA();

		LogD("idfaString : " + idfaString);

        mMixpanelAPI.identify(idfaString);

        Date date = new Date();
        String dateString = getStringFromDate(date, TimeZone.getTimeZone("UTC"));

		try {
        	JSONObject propertiesSuper = new JSONObject();
        	propertiesSuper.putOpt("user_id",       idfaString);
			propertiesSuper.putOpt("install_date", dateString);

			LogD("propertiesSuper : " + propertiesSuper.toString());

			mMixpanelAPI.registerSuperPropertiesOnce(propertiesSuper);

        	JSONObject propertiesPeople = new JSONObject();
        	propertiesPeople.putOpt("mixpanel_id",  idfaString);
        	propertiesPeople.putOpt("user_id",      idfaString);
        	propertiesPeople.putOpt("install_date", dateString);

			LogD("propertiesPeople : " + propertiesPeople.toString());

        	mMixpanelAPI.getPeople().setOnce(propertiesPeople);

		} catch (JSONException e) {
			e.printStackTrace();
		}

        InitializeWithId(idfaString);

		return idfaString;
	}

	private void InitializeWithId(String mixpanelID) {

		mMixpanelAPI.identify(mixpanelID);

		LogD("super properties : " + mMixpanelAPI.getSuperProperties().toString());
	}

	public void AppendFacebookInfo(JSONObject info) {

		new AsyncTask<JSONObject, Void, Void>() {

			@Override
			protected Void doInBackground(JSONObject... params) {

				String mixPanelID 			= params[0].optString("Param1");
				String facebookFirstName 	= params[0].optString("Param2");
				String facebookLastName 	= params[0].optString("Param3");
				String playerID 			= params[0].optString("Param4");

				mMixpanelAPI.identify(mixPanelID);
				mMixpanelAPI.alias(playerID, mixPanelID);

				try {

					JSONObject properties = new JSONObject();
					properties.putOpt("first_name", facebookFirstName);
					properties.putOpt("last_name", facebookLastName);

					LogD("propertiesPeople : " + properties.toString());

					mMixpanelAPI.registerSuperProperties(properties);
					mMixpanelAPI.getPeople().set(properties);

				} catch (JSONException e) {
					e.printStackTrace();
				}

				return null;
			}
		}.execute(info);
	}

	public void addDeviceToken(JSONObject deviceToken) {
		// Android is not using this function
	}

	public String getInstallDate(String strMixpanelId) {

		mMixpanelAPI.identify(strMixpanelId);

		//get current date if the install_date is empty
		Date date = new Date();

		JSONObject properties = mMixpanelAPI.getSuperProperties();
		String installDateString = properties.optString("install_date", getStringFromDate(date, TimeZone.getTimeZone("UTC")));

		LogD("installDateString " + installDateString);

		return installDateString;
	}

	public int getNumberOfDaysPassed(String strDate) {

		SimpleDateFormat dateFormatter = new SimpleDateFormat("yyyy-MM-dd", Locale.getDefault());
		dateFormatter.setTimeZone(TimeZone.getTimeZone("UTC"));

		Date installDate = new Date();
		try {
			installDate = dateFormatter.parse(strDate);
		} catch (ParseException e) {
			e.printStackTrace();
		}

		Calendar currentDateCal = toCalendar( System.currentTimeMillis() );
		Calendar installDateCal = toCalendar( installDate.getTime() );

		long milisCurrent = currentDateCal.getTimeInMillis();
		long milisInstall = installDateCal.getTimeInMillis();

		long diff = Math.abs(milisCurrent - milisInstall);

		return (int)(diff / (24 * 60 * 60 * 1000));
	}

	public String getIPAddress() {

		boolean preferIPv4 = true;

		try {
			List<NetworkInterface> interfaces = Collections.list(NetworkInterface.getNetworkInterfaces());

			for (NetworkInterface networkInterface : interfaces) {
				List<InetAddress> addresses = Collections.list(networkInterface.getInetAddresses());

				for (InetAddress address : addresses) {
					if (!address.isLoopbackAddress()) {
						String addressString = address.getHostAddress();

						boolean isIPv4 = addressString.indexOf(':') >= 0;

						if (!isIPv4)
							preferIPv4 = false;

						if (preferIPv4) {
							return addressString;
						} else {
							int delimitator = addressString.indexOf('%'); // drop ip6 zone suffix
							return delimitator<0 ? addressString.toUpperCase() : addressString.substring(0, delimitator).toUpperCase();
						}
					}
				}
			}
		} catch (Exception ex) { ex.printStackTrace(); } // for now eat exceptions
		return "127.0.0.1";
	}

	public String getFreeDiskSpace() {

		return bytesToHuman( getFreeMemory() );
	}

	public void UpdateProperties(JSONObject info) {

		new AsyncTask<JSONObject, Void, Void>() {

			@Override
			protected Void doInBackground(JSONObject... params) {

				String mixpanelID 		= params[0].optString("Param1");
				JSONObject properties	= params[0].optJSONObject("Param2");

				mMixpanelAPI.identify(mixpanelID);

				LogD("properties " + properties);

				Iterator<String> iterator = properties.keys();
				while (iterator.hasNext()) {

					String key = iterator.next();

					try {
						Object value = properties.get(key);

						JSONObject property = new JSONObject();
						property.put(key, value);

						mMixpanelAPI.registerSuperProperties(property);

					} catch (JSONException e) {
						e.printStackTrace();
					}
				}

				mMixpanelAPI.getPeople().set(properties);

				LogD("CURRENT SUPER properties " + mMixpanelAPI.getSuperProperties().toString());

				return null;
			}
		}.execute(info);
	}

	public void WriteDataToDisk(String mixpanelID) {

		//do nothing
//		mMixpanelAPI.identify(mixpanelID);
	}

	@Override
	public void logEvent(String eventID) {

		LogD("event " + eventID);

		Date date = new Date();
		String dateString = getStringFromDate(date, TimeZone.getDefault());

		JSONObject properties = new JSONObject();
		try {
			properties.putOpt("local_timestamp", "X" + dateString);

			mMixpanelAPI.track(eventID, properties);

		} catch (JSONException e) {
			e.printStackTrace();
		}

	}

	@Override
	public void logEvent(String eventID, Hashtable<String, String> paramMap) {

		LogD("event " + eventID);

		Date date = new Date();
		String dateString = getStringFromDate(date, TimeZone.getDefault());

		JSONObject properties = new JSONObject(paramMap);

		try {

			properties.putOpt("local_timestamp", "X" + dateString);

			LogD("properties " + properties.toString() );

			mMixpanelAPI.track(eventID, properties);

		} catch (JSONException e) {
			e.printStackTrace();
		}
	}

	@Override
	public void logTimedEventBegin(String eventID) {

		LogD("event " + eventID);

		mMixpanelAPI.timeEvent(eventID);

	}

	@Override
	public void logTimedEventEnd(String eventID) {

		LogD("event " + eventID);

		Date date = new Date();
		String dateString = getStringFromDate(date, TimeZone.getDefault());

		JSONObject properties = new JSONObject();
		try {
			properties.putOpt("local_timestamp", "X" + dateString);

			mMixpanelAPI.track(eventID, properties);

		} catch (JSONException e) {
			e.printStackTrace();
		}

	}

	///////////////
	//  HELPER   //
	// FUNCTIONS //
	///////////////

	private static final boolean FINAL_CONSTANT_IS_LOCAL = true;

	private static String getLogTagWithMethod() {
		if (FINAL_CONSTANT_IS_LOCAL) {
			Throwable stack = new Throwable().fillInStackTrace();
			StackTraceElement[] trace = stack.getStackTrace();
			return trace[0].getClassName() + "." + trace[0].getMethodName() + ":" + trace[0].getLineNumber();
		} else {
			return TAG;
		}
	}

    private static void LogE(String msg, Exception e) {
        Log.e(TAG, msg, e);
        e.printStackTrace();
    }

    private static void LogD(String msg) {
        if (bDebug) {
			Log.d(TAG, msg);
//            Log.d(getLogTagWithMethod(), msg);
        }
    }

    public PluginMixpanel(Context context) {
        mContext = context;
        mAdapter = this;
    }

	private String getIDFA() {
		AdvertisingIdClient.Info adInfo = null;

        try {
            adInfo = AdvertisingIdClient.getAdvertisingIdInfo(mContext);
        } catch (IOException | GooglePlayServicesNotAvailableException | GooglePlayServicesRepairableException e) {
            e.printStackTrace();
        }

		return adInfo != null ? adInfo.getId() : "";
	}

	private String getStringFromDate(Date date, TimeZone timeZone) {

		SimpleDateFormat dateFormatter = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault());
		dateFormatter.setTimeZone(timeZone);

		return dateFormatter.format(date);
	}

	private Calendar toCalendar(long timestamp)
	{
		Calendar calendar = Calendar.getInstance();
		calendar.setTimeInMillis(timestamp);
		calendar.set(Calendar.HOUR_OF_DAY, 0);
		calendar.set(Calendar.MINUTE, 0);
		calendar.set(Calendar.SECOND, 0);
		calendar.set(Calendar.MILLISECOND, 0);
		return calendar;
	}

	private long getFreeMemory()
	{
		StatFs statFs = new StatFs(Environment.getRootDirectory().getAbsolutePath());
		return (statFs.getAvailableBlocksLong() * statFs.getBlockSizeLong());
	}

	private String floatForm (double d)
	{
		return new DecimalFormat("#.##").format(d);
	}

	private String bytesToHuman (long size)
	{
		long Kb = 	   1024;
		long Mb = Kb * 1024;
		long Gb = Mb * 1024;
		long Tb = Gb * 1024;
		long Pb = Tb * 1024;
		long Eb = Pb * 1024;

		if (size <  Kb)                 return floatForm(        size     ) + " byte";
		if (size >= Kb && size < Mb)    return floatForm((double)size / Kb) + " Kb";
		if (size >= Mb && size < Gb)    return floatForm((double)size / Mb) + " Mb";
		if (size >= Gb && size < Tb)    return floatForm((double)size / Gb) + " Gb";
		if (size >= Tb && size < Pb)    return floatForm((double)size / Tb) + " Tb";
		if (size >= Pb && size < Eb)    return floatForm((double)size / Pb) + " Pb";
		if (size >= Eb)                 return floatForm((double)size / Eb) + " Eb";

		return "???";
	}

    @Override
    public void setDebugMode(boolean debug) {
        bDebug = debug;
    }

	@Override
	public void logError(String s, String s1) {

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
            bRet = (null != netInfo) && netInfo.isAvailable();
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
	public void onResume() {

	}

	@Override
	public void onPause() {

	}

	@Override
	public void onDestroy() {
		mMixpanelAPI.flush();
	}

	@Override
	public boolean onActivityResult(int i, int i1, Intent intent) {
		return false;
	}

	@Override
	public void setSessionContinueMillis(int i) {

	}

	@Override
	public void setCaptureUncaughtException(boolean b) {

	}
}