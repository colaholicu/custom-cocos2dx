//
//  PluginSupersonic.m
//  PluginSupersonic
//
//  Created by Cristian Boghina on 12/01/2016.
//  Copyright (c) 2015 Cristian Boghina. All rights reserved.
//

#import "PluginSupersonic.h"
#import "AdsWrapper.h"

#import <Supersonic/Supersonic.h>

#define OUTPUT_LOG(...)     if (true) NSLog(__VA_ARGS__);


@implementation PluginSupersonic


@synthesize debug = __debug;
@synthesize rvAdsAvailable = __rvAdsAvailable;
@synthesize isAdsAvailable = __isAdsAvailable;


- (void) setDebugMode: (BOOL) isDebugMode
{
    OUTPUT_LOG( @"PluginSupersonic setDebugMode invoked(%d)", isDebugMode );
    self.debug = isDebugMode;
}


- (void) Initialize: (NSString*)appId
{
    OUTPUT_LOG(@"PluginSupersonic (supersonic stuff) : Initialize");
    
    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    [[Supersonic sharedInstance] setOWDelegate:self];
    [[Supersonic sharedInstance] initOWWithAppKey:appId withUserId:idfv];
    
    [[Supersonic sharedInstance] setRVDelegate:self];
    [[Supersonic sharedInstance] initRVWithAppKey:appId withUserId:idfv];
    
    [[Supersonic sharedInstance] setISDelegate:self];
    [[Supersonic sharedInstance] initISWithAppKey:appId withUserId:idfv];
        
    __rvAdsAvailable = FALSE;
    __isAdsAvailable = FALSE;
}


-(void)ShowVideoAd:(NSString *) adsType
{
    if ([adsType isEqualToString:@"rv"])
    {
        [[Supersonic sharedInstance] showRV];
    }
    else if ([adsType isEqualToString:@"ow"])
    {
        [[Supersonic sharedInstance] showOW];
    }
    else if ([adsType isEqualToString:@"is"])
    {
        [[Supersonic sharedInstance] showIS];
    }
}


-(NSNumber*)HasCachedRVVideoAd
{
    return @(__rvAdsAvailable ? 1 : 0);
}


-(NSNumber*)HasCachedISVideoAd
{
    return @(__isAdsAvailable ? 1 : 0);
}


// --OW------------------------------------------------------------------


-(void)supersonicOWInitSuccess
{
    OUTPUT_LOG(@"PluginSupersonic : supersonicOWInitSuccess");
}

- (void)supersonicOWShowSuccess
{
    OUTPUT_LOG(@"PluginSupersonic : supersonicOWShowSuccess");
}

- (void)supersonicOWInitFailedWithError:(NSError *)error
{
    OUTPUT_LOG(@"PluginSupersonic : supersonicOWInitFailedWithError %@", [error localizedDescription]);
}

- (void)supersonicOWShowFailedWithError:(NSError *)error
{
    OUTPUT_LOG(@"PluginSupersonic : supersonicOWShowFailedWithError %@", [error localizedDescription]);
}

- (void)supersonicOWAdClosed
{
    [AdsWrapper onAdsResult:self withRet:kAdsDismissed withMsg:@"PluginSupersonic: OW Ad Closed !"];
    
    OUTPUT_LOG(@"PluginSupersonic : supersonicOWAdClosed");
}

- (BOOL)supersonicOWDidReceiveCredit:(NSDictionary *)creditInfo
{
    [AdsWrapper onAdsResult:self withRet:kPointsSpendSucceed withMsg:@"PluginSupersonic: OW Did Receive Credit !"];
    
    OUTPUT_LOG(@"PluginSupersonic : supersonicOWDidReceiveCredit %@", creditInfo);
    
    return true;
}

- (void)supersonicOWFailGettingCreditWithError:(NSError *)error
{
    OUTPUT_LOG(@"PluginSupersonic : supersonicOWFailGettingCreditWithError %@", [error localizedDescription]);
}

// --RV------------------------------------------------------------------

- (void)supersonicRVInitSuccess
{
    OUTPUT_LOG(@"PluginSupersonic : supersonicRVInitSuccess");
}

- (void)supersonicRVInitFailedWithError:(NSError *)error
{
    OUTPUT_LOG(@"PluginSupersonic : supersonicRVInitFailedWithError %@", [error localizedDescription]);
}

- (void)supersonicRVAdAvailabilityChanged:(BOOL)hasAvailableAds
{
    __rvAdsAvailable = hasAvailableAds;
    
    OUTPUT_LOG(@"PluginSupersonic : supersonicRVAdAvailabilityChanged %@", hasAvailableAds ? @"TRUE" : @"FALSE");
}

- (void)supersonicRVAdRewarded:(SupersonicPlacementInfo*)placementInfo
{
    [AdsWrapper onAdsResult:self withRet:kPointsSpendSucceed withMsg:@"PluginSupersonic: RV Ad Closed !"];
    
    OUTPUT_LOG(@"PluginSupersonic : supersonicRVAdRewarded\n%@\n%@\n%@", [placementInfo placementName], [placementInfo rewardName], [placementInfo rewardAmount]);
}

- (void)supersonicRVAdFailedWithError:(NSError *)error
{
    OUTPUT_LOG(@"PluginSupersonic : supersonicRVInitFailedWithError %@", [error localizedDescription]);
}

- (void)supersonicRVAdOpened
{
    OUTPUT_LOG(@"PluginSupersonic : supersonicRVAdOpened");
}

- (void)supersonicRVAdClosed
{
    [AdsWrapper onAdsResult:self withRet:kAdsDismissed withMsg:@"PluginSupersonic: RV Ad Closed !"];
    
    OUTPUT_LOG(@"PluginSupersonic : supersonicRVAdClosed");
}

- (void)supersonicRVAdStarted
{
    OUTPUT_LOG(@"PluginSupersonic : supersonicRVAdStarted");
}

- (void)supersonicRVAdEnded
{
    OUTPUT_LOG(@"PluginSupersonic : supersonicRVAdEnded");
}

// ----------------------

- (void)supersonicISInitSuccess
{
    OUTPUT_LOG(@"PluginSupersonic : supersonicISInitSuccess");
}

- (void)supersonicISInitFailedWithError:(NSError *)error
{
    OUTPUT_LOG(@"PluginSupersonic : supersonicISInitFailedWithError %@", [error localizedDescription]);
}

- (void)supersonicISShowSuccess
{
    OUTPUT_LOG(@"PluginSupersonic : supersonicISShowSuccess");
}

- (void)supersonicISShowFailWithError:(NSError *)error
{
    OUTPUT_LOG(@"PluginSupersonic : supersonicISShowFailWithError %@", [error localizedDescription]);
}

- (void)supersonicISAdAvailable:(BOOL)available
{
    __isAdsAvailable = available;

    OUTPUT_LOG(@"PluginSupersonic : supersonicISAdAvailable %@", (available ? @"TRUE" : @"FALSE"));
}

- (void)supersonicISAdClicked
{
    [AdsWrapper onAdsResult:self withRet:kPointsSpendSucceed withMsg:@"PluginSupersonic: IS Ad Clicked !"];
    
    OUTPUT_LOG(@"PluginSupersonic : supersonicISAdClicked");
}

- (void)supersonicISAdClosed
{
    [AdsWrapper onAdsResult:self withRet:kAdsDismissed withMsg:@"PluginSupersonic: IS Ad Closed !"];
    
    OUTPUT_LOG(@"PluginSupersonic : supersonicISAdClosed");
}


@end
