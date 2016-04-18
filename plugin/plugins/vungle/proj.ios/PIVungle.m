//
//  PIVungle.m
//  PluginVungle
//
//  Created by Daniel Popescu on 08/10/14.
//  Copyright (c) 2014 Supperhippo. All rights reserved.
//

#import "PIVungle.h"
#import "AdsWrapper.h"

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);

@implementation PIVungle

@synthesize debug       = __debug;
@synthesize appId       = __appId;
@synthesize vungleSDK   = __vungleSDK;
@synthesize points      = __points;

#pragma mark - INTERFACE ADS

- (void) configDeveloperInfo: (NSMutableDictionary*) devInfo
{
    self.appId = (NSString*)[devInfo objectForKey:@"VungleAppID"];
    
    self.vungleSDK = [VungleSDK sharedSDK];
    [self.vungleSDK startWithAppId:self.appId];
    
    self.vungleSDK.delegate = self;
}

- (void) showAds: (NSMutableDictionary*) info position:(int) pos
{
    if (self.appId == nil || [self.appId length] == 0)
    {
        OUTPUT_LOG(@"configDeveloperInfo() not correctly invoked in Vungle!")
        return;
    }
    
    NSMutableDictionary* newDict = [[NSMutableDictionary alloc] init];
    
    if (info[@"VunglePlayAdOptionKeyShowClose"] != nil)
        [newDict setObject:info[@"VunglePlayAdOptionKeyShowClose"] forKey:VunglePlayAdOptionKeyShowClose];
        
    
    [self.vungleSDK playAd:[AdsWrapper getCurrentRootViewController] withOptions:newDict];
}

- (void) queryPoints
{

}

- (void) spendPoints: (int) points
{
    self.points = points;
}

- (void) setDebugMode: (BOOL) isDebugMode
{
    self.debug = isDebugMode;
    
    [self.vungleSDK setLoggingEnabled:isDebugMode];
}

- (NSString*) getSDKVersion
{
    return @"3.0.10";
}

- (NSString*) getPluginVersion
{
    return @"0.0.1";
}

#pragma mark - CUSTOM METHODS

- (BOOL) isCachedAdAvailable
{
    OUTPUT_LOG(@"isCachedAdAvailable %@",[self.vungleSDK isCachedAdAvailable]?@"true":@"false");
    
    return [self.vungleSDK isCachedAdAvailable];
}

#pragma mark - VUNGLE DELEGATES

- (void)vungleSDKLog:(NSString *)message
{
    OUTPUT_LOG(@"vungleSDKLog %@",message);
}

-(void)vungleSDKwillShowAd
{
    OUTPUT_LOG(@"vungleSDKwillShowAd");
    
    [AdsWrapper onAdsResult:self withRet:kAdsShown withMsg:@"Vungle ads will show"];
}

-(void)vungleSDKwillCloseAdWithViewInfo:(NSDictionary *)viewInfo willPresentProductSheet:(BOOL)willPresentProductSheet
{
    BOOL completed      = [(NSNumber*)[viewInfo objectForKey:@"completedView"] boolValue];
    BOOL didDownlaod    = [(NSNumber*)[viewInfo objectForKey:@"didDownlaod"] boolValue];
    double watched      = [(NSNumber*)[viewInfo objectForKey:@"playTime"] doubleValue];
    
    OUTPUT_LOG(@"%@",[NSString stringWithFormat:@"vungleSDKwillCloseAdWithViewInfo   completed: %@   watched: %f   didDownlaod: %@", completed?@"true":@"false", watched, didDownlaod?@"true":@"false"]);
    
    if (completed)
    {
        [AdsWrapper onPlayerGetPoints:self withPoints:self.points];
    }
    
    if (!willPresentProductSheet)
        [AdsWrapper onAdsResult:self withRet:kAdsDismissed withMsg:@"Vungle ads will dismiss"];
}

-(void)vungleSDKwillCloseProductSheet:(id)productSheet
{
    OUTPUT_LOG(@"vungleSDKwillCloseProductSheet");
    
    [AdsWrapper onAdsResult:self withRet:kAdsDismissed withMsg:@"Vungle ads will dismiss"];
}

-(void)vungleSDKhasCachedAdAvailable
{
    OUTPUT_LOG(@"vungleSDKhasCachedAdAvailable");
}

@end
