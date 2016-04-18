//
//  PluginChartboost.h
//  PluginChartboost
//
//  Created by Iosif Murariu on 03/06/2015.
//  Copyright (c) 2015 Iosif Murariu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InterfaceAds.h"
#import <CommonCrypto/CommonDigest.h>
#import <AdSupport/AdSupport.h>

#import <Chartboost/Chartboost.h>

@interface PluginChartboost : NSObject <InterfaceAds, ChartboostDelegate>
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
 interfaces of ChartboostDelegate
 */
- (void)didFailToLoadMoreApps:(CBLoadError)error;
- (void)didFailToLoadInterstitial:(NSString *)location withError:(CBLoadError)error;
- (void)didDismissInterstitial:(CBLocation)location;
- (void)didCloseInterstitial:(CBLocation)location;
- (void)didClickInterstitial:(CBLocation)location;

/**
 interfaces of PluginChartboost
 */
- (void) Initialize: (NSDictionary*) params;
- (void) ShowStaticAd: (NSNumber*) location;
@end
