//
//  Mixpanel.m
//  Mixpanel
//
//  Created by Iosif Murariu on 02/06/2015.
//  Copyright (c) 2015 Iosif Murariu. All rights reserved.
//

#import "PluginMixpanel.h"
#import "Mixpanel/Mixpanel.h"
#import <AdSupport/ASIdentifierManager.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"


#define OUTPUT_LOG(...)     if (__debug) NSLog(__VA_ARGS__);

@implementation PluginMixpanel

@synthesize debug = __debug;


- (void) startSession: (NSString*) appKey
{
    OUTPUT_LOG( @"Mixpanel PlugInX startSession with %s", [appKey UTF8String] );
    
    [Mixpanel sharedInstanceWithToken:appKey];
}

- (void) stopSession
{
    OUTPUT_LOG( @"Mixpanel PlugInX stopSessio" );
}

- (void) setDebugMode: (BOOL) isDebugMode
{
    OUTPUT_LOG( @"Mixpanel setDebugMode invoked(%d)", isDebugMode );
    self.debug = isDebugMode;
}

- (void) logEvent: (NSString*) eventId
{
    OUTPUT_LOG(@"%s ---> event:%@", __FUNCTION__, eventId);
    
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    NSDate* date = [[NSDate alloc] init];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    NSTimeZone *destinationTimeZone = [NSTimeZone localTimeZone];
    formatter.timeZone = destinationTimeZone;
    [formatter setDateStyle:NSDateFormatterLongStyle];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    properties[@"local_timestamp"] = [NSString stringWithFormat:@"X%@", [formatter stringFromDate:date]];
    
    [[Mixpanel sharedInstance] track:eventId properties:properties];
}

-(void) trackCharge:(NSNumber *)nAmount
{
    OUTPUT_LOG(@"%s ---> amount:%@", __FUNCTION__, nAmount);
    [[[Mixpanel sharedInstance] people] trackCharge:nAmount];
}

- (void) logEvent: (NSString*) eventId withParam:(NSMutableDictionary*) paramMap
{
    OUTPUT_LOG(@"%s ---> event:%@, params:%@", __FUNCTION__, eventId, paramMap);
    
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    [properties addEntriesFromDictionary:paramMap];
    NSDate* date = [[NSDate alloc] init];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    NSTimeZone *destinationTimeZone = [NSTimeZone localTimeZone];
    formatter.timeZone = destinationTimeZone;
    [formatter setDateStyle:NSDateFormatterLongStyle];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    properties[@"local_timestamp"] = [NSString stringWithFormat:@"X%@", [formatter stringFromDate:date]];
    
    [[Mixpanel sharedInstance] track:eventId properties:properties];
}

- (void) logTimedEventBegin: (NSString*) eventId
{
    OUTPUT_LOG(@"%s ---> event:%@", __PRETTY_FUNCTION__, eventId);
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel timeEvent:eventId];
}

- (void) logTimedEventEnd: (NSString*) eventId
{
    OUTPUT_LOG(@"%s ---> event:%@", __PRETTY_FUNCTION__, eventId);
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    NSDate* date = [[NSDate alloc] init];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    NSTimeZone *destinationTimeZone = [NSTimeZone localTimeZone];
    formatter.timeZone = destinationTimeZone;
    [formatter setDateStyle:NSDateFormatterLongStyle];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    properties[@"local_timestamp"] = [NSString stringWithFormat:@"X%@", [formatter stringFromDate:date]];
    
    [mixpanel track:eventId properties:properties];
}

- (NSString*) DoFirstLaunch
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    NSString* idfaString = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    [mixpanel identify:idfaString];
    
    // install date & user id
    NSDate *currentDate = [[NSDate alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    
    NSString* idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    // register super properties that will be sent at each event
    [mixpanel registerSuperPropertiesOnce:@{
                                            @"user_id": idfaString,
                                            @"install_date": dateString,
                                            @"idfv": idfv
                                            }];
    
    [mixpanel.people setOnce:@{
                               @"mixpanel_id": idfaString,
                               @"user_id": idfaString,
                               @"install_date": dateString,
                               @"idfv": idfv
                               }];
    
    // initialize properties & stuff
    [self InitializeWithId: idfaString];
    
    return idfaString;
}

- (void) updateSessionCount:(NSString *)mixpanelId
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify:mixpanelId];
    
    // check sessions count & duration
    NSDictionary* properties = [mixpanel currentSuperProperties];
    NSString* sessionCount = [properties objectForKey:@"session_count"];
    if (sessionCount)
    {
        int sessions = [sessionCount intValue];
        sessions++;
        [mixpanel registerSuperProperties:@{@"session_count": [[NSNumber alloc] initWithInt:(int)sessions]}];
    }
    else
    {
        [mixpanel registerSuperProperties:@{@"session_count": [[NSNumber alloc] initWithInt:(int)1]}];
    }
}

