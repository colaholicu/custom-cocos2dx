package org.cocos2dx.plugin;

import com.unity3d.ads.android.IUnityAdsListener;

public class UnityAdsListener implements IUnityAdsListener {

	private InterfaceAds m_AdsInterface;

	public void setAdsInterface(InterfaceAds adInterface) {
		
		m_AdsInterface = adInterface;
	}
	
	@Override
	public void onHide() {
		// TODO Auto-generated method stub
		AdsWrapper.onAdsResult(m_AdsInterface, AdsWrapper.RESULT_CODE_AdsDismissed, "PluginUnityAds: Video Ad will dismiss!");
	}

	@Override
	public void onShow() {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void onVideoStarted() {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void onVideoCompleted(String rewardItemKey, boolean skipped) {
		// TODO Auto-generated method stub
		PluginUnityAds.LogD("PluginUnityAds : Video Ad completed");
		
		if (skipped) {
			AdsWrapper.onAdsResult(m_AdsInterface, AdsWrapper.RESULT_CODE_PointsSpendFailed, "PluginUnityAds: Video Ad dismissed, no reward received!");
		}
		else {
			AdsWrapper.onAdsResult(m_AdsInterface, AdsWrapper.RESULT_CODE_PointsSpendSucceed, "PluginUnityAds: Video ad reward successful!");
		}
	}

	@Override
	public void onFetchCompleted() {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void onFetchFailed() {
		// TODO Auto-generated method stub
		
	}

}
