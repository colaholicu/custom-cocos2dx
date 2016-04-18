//
//  PluginApsalar.m
//  PluginApsalar
//
//  Created by Iosif Murariu on 11/06/2015.
//  Copyright (c) 2015 Iosif Murariu. All rights reserved.
//

#import "PluginApsalar.h"
#import "Apsalar/Apsalar.h"

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);

@implementation PluginApsalar

@synthesize debug = __debug;

- (void) Initialize:(NSDictionary*) params
{
    NSString* apiKey = [params objectForKey:@"Param1"];
    NSString* secret = [params objectForKey:@"Param2"];
    
    OUTPUT_LOG(@"%s ---> apiKey:%@, secret:%@", __PRETTY_FUNCTION__, apiKey, secret);
    [Apsalar startSession:@"superhippo" withKey:@"HgdSQqed"];
}

- (void) stopSession
{
    OUTPUT_LOG( @"PluginApsalar PlugInX stopSessio" );
}

- (void) setDebugMode: (BOOL) isDebugMode
{
    OUTPUT_LOG( @"PluginApsalar setDebugMode invoked(%d)", isDebugMode );
    self.debug = isDebugMode;
}

- (void) logEvent: (NSString*) eventId
{
    OUTPUT_LOG(@"%s ---> event:%@", __PRETTY_FUNCTION__, eventId);
    [Apsalar event:eventId];
}

- (void) logEvent: (NSString*) eventId withParam:(NSMutableDictionary*) paramMap
{
    OUTPUT_LOG(@"%s ---> event:%@, params:%@", __PRETTY_FUNCTION__, eventId, paramMap);
    if (paramMap != nil)
    {
        [Apsalar event:eventId withArgs:paramMap];
    } else {
        [Apsalar event:eventId];
    }
}

@end