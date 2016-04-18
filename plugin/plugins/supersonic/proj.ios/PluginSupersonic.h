//
//  PluginSupersonic.h
//  PluginSupersonic
//
//  Created by Cristian Boghina on 12/01/2016.
//  Copyright (c) 2015 Cristian Boghina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InterfaceAds.h"

#import <Supersonic/Supersonic.h>

@interface PluginSupersonic : NSObject <InterfaceAds, SupersonicOWDelegate, SupersonicRVDelegate, SupersonicISDelegate>
{
    
}

@property BOOL debug;
@property BOOL rvAdsAvailable;
@property BOOL isAdsAvailable;


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
 interfaces of PluginSupersonic
 */
- (void) Initialize:  (NSString*) appId;
- (void) ShowVideoAd: (NSString*) adsType; //ow - offerwall, rv - reward video, is - interstitial
- (NSNumber*) HasCachedRVVideoAd;
- (NSNumber*) HasCachedISVideoAd;

@end
