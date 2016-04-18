//
//  PluginApsalar.h
//  PluginApsalar
//
//  Created by Iosif Murariu on 11/06/2015.
//  Copyright (c) 2015 Iosif Murariu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InterfaceAnalytics.h"

@interface PluginApsalar : NSObject <InterfaceAnalytics>
{
    
}

@property BOOL debug;



/**
 interfaces of protocol : InterfaceAnalytics
 */
//- (void) startSession: (NSString*) appKey;
- (void) stopSession;
- (void) setDebugMode: (BOOL) isDebugMode;
- (void) logEvent: (NSString*) eventId;
- (void) logEvent: (NSString*) eventId withParam:(NSMutableDictionary*) paramMap;

/**
 interfaces of PluginApsalar
 */
- (void) Initialize:(NSDictionary*) params;

@end