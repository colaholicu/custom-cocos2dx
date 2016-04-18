//
//  PluginUnityAds.m
//  PluginUnityAds
//
//  Created by Iosif Murariu on 03/06/2015.
//  Copyright (c) 2015 Iosif Murariu. All rights reserved.
//

#import "PluginUnityAds.h"
#import "AdsWrapper.h"

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);

@implementation PluginUnityAds

@synthesize debug = __debug;

- (void) setDebugMode: (BOOL) isDebugMode
{
    OUTPUT_LOG( @"PluginUnityAds setDebugMode invoked(%d)", isDebugMode );
    self.debug = isDebugMode;
}

- (void) Initialize: (NSString*)appId
{
    [[UnityAds sharedInstance] startWithGameId:appId andViewController:[AdsWrapper getCurrentRootViewController]];
    [[UnityAds sharedInstance] setDelegate:self];
    
}

-(void)ShowVideoAd:(NSString *)zoneId
{
    OUTPUT_LOG(@"PluginUnityAds : Video Ad requested!");
    
    [[UnityAds sharedInstance] setZone:zoneId];
    
    if ([[UnityAds sharedInstance] canShow])
    {
        [AdsWrapper onAdsResult:self withRet:kAdsReceived withMsg:@"PluginUnityAds: Video Ad available!"];
        
        [[UnityAds sharedInstance] show];
    }
    else
    {
        [AdsWrapper onAdsResult:self withRet:kAdNotAvailable withMsg:@"PluginUnityAds: Video Ad not available!"];
    }
}

-(NSNumber*)HasCachedVideoAd
{
    return @([[UnityAds sharedInstance] canShow]);
}

-(void)unityAdsVideoCompleted:(NSString *)rewardItemKey skipped:(BOOL)skipped
{
    if (skipped)
    {
        [AdsWrapper onAdsResult:self withRet:kPointsSpendFailed withMsg:@"PluginUnityAds: Video Ad dismissed, no reward received!"];
    }
    else
    {
        [AdsWrapper onAdsResult:self withRet:kPointsSpendSucceed withMsg:@"PluginUnityAds: Video ad reward successful!"];
    }
    
    OUTPUT_LOG(@"PluginUnityAds : Video Ad completed");
}

-(void)unityAdsDidHide
{
    [AdsWrapper onAdsResult:self withRet:kAdsShown withMsg:@"PluginUnityAds: Video Ad shown!"];
}

-(void)unityAdsWillHide
{
    [AdsWrapper onAdsResult:self withRet:kAdsDismissed withMsg:@"PluginUnityAds: Video Ad will dismiss!"];
}

@end
