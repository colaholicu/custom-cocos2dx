//
//  PIVungle.h
//  PluginVungle
//
//  Created by Daniel Popescu on 08/10/14.
//  Copyright (c) 2014 Supperhippo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <VungleSDK/VungleSDK.h>

#import "InterfaceAds.h"

@interface PIVungle : NSObject <InterfaceAds, VungleSDKDelegate, VungleSDKLogger>

@property BOOL debug;
@property (nonatomic, retain) NSString*             appId;
@property (nonatomic, retain) VungleSDK*            vungleSDK;
@property (nonatomic, assign) int                   points;

// INTERFACE ADS
- (void) configDeveloperInfo: (NSMutableDictionary*) devInfo;
- (void) showAds: (NSMutableDictionary*) info position:(int) pos;
- (void) setDebugMode: (BOOL) debug;
- (NSString*) getSDKVersion;
- (NSString*) getPluginVersion;

// CUSTOM METHODS
- (BOOL) isCachedAdAvailable;

// VUNGLE DELEGATES
- (void)vungleSDKLog:(NSString *)message;

-(void)vungleSDKwillShowAd;
-(void)vungleSDKwillCloseAdWithViewInfo:(NSDictionary *)viewInfo willPresentProductSheet:(BOOL)willPresentProductSheet;
-(void)vungleSDKwillCloseProductSheet:(id)productSheet;
-(void)vungleSDKhasCachedAdAvailable;

@end
