//
//  PIAdColony.h
//  PluginAdColony
//
//  Created by Daniel Popescu on 10/10/14.
//  Copyright (c) 2014 Superhippo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AdColony/AdColony.h>

#import "InterfaceAds.h"

@interface PIAdColony : NSObject <InterfaceAds, AdColonyDelegate, AdColonyAdDelegate>

@property BOOL debug;
@property (nonatomic, retain) NSString*             appId;
@property (nonatomic, retain) NSString*             zoneId;
@property (nonatomic, assign) int                   points;

// INTERFACE ADS
- (void) configDeveloperInfo: (NSMutableDictionary*) devInfo;
- (void) showAds: (NSMutableDictionary*) info position:(int) pos;
- (void) setDebugMode: (BOOL) debug;
- (NSString*) getSDKVersion;
- (NSString*) getPluginVersion;

@end
