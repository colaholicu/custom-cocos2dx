//
//  PluginHelpShift.h
//  PluginHelpShift
//
//  Created by Iosif Murariu on 11/06/2015.
//  Copyright (c) 2015 Iosif Murariu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "InterfaceAnalytics.h"

@interface PluginHelpShift : NSObject<InterfaceAnalytics>

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
- (void) ShowFAQ:(NSDictionary*)params;
- (void) ShowHelp:(NSDictionary*)params;
- (void) addDeviceToken:(NSData *)deviceToken;
- (void) HandleRemoteNotification:(NSString*) notificationInfo;
- (void) HandleLocalNotification:(UILocalNotification*) notificationInfo;
- (NSString*) getIDFA;
+ (NSDictionary*) DictionaryFromJSONString:(NSString*) JSONString;

@end
