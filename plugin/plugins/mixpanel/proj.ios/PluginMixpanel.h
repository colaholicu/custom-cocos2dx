//
//  Mixpanel.h
//  Mixpanel
//
//  Created by Iosif Murariu on 02/06/2015.
//  Copyright (c) 2015 Iosif Murariu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InterfaceAnalytics.h"


@interface PluginMixpanel : NSObject <InterfaceAnalytics>
{
    
}

@property BOOL debug;



/**
 interfaces of protocol : InterfaceAnalytics
 */
- (void) startSession: (NSString*) appKey;
- (void) stopSession;
//- (void) setSessionContinueMillis: (long) millis;
//- (void) setCaptureUncaughtException: (BOOL) isEnabled;
- (void) setDebugMode: (BOOL) isDebugMode;
//- (void) logError: (NSString*) errorId withMsg:(NSString*) message;
- (void) logEvent: (NSString*) eventId;
- (void) logEvent: (NSString*) eventId withParam:(NSMutableDictionary*) paramMap;
- (void) logTimedEventBegin: (NSString*) eventId;
- (void) logTimedEventEnd: (NSString*) eventId;
- (void) trackCharge: (NSNumber*) nAmount;
//- (NSString*) getSDKVersion;
//- (NSString*) getPluginVersion;

/**
 additional stuff
 */
- (NSString*) DoFirstLaunch;
- (NSNumber*) getNumberOfDaysPassed:(NSString*)strDate;
- (void) updateSessionCount:(NSString*)mixpanelId;
- (void) updateSessionDuration: (NSMutableDictionary*) params;
- (NSString*) getInstallDate: (NSString*) mixpanelId;
- (NSNumber*) getFreeDiskSpace;
- (NSString*) getIPAddress;
- (void) InitializeWithId: (NSString*) mixpanelId;
- (void) AppendFacebookInfo: (NSMutableDictionary*) params;
- (void) UpdateProperties: (NSMutableDictionary*) params;
- (void) addDeviceToken: (NSData*) deviceToken;
- (void) WriteDataToDisk: (NSString*) mixpanelId;


@end
