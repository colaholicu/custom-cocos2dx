//
//  PluginHelpShift.m
//  PluginHelpShift
//
//  Created by Iosif Murariu on 11/06/2015.
//  Copyright (c) 2015 Iosif Murariu. All rights reserved.
//

#import "PluginHelpShift.h"
#import "Helpshift.h"
#import <AdSupport/ASIdentifierManager.h>

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);

@implementation PluginHelpShift

@synthesize debug = __debug;


+(NSDictionary*) DictionaryFromJSONString:(NSString*) JSONString
{
    NSError *error;
    NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if (!jsonDict)
    {
        NSLog(@"DictionaryFromJSONString: error: %@", error.localizedDescription);
        return @{};
    }
    else
    {
        return jsonDict;
    }
}

- (void) Initialize:(NSDictionary*) params
{
    NSString* apiKey = [params objectForKey:@"Param1"];
    NSString* domain = [params objectForKey:@"Param2"];
    NSString* appId  = [params objectForKey:@"Param3"];
    
    OUTPUT_LOG(@"%s ---> %@", __PRETTY_FUNCTION__, params);
    [Helpshift installForApiKey:apiKey domainName:domain appID:appId];
    
    NSString* idfaString = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    if ((idfaString != nil) && (idfaString.length > 0))
    {
        [Helpshift setUserIdentifier:idfaString];
    }
}

- (NSString*) getIDFA
{
    return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
}

- (void) stopSession
{
    OUTPUT_LOG( @"PluginHelpShift PlugInX stopSessio" );
}

- (void) setDebugMode: (BOOL) isDebugMode
{
    OUTPUT_LOG( @"PluginHelpShift setDebugMode invoked(%d)", isDebugMode );
    self.debug = isDebugMode;
}

- (void) logEvent: (NSString*) eventId
{
    OUTPUT_LOG(@"%s ---> event:%@", __PRETTY_FUNCTION__, eventId);
//    [Helpshift leaveBreadCrumb:eventId];
}

- (UIViewController *)getCurrentRootViewController {
    
    UIViewController *result = nil;
    
    // Try to find the root view controller programmically
    
    // Find the top window (that is not an alert view or other window)
    UIWindow *topWindow = [[UIApplication sharedApplication] keyWindow];
    if (topWindow.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(topWindow in windows)
        {
            if (topWindow.windowLevel == UIWindowLevelNormal)
                break;
        }
    }
    
    UIView *rootView = [[topWindow subviews] objectAtIndex:0];
    id nextResponder = [rootView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else if ([topWindow respondsToSelector:@selector(rootViewController)] && topWindow.rootViewController != nil)
        result = topWindow.rootViewController;
    else
        NSAssert(NO, @"Could not find a root view controller.");
    
    return result;
}

- (void) ShowFAQ:(NSDictionary*)params
{
    NSMutableDictionary* dictMetadata = [params objectForKey:@"Param1"];
    NSNumber* payerType = [params objectForKey:@"Param2"];
    NSNumber* playerType = [params objectForKey:@"Param3"];
    
    // shitty NSCFStrings
    NSArray* nscfStrings = @[[playerType intValue] ? (([payerType intValue] > 1) ? @"longtime player" : @"new player") : @"",
                             [payerType intValue] ? (([payerType intValue] > 1) ? @"heavy payer" : @"payer") : @""];
    
    OUTPUT_LOG(@"%@", nscfStrings);
    
    [dictMetadata setObject:nscfStrings forKey:HSTagsKey];
    [[Helpshift sharedInstance] showFAQs:[UIApplication sharedApplication].keyWindow.rootViewController
                             withOptions:@{@"enableContactUs":@"ALWAYS",
                                           @"gotoConversationAfterContactUs":@"YES",
                                           @"requireEmail":@"yes",
                                           HSCustomMetadataKey: dictMetadata,
                                           }];
}

- (void) HandleRemoteNotification:(NSString*) notificationInfo
{
    [[Helpshift sharedInstance] handleRemoteNotification:[PluginHelpShift DictionaryFromJSONString:notificationInfo] withController:[[UIApplication sharedApplication] keyWindow].rootViewController];
}

- (void) HandleLocalNotification:(UILocalNotification*) notification
{
    [[Helpshift sharedInstance] handleLocalNotification:notification withController:[[UIApplication sharedApplication] keyWindow].rootViewController];
}

- (void) ShowHelp:(NSDictionary*)params
{
    NSMutableDictionary* dictMetadata = [params objectForKey:@"Param1"];
    NSNumber* payerType = [params objectForKey:@"Param2"];
    NSNumber* playerType = [params objectForKey:@"Param3"];
    
    // shitty NSCFStrings
    NSArray* nscfStrings = @[[playerType intValue] ? (([payerType intValue] > 1) ? @"longtime player" : @"new player") : @"",
                             [payerType intValue] ? (([payerType intValue] > 1) ? @"heavy payer" : @"payer") : @""];
    
    OUTPUT_LOG(@"%@", nscfStrings);
    [dictMetadata setObject:nscfStrings forKey:HSTagsKey];
    [[Helpshift sharedInstance] showConversation:[UIApplication sharedApplication].keyWindow.rootViewController withOptions:@{@"requireEmail":@"yes",
                                                                                                                              HSCustomMetadataKey: dictMetadata
                                                                                                                              }];
}

- (void) addDeviceToken:(NSData *)deviceToken
{
    [[Helpshift sharedInstance] registerDeviceToken:deviceToken];
}

- (void) logEvent: (NSString*) eventId withParam:(NSMutableDictionary*) paramMap
{
    OUTPUT_LOG(@"%s ---> event:%@, params:%@", __PRETTY_FUNCTION__, eventId, paramMap);
}

@end
