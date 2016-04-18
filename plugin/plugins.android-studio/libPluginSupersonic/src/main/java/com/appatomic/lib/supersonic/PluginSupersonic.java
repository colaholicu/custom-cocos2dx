package com.appatomic.lib.supersonic;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.Map;
import java.util.Set;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLConnection;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Bundle;
import android.util.Log;
import android.app.DownloadManager;
import android.net.Uri;

import com.google.android.gms.common.GooglePlayServicesNotAvailableException;
import com.google.android.gms.common.GooglePlayServicesRepairableException;
import com.supersonic.mediationsdk.model.Placement;
import com.supersonic.mediationsdk.sdk.InterstitialListener;
import com.supersonic.mediationsdk.sdk.RewardedVideoListener;
import com.supersonic.mediationsdk.sdk.OfferwallListener;
import com.supersonic.mediationsdk.sdk.Supersonic;
import com.supersonic.mediationsdk.sdk.SupersonicFactory;
import com.supersonic.mediationsdk.logger.LogListener;
import com.supersonic.mediationsdk.logger.SupersonicLogger;
import com.supersonic.mediationsdk.logger.SupersonicError;

import com.google.android.gms.ads.identifier.AdvertisingIdClient;

import org.cocos2dx.plugin.*;

public class PluginSupersonic implements InterfaceAds, InterstitialListener, RewardedVideoListener, OfferwallListener {

	private final static String LOG_TAG = "PluginSupersonic";

	private static Activity mContext = null;
	private static InterfaceAds mAdapter = null;

	private static boolean bDebug = true;

	private Supersonic mMediationAgent;
	private boolean bHasInterstitials;
	private boolean bHasRewardedVideos;

	protected static void LogE(String msg, Exception e) {
		Log.e(LOG_TAG, msg, e);
		e.printStackTrace();
	}

	protected static void LogD(String msg) {
		if (true) {
			Log.d(LOG_TAG, msg);
		}
	}

	public PluginSupersonic(Context context) {
		mContext = (Activity) context;
		mAdapter = this;

		mMediationAgent = SupersonicFactory.getInstance();

		PluginWrapper.addListener(new PluginListener() {

			@Override
			public void onResume() {
				if (mMediationAgent != null) {
					mMediationAgent.onResume(mContext);
				}
			}

			@Override
			public void onPause() {
				if (mMediationAgent != null) {
					mMediationAgent.onPause(mContext);
				}
			}

			@Override
			public void onDestroy() {

			}

			@Override
			public boolean onActivityResult(int arg0, int arg1, Intent arg2) {

				boolean result = true;
				//result = mCallbackManager.onActivityResult(arg0, arg1, arg2);
				return result;
			}
		});

		mMediationAgent.setLogListener(new LogListener() {
			@Override
			public void onLog(SupersonicLogger.SupersonicTag tag, String message, int logLevel) {
				LogD(">: " + message);
			}
		});

		bHasInterstitials = false;
		bHasRewardedVideos = false;
	}


	public void Initialize(String param)
	{
		LogD(">Initialize : " + param);

		try {
			String userId = AdvertisingIdClient.getAdvertisingIdInfo(mContext).getId();

			mMediationAgent.setInterstitialListener(this);
			mMediationAgent.initInterstitial(mContext, param, userId);

			mMediationAgent.setRewardedVideoListener(this);
			mMediationAgent.initRewardedVideo(mContext, param, userId);

			mMediationAgent.setRewardedVideoListener(this);
			mMediationAgent.initOfferwall(mContext, param, userId);
		}
		catch (IOException ex)
		{
			LogD("Fail to initialize Supersonic managers / IOException: " + ex.getLocalizedMessage());
		}
		catch (GooglePlayServicesRepairableException ex)
		{
			LogD("Fail to initialize Supersonic managers / GooglePlayServicesRepairableException: " + ex.getLocalizedMessage());
		}
		catch (GooglePlayServicesNotAvailableException ex)
		{
			LogD("Fail to initialize Supersonic managers / GooglePlayServicesNotAvailableException: " + ex.getLocalizedMessage());
		}
	}

	public void ShowVideoAd(String param)
	{
		LogD(">ShowVideoAd " + param);

		if (param.equals("wo"))
		{
			mMediationAgent.showOfferwall();
		}
		else if (param.equals("is"))
		{
			mMediationAgent.showInterstitial();
		}
		else if (param.equals("rv"))
		{
			mMediationAgent.showRewardedVideo();
		}
	}

	public int HasCachedISVideoAd()
	{
		return bHasInterstitials ? 1 : 0;
	}