- (NSString*) getInstallDate:(NSString *)strMixpanelId
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify:strMixpanelId];
    
    // calculate install_days
    NSDictionary* properties = [mixpanel currentSuperProperties];
    NSString* installDateString = [properties objectForKey:@"install_date"];
    
    return installDateString;
}

- (NSNumber*) getNumberOfDaysPassed:(NSString *)strDate
{
    NSString* installDateString = strDate;
    OUTPUT_LOG(@"%s --> super properties installDateString: %@", __PRETTY_FUNCTION__, installDateString);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    long locationOfT = [installDateString rangeOfString:@"T"].location;
    if (locationOfT != NSNotFound)
    {
        installDateString = [installDateString substringToIndex:locationOfT];
    }
    
    NSDate *installDate = [dateFormatter dateFromString:installDateString];
    if (installDate)
    {
        NSDate *currentDate = [[NSDate alloc] init];
        
        OUTPUT_LOG(@"currentDate = %@", currentDate);
        
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                            fromDate:installDate
                                                              toDate:currentDate
                                                             options:NSCalendarWrapComponents];
        
        NSNumber* daysPassed = [[NSNumber alloc] initWithInteger:[components day]];
        return daysPassed;
    }
    
    return nil;
}

- (NSNumber*)getFreeDiskSpace
{
    __autoreleasing NSError *error = nil;
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [searchPaths objectAtIndex:0];
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:documentPath error: &error];
    
    if (dictionary) {
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        return freeFileSystemSizeInBytes;
    }
    
    return nil;
}

// code from http://stackoverflow.com/questions/7072989/iphone-ipad-osx-how-to-get-my-ip-address-programmatically
- (NSString *)getIPAddress
{
//    NSArray *searchArray = preferIPv4 ?
//    @[ IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
//    @[ IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSArray *searchArray = @[ IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] ;
    NSDictionary *addresses = [self getIPAddresses];
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         address = addresses[key];
         if(address) *stop = YES;
     } ];
    return address ? address : @"127.0.0.1";
}

- (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

- (void) InitializeWithId:(NSString *)mixpanelId
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify:mixpanelId];
    
    OUTPUT_LOG(@"%s --> super properties: %@", __PRETTY_FUNCTION__, [mixpanel currentSuperProperties]);
}

- (void) AppendFacebookInfo:(NSMutableDictionary *)params
{
    OUTPUT_LOG(@"%s --> params: %@", __PRETTY_FUNCTION__, params);
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    NSString* mixpanelId = [params objectForKey:@"Param1"];
    NSString* strFbFirstName = [params objectForKey:@"Param2"];
    NSString* strFbLastName = [params objectForKey:@"Param3"];
    NSNumber* playerId = [params objectForKey:@"Param4"];
    
    [mixpanel identify:mixpanelId];
    [mixpanel createAlias:playerId.stringValue forDistinctID:mixpanelId];
    
    // add facebook properties
    [mixpanel registerSuperProperties:@{
                                        @"first_name": strFbFirstName,
                                        @"last_name": strFbLastName,
                                        }];
    
    // add people info
    [mixpanel.people set:@{@"first_name": strFbFirstName, @"last_name": strFbLastName}];
    
    OUTPUT_LOG(@"%s --> super properties: %@", __PRETTY_FUNCTION__, [mixpanel currentSuperProperties]);
}

- (void) addDeviceToken:(NSData *)deviceToken
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel.people addPushDeviceToken:deviceToken];
}

- (void) updateSessionDuration:(NSMutableDictionary *)params
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    NSString* mixpanelId = [params objectForKey:@"Param1"];
    NSString* strDuration = [params objectForKey:@"Param2"];
    
    [mixpanel identify:mixpanelId];
    
    [mixpanel registerSuperProperties:@{@"session_duration": strDuration}];
}

- (void) UpdateProperties: (NSMutableDictionary *)params
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    NSString* mixpanelId = [params objectForKey:@"Param1"];
    NSMutableDictionary* properties = [params objectForKey:@"Param2"];
    
    NSString* idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    [properties setObject:idfv forKey:@"idfv"];
    
    [mixpanel identify:mixpanelId];
    
    OUTPUT_LOG(@"%s --> CURRENT super properties: %@", __PRETTY_FUNCTION__, [mixpanel currentSuperProperties]);
    
    // register the value for each property in propertyKeys
    for (NSString *key in properties) {
        id value = properties[key];
        if (value == nil)
            continue;
        
        [mixpanel registerSuperProperties:@{key: properties[key]}];
    }
    
    [mixpanel.people set:properties];
    
    OUTPUT_LOG(@"%s --> UPDATED super properties: %@", __PRETTY_FUNCTION__, [mixpanel currentSuperProperties]);
}

- (void) WriteDataToDisk:(NSString *)mixpanelId
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify:mixpanelId];
    [mixpanel archive];
}

@end
