//
//  PIAdColony.m
//  PluginAdColony
//
//  Created by Daniel Popescu on 10/10/14.
//  Copyright (c) 2014 Superhippo. All rights reserved.
//

#import "PIAdColony.h"
#import "AdsWrapper.h"

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);

@implementation PIAdColony

@synthesize debug           = __debug;
@synthesize appId           = __appId;
@synthesize zoneId          = __zoneId;
@synthesize points          = __points;

#pragma mark - INTERFACE ADS

- (void) configDeveloperInfo: (NSMutableDictionary*) devInfo
{
    self.appId  = (NSString*)[devInfo objectForKey:@"AdColonyAppID"];
    self.debug  = [[devInfo objectForKey:@"AdColonyDebugging"] boolValue];
    self.zoneId = (NSString*)[devInfo objectForKey:@"AdColonyZoneID"];
    
    [AdColony configureWithAppID:self.appId zoneIDs:@[self.zoneId] delegate:self logging:self.debug];
}

- (void) showAds: (NSMutableDictionary*) info position:(int) pos
{
    if (self.appId == nil || [self.appId length] == 0)
    {
        OUTPUT_LOG(@"configDeveloperInfo() not correctly invoked in AdColony!")
        return;
    }
    
//    NSMutableDictionary* newDict = [[NSMutableDictionary alloc] init];
//    
//    if (info[@"VunglePlayAdOptionKeyShowClose"] != nil)
//        [newDict setObject:info[@"VunglePlayAdOptionKeyShowClose"] forKey:VunglePlayAdOptionKeyShowClose];
    
    [AdColony playVideoAdForZone:self.zoneId withDelegate:self];
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
}

- (NSString*) getSDKVersion
{
    return @"2.4.12";
}

- (NSString*) getPluginVersion
{
    return @"0.0.1";
}

#pragma mark - ADCOLONY DELEGATES

- (void) onAdColonyAdStartedInZone:(NSString *)zoneID
{
    [AdsWrapper onAdsResult:self withRet:kAdsShown withMsg:@"AdColony ads will show"];
}

- (void) onAdColonyAdAttemptFinished:(BOOL)shown inZone:(NSString *)zoneID
{
    [AdsWrapper onAdsResult:self withRet:kAdsDismissed withMsg:@"AdColony ads will dismiss"];
    
    if (shown)
        [AdsWrapper onPlayerGetPoints:self withPoints:self.points];
}

@end
