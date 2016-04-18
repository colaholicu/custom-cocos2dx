//
//  PluginChartboost.m
//  PluginChartboost
//
//  Created by Iosif Murariu on 03/06/2015.
//  Copyright (c) 2015 Iosif Murariu. All rights reserved.
//

#import "PluginChartboost.h"
#import "AdsWrapper.h"

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);

@implementation PluginChartboost

@synthesize debug = __debug;

- (void) setDebugMode: (BOOL) isDebugMode
{
    OUTPUT_LOG( @"PluginChartboost setDebugMode invoked(%d)", isDebugMode );
    self.debug = isDebugMode;
}

- (void) Initialize: (NSDictionary*) params
{
    
    NSString* appId = [params objectForKey:@"Param1"];
    NSString* appSignature = [params objectForKey:@"Param2"];
    
    // Initialize the Chartboost library
    [Chartboost startWithAppId:@"55cb56275b1453296cf7f7a5"
                  appSignature:@"c95abfe9fe47fc59b959306760ffda242d41c92f"
                      delegate:self];
    
    [Chartboost cacheInterstitial:CBLocationGameOver];
    [Chartboost cacheInterstitial:CBLocationMainMenu];
    [Chartboost cacheMoreApps:CBLocationHomeScreen];
}

- (void) ShowStaticAd: (NSNumber*) location
{
    int nValue = [location intValue];
    
    switch (nValue)
    {
        case 0:
            [Chartboost showInterstitial:CBLocationGameOver];
            break;
        case 1:
            [Chartboost showInterstitial:CBLocationMainMenu];
            break;
        default:
            [Chartboost showInterstitial:CBLocationGameOver];
            break;
    }
}

- (void)didDismissInterstitial:(CBLocation)location
{
    NSString *errorString = [NSString stringWithFormat:@"%s ---- didDismissInterstitial", __FUNCTION__];
    [AdsWrapper onAdsResult:self withRet:kAdsDismissed withMsg:errorString];
}

- (void)didCloseInterstitial:(CBLocation)location
{
    NSString *errorString = [NSString stringWithFormat:@"%s ---- didCloseInterstitial", __FUNCTION__];
    [AdsWrapper onAdsResult:self withRet:kAdsDismissed withMsg:errorString];
}

- (void)didClickInterstitial:(CBLocation)location
{
    NSString *errorString = [NSString stringWithFormat:@"%s ---- didClickInterstitial", __FUNCTION__];
    [AdsWrapper onAdsResult:self withRet:kAdsDismissed withMsg:errorString];
}


/*
 * didFailToLoadInterstitial
 *
 * This is called when an interstitial has failed to load. The error enum specifies
 * the reason of the failure
 */

- (void)didFailToLoadInterstitial:(NSString *)location withError:(CBLoadError)error {
    NSString *errorString = nil;
    switch(error){
        case CBLoadErrorInternetUnavailable: {
            errorString = [NSString stringWithFormat:@"%s ----- Failed to load Interstitial at location %@, no Internet connection !", __FUNCTION__, location];
        } break;
        case CBLoadErrorInternal: {
            errorString = [NSString stringWithFormat:@"%s ----- Failed to load Interstitial at location %@, internal error !", __FUNCTION__, location];
        } break;
        case CBLoadErrorNetworkFailure: {
            errorString = [NSString stringWithFormat:@"%s ----- Failed to load Interstitial at location %@, network error !", __FUNCTION__, location];
        } break;
        case CBLoadErrorWrongOrientation: {
            errorString = [NSString stringWithFormat:@"%s ----- Failed to load Interstitial at location %@, wrong orientation !", __FUNCTION__, location];
        } break;
        case CBLoadErrorTooManyConnections: {
            errorString = [NSString stringWithFormat:@"%s ----- Failed to load Interstitial at location %@, too many connections !", __FUNCTION__, location];
        } break;
        case CBLoadErrorFirstSessionInterstitialsDisabled: {
            errorString = [NSString stringWithFormat:@"%s ----- Failed to load Interstitial at location %@, first session !", __FUNCTION__, location];
        } break;
        case CBLoadErrorNoAdFound : {
            errorString = [NSString stringWithFormat:@"%s ----- Failed to load Interstitial at location %@, no ad found !", __FUNCTION__, location];
        } break;
        case CBLoadErrorSessionNotStarted : {
            errorString = [NSString stringWithFormat:@"%s ----- Failed to load Interstitial at location %@, session not started !", __FUNCTION__, location];
        } break;
        case CBLoadErrorNoLocationFound : {
            errorString = [NSString stringWithFormat:@"%s ----- Failed to load Interstitial at location %@, missing location parameter !", __FUNCTION__, location];
        } break;
        default: {
            errorString = [NSString stringWithFormat:@"%s ----- Failed to load Interstitial at location %@, unknown error !", __FUNCTION__, location];
        }
    }
    
    [AdsWrapper onAdsResult:self withRet:kUnknownError withMsg:errorString];
}

/*
 * didFailToLoadMoreApps
 *
 * This is called when the more apps page has failed to load for any reason
 *
 * Is fired on:
 * - No network connection
 * - No more apps page has been created (add a more apps page in the dashboard)
 * - No publishing campaign matches for that user (add more campaigns to your more apps page)
 *  -Find this inside the App > Edit page in the Chartboost dashboard
 */

- (void)didFailToLoadMoreApps:(CBLoadError)error {
    NSString *errorString = nil;
    switch(error){
        case CBLoadErrorInternetUnavailable: {
            errorString = [NSString stringWithFormat:@"%s ----- Failed to load More Apps, no Internet connection !", __FUNCTION__];
        } break;
        case CBLoadErrorInternal: {
            errorString = [NSString stringWithFormat:@"%s ----- Failed to load More Apps, internal error !", __FUNCTION__];
        } break;
        case CBLoadErrorNetworkFailure: {
            errorString = [NSString stringWithFormat:@"%s ----- Failed to load More Apps, network error !", __FUNCTION__];
        } break;
        case CBLoadErrorWrongOrientation: {
            errorString = [NSString stringWithFormat:@"%s ----- Failed to load More Apps, wrong orientation !", __FUNCTION__];
        } break;
        case CBLoadErrorTooManyConnections: {
            errorString = [NSString stringWithFormat:@"%s ----- Failed to load More Apps, too many connections !", __FUNCTION__];
        } break;
        case CBLoadErrorFirstSessionInterstitialsDisabled: {
            errorString = [NSString stringWithFormat:@"%s ----- Failed to load More Apps, first session !", __FUNCTION__];
        } break;
        case CBLoadErrorNoAdFound : {
            errorString = [NSString stringWithFormat:@"%s ----- Failed to load More Apps, no ad found !", __FUNCTION__];
        } break;
        case CBLoadErrorSessionNotStarted : {
            errorString = [NSString stringWithFormat:@"%s ----- Failed to load More Apps, session not started !", __FUNCTION__];
        } break;
        case CBLoadErrorNoLocationFound : {
            errorString = [NSString stringWithFormat:@"%s ----- Failed to load More Apps, missing location parameter !", __FUNCTION__];
        } break;
        default: {
            errorString = [NSString stringWithFormat:@"%s ----- Failed to load More Apps, unknown error !", __FUNCTION__];
        }
    }
    
    [AdsWrapper onAdsResult:self withRet:kUnknownError withMsg:errorString];
}
@end
