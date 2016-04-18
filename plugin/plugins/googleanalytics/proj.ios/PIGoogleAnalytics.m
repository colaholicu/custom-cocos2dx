/****************************************************************************
Copyright (c) 2012-2013 cocos2d-x.org

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
#import "PIGoogleAnalytics.h"

#include "GoogleAnalytics/GAI.h"
#include "GoogleAnalytics/GAIDictionaryBuilder.h"
#include "GoogleAnalytics/GAITrackedViewController.h"
#include "GoogleAnalytics/GAIFields.h"

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);


@implementation PIGoogleAnalytics


@synthesize debug = __debug;


- (void) startSession: (NSString*) appKey
{
    OUTPUT_LOG( @"GoogleAnalytics PlugInX startSession with %s", [appKey UTF8String] );
    
    [[GAI sharedInstance] trackerWithTrackingId:appKey];
    
    [[[GAI sharedInstance] defaultTracker] allowIDFACollection];
}


- (void) stopSession
{
    OUTPUT_LOG( @"GoogleAnalytics PlugInX stopSession in Google Analytics not available on iOS" );
}


- (void) setSessionContinueMillis: (long) millis
{
    OUTPUT_LOG( @"GoogleAnalytics PlugInX dispatchInterval invoked(%ld)", millis );
    int seconds = (int)(millis / 1000);
    [[GAI sharedInstance] setDispatchInterval: seconds];
}


- (void) setCaptureUncaughtException: (BOOL) isEnabled
{
    OUTPUT_LOG( @"GoogleAnalytics setCaptureUncaughtException" );
    [[GAI sharedInstance] setTrackUncaughtExceptions: isEnabled];
}


- (void) setDebugMode: (BOOL) isDebugMode
{
    OUTPUT_LOG( @"GoogleAnalytics setDebugMode invoked(%d)", isDebugMode );
    self.debug = isDebugMode;
    [[[GAI sharedInstance] logger] setLogLevel:(isDebugMode == FALSE ? kGAILogLevelNone :kGAILogLevelVerbose)];
}


- (void) logError: (NSString*) errorId withMsg:(NSString*) message
{
    OUTPUT_LOG( @"GoogleAnalytics logError invoked(%@, %@)", errorId, message );
    NSString* msg = nil;
    if (nil == message) {
        msg = @"";
    } else {
        msg = message;
    }
    if ([[GAI sharedInstance] defaultTracker])
    {
        [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"error"             // Event category (required)
                                                                                           action:msg                   // Event action (required)
                                                                                           label:errorId                // Event label
                                                                                           value:nil] build]];          // Event value
    }
}


- (void) logEvent: (NSString*) eventId
{
    OUTPUT_LOG( @"GoogleAnalytics logEvent invoked(%@)", eventId );
    if ([[GAI sharedInstance] defaultTracker])
    {
        [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"event"                 // Event category (required)
                                                                                            action:eventId                  // Event action (required)
                                                                                            label:nil                       // Event label
                                                                                            value:nil] build]];             // Event value
    }
}


- (void) logEvent: (NSString*) eventId withParam:(NSMutableDictionary*) paramMap
{
    OUTPUT_LOG( @"GoogleAnalytics logEventWithParams invoked (%@, %@)", eventId, [paramMap debugDescription] );
    if ([[GAI sharedInstance] defaultTracker])
    {
        [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"event"                     // Event category (required)
                                                                                            action:eventId                      // Event action (required)
                                                                                            label:[paramMap debugDescription]   // Event label
                                                                                            value:nil] build]];                 // Event value
    }
}


- (void) logTimedEventBegin: (NSString*) eventId
{
    OUTPUT_LOG( @"GoogleAnalytics logTimedEventBegin invoked (%@)", eventId );
}


- (void) logTimedEventEnd: (NSString*) eventId
{
    OUTPUT_LOG( @"GoogleAnalytics logTimedEventEnd invoked (%@)", eventId );
}


- (NSString*) getSDKVersion
{
    return @"3.09";
}


- (NSString*) getPluginVersion
{
    return @"0.0.2";
}


-(void) longLogEvent:(NSDictionary *) params
{
    OUTPUT_LOG( @"GoogleAnalytics logEvent log version 2, %@", params );
    
    if ([[GAI sharedInstance] defaultTracker])
    {
        [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:[params objectForKey:@"Param1"]                  // Event category (required)
                                                                                            action:[params objectForKey:@"Param2"]                  // Event action (required)
                                                                                             label:[params objectForKey:@"Param3"]                  // Event label
                                                                                             value:[params objectForKey:@"Param4"]] build]];        // Event value
    }
}


- (void) longLogScreen: (NSString*) screen
{
    OUTPUT_LOG( @"GoogleAnalytics longLogScreen for %@", screen );
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:screen];
    
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}


- (void) longLogECommerce: (NSDictionary*) params
{
    OUTPUT_LOG( @"GoogleAnalytics longLogECommerce for %@", params );
    
    if ([[GAI sharedInstance] defaultTracker])
    {
        [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createItemWithTransactionId:[params objectForKey:@"Param1"]
                                                                                                  name:[params objectForKey:@"Param2"]
                                                                                                   sku:[params objectForKey:@"Param3"]
                                                                                              category:[params objectForKey:@"Param4"]
                                                                                                 price:[params objectForKey:@"Param5"]
                                                                                              quantity:[params objectForKey:@"Param6"]
                                                                                          currencyCode:[params objectForKey:@"Param7"]] build]];
    }
}


- (void) longLogCustomMetrics: (NSDictionary*) params
{
    OUTPUT_LOG( @"GoogleAnalytics longLogCustomMetrics for %@ [N/A]", params );
    
//    if ([[GAI sharedInstance] defaultTracker])
//    {
//        [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createItemWithTransactionId:[params objectForKey:@"Param1"]
//                                                                                                  name:[params objectForKey:@"Param2"]
//                                                                                                   sku:[params objectForKey:@"Param3"]
//                                                                                              category:[params objectForKey:@"Param4"]
//                                                                                                 price:[params objectForKey:@"Param5"]
//                                                                                              quantity:[params objectForKey:@"Param6"]
//                                                                                          currencyCode:[params objectForKey:@"Param7"]] build]];
//    }
}


@end
