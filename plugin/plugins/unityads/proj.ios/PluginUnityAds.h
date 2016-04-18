//
//  PluginChartboost.h
//  PluginChartboost
//
//  Created by Iosif Murariu on 03/06/2015.
//  Copyright (c) 2015 Iosif Murariu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InterfaceAds.h"

#import <UnityAds/UnityAds.h>

@interface PluginUnityAds : NSObject <InterfaceAds, UnityAdsDelegate>
{
    
}

@property BOOL debug;



/**
 interfaces of protocol : InterfaceAnalytics
 */
- (void) configDeveloperInfo: (NSMutableDictionary*) devInfo;
- (void) showAds: (NSMutableDictionary*) info position:(int) pos;
- (void) hideAds: (NSMutableDictionary*) info;
- (void) queryPoints;
- (void) spendPoints: (int) points;
- (void) setDebugMode: (BOOL) debug;
- (NSString*) getSDKVersion;
- (NSString*) getPluginVersion;

/**
 interfaces of PluginUnityAds
 */
- (void) Initialize:  (NSString*) appId;
- (void) ShowVideoAd: (NSString*) zoneId;
- (NSNumber*) HasCachedVideoAd;

-(void)unityAdsVideoCompleted:(NSString *)rewardItemKey skipped:(BOOL)skipped;

@end