	public int HasCachedRVVideoAd()
	{
		return bHasRewardedVideos ? 1 : 0;
	}


	@Override
	public void configDeveloperInfo(Hashtable<String, String> hashtable) {

	}

	@Override
	public void showAds(Hashtable<String, String> hashtable, int i) {

	}

	@Override
	public void hideAds(Hashtable<String, String> hashtable) {

	}

	@Override
	public void queryPoints() {

	}

	@Override
	public void spendPoints(int i) {

	}

	@Override
	public void setDebugMode(boolean b) {
		bDebug = b;
	}

	@Override
	public String getSDKVersion() {
		return null;
	}

	@Override
	public String getPluginVersion() {
		return "1";
	}

	// interstitial apis
	@Override
	public void onInterstitialInitSuccess() {
		LogD(">onInterstitialInitSuccess");
	}

	@Override
	public void onInterstitialInitFail(SupersonicError var1) {
		LogD("onInterstitialInitFail " + var1.getErrorMessage());
	}

	@Override
	public void onInterstitialAvailability(boolean var1) {
		LogD("onInterstitialAvailability " + (var1 ? "TRUE" : "FALSE"));

		bHasInterstitials = var1;
	}

	@Override
	public void onInterstitialShowSuccess() {
		LogD("onInterstitialShowSuccess");
	}

	@Override
	public void onInterstitialShowFail(SupersonicError var1) {
		LogD("onInterstitialShowFail " + var1.getErrorMessage());
	}

	@Override
	public void onInterstitialAdClicked() {
		LogD("onInterstitialAdClicked");

		AdsWrapper.onAdsResult(mAdapter, AdsWrapper.RESULT_CODE_PointsSpendSucceed, "Interstitials clicked with succes!");
	}

	@Override
	public void onInterstitialAdClosed() {
		LogD("onInterstitialAdClosed");

		AdsWrapper.onAdsResult(mAdapter, AdsWrapper.RESULT_CODE_AdsDismissed, "Interstitials closed!");
	}


	// reward video apis
	@Override
	public void onRewardedVideoInitSuccess() {
		LogD("onRewardedVideoInitSuccess");
	}

	@Override
	public void onRewardedVideoInitFail(SupersonicError supersonicError) {
		LogD("onRewardedVideoInitFail " + supersonicError.getErrorMessage());
	}

	@Override
	public void onRewardedVideoAdOpened() {
		LogD("onRewardedVideoAdOpened");
	}

	@Override
	public void onRewardedVideoAdClosed() {
		LogD("onRewardedVideoAdClosed");

		AdsWrapper.onAdsResult(mAdapter, AdsWrapper.RESULT_CODE_AdsDismissed, "Rewarded Video closed!");
	}

	@Override
	public void onVideoAvailabilityChanged(boolean b) {
		LogD("onVideoAvailabilityChanged " + (b ? "TRUE" : "FALSE"));

		bHasRewardedVideos = b;
	}

	@Override
	public void onVideoStart() {
		LogD("onVideoStart");
	}

	@Override
	public void onVideoEnd() {
		LogD("onVideoEnd");
	}

	@Override
	public void onRewardedVideoAdRewarded(Placement placement) {
		LogD("onVideoEnd " + placement.getPlacementName() + " " + placement.getRewardName() + " " + placement.getRewardAmount());

		AdsWrapper.onAdsResult(mAdapter, AdsWrapper.RESULT_CODE_PointsSpendSucceed, "Rewarded Video ended with succes!");
	}

	@Override
	public void onRewardedVideoShowFail(SupersonicError supersonicError) {
		LogD("onRewardedVideoShowFail " + supersonicError.getErrorMessage());
	}

	// offer wall apis
	@Override
	public void onOfferwallInitSuccess() {
		LogD("onOfferwallInitSuccess");
	}

	@Override
	public void onOfferwallInitFail(SupersonicError supersonicError) {
		LogD("onOfferwallInitFail " + supersonicError.getErrorMessage());
	}

	@Override
	public void onOfferwallOpened() {
		LogD("onOfferwallOpened");
	}

	@Override
	public void onOfferwallShowFail(SupersonicError supersonicError) {
		LogD("onOfferwallShowFail " + supersonicError.getErrorMessage());
	}

	@Override
	public boolean onOfferwallAdCredited(int i, int i1, boolean b) {
		LogD("onOfferwallAdCredited");
		return false;
	}

	@Override
	public void onGetOfferwallCreditsFail(SupersonicError supersonicError) {
		LogD("onGetOfferwallCreditsFail " + supersonicError.getErrorMessage());
	}

	@Override
	public void onOfferwallClosed() {
		LogD("onOfferwallClosed");
	}
}
