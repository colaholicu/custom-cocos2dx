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
#import "PluginLeanPlum.h"

#import <Leanplum/Leanplum.h>
#import <AdSupport/ASIdentifierManager.h>

#define OUTPUT_LOG(...)     if ([PluginLeanPlum pluginDebugMode]) NSLog(__VA_ARGS__);

@implementation PluginLeanPlum

static NSDictionary* __pricesDict = nil;
static NSDictionary* __varsDict = nil;
static BOOL __debugMode = false;

LPVar* leanplumPrices;
LPVar* leanplumVars;


@synthesize debug = __debug;

static void __attribute__((constructor)) initObjects() {
    @autoreleasepool {
        
        // first check if the file exists at the documents directory path
        NSError *error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *docsPath = [documentsDirectory stringByAppendingPathComponent:@"prices.plist"];
        NSString *varsPath = [documentsDirectory stringByAppendingPathComponent:@"variables.plist"];
        
        //copy this file from bundle/dlc to documents directory
        NSString *docsBundlePath = [[NSBundle mainBundle] pathForResource:@"prices" ofType:@"plist" inDirectory:@"configs"];
        NSString *varsBundlePath = [[NSBundle mainBundle] pathForResource:@"variables" ofType:@"plist" inDirectory:@"configs"];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        // prices
        if ( ![fileManager fileExistsAtPath:docsPath] )
        {
            OUTPUT_LOG( @"[LeanPlum] price config file not in documents directory...creating and encrypting file!" );
            
            BOOL copySuccess = [fileManager copyItemAtPath:docsBundlePath toPath:docsPath error:&error];
            
            if (copySuccess)
            {
                OUTPUT_LOG( @"[LeanPlum] plist price config copied to documents directory!" );
                
                // encrypt the prices plist file
                NSDictionary* dictionaryToEncrypt = [NSDictionary dictionaryWithContentsOfFile:docsPath];
                
                // set the prices
                [PluginLeanPlum setCachedPrices:dictionaryToEncrypt];
                
                OUTPUT_LOG( @"[LeanPlum] encrypting price config file..." );
                
                // encrypt the file
                NSMutableData *plistFileData = [NSMutableData new];
                NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:plistFileData];
                
                [archiver encodeObject:dictionaryToEncrypt forKey:@"Prices"];
                [archiver finishEncoding];
                
                BOOL writeSuccess = [plistFileData writeToFile:docsPath atomically:YES];
                
                OUTPUT_LOG( writeSuccess ? @"[LeanPlum] price config file encryption succesfull!": @"[LeanPlum] price config file encryption failed!" );
            }
            else
            {
                if (error)
                    OUTPUT_LOG(@"[LeanPlum] file writing failed with error %@", error.localizedDescription);
                
                //temp, just read it from bundle, careful, it's not encrypted
                leanplumPrices = [LPVar define:@"Prices" withDictionary: [NSDictionary dictionaryWithContentsOfFile:docsBundlePath] ];
            }
        }
        else
        {
            // set the cached variable to use the saved plist file in documents directory
            OUTPUT_LOG( @"[LeanPlum] decrypting price config file..." );
            
            NSData *archivedData = [NSData dataWithContentsOfFile:docsPath];
            
            NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:archivedData];
            
            NSDictionary *decodedDictionary = [unarchiver decodeObjectForKey:@"Prices"];
            
            OUTPUT_LOG( @"[LeanPlum] price config file decrypted!" );
            
            [PluginLeanPlum setCachedPrices:decodedDictionary];
            
            // set the variable to always use the prices file from the bundle
            leanplumPrices = [LPVar define:@"Prices" withDictionary: [NSDictionary dictionaryWithContentsOfFile:docsBundlePath]];
        }
        
        // variables
        if ( ![fileManager fileExistsAtPath:varsPath] )
        {
            OUTPUT_LOG( @"[LeanPlum] variables file not in documents directory...creating and encrypting file!" );
            
            BOOL copySuccess = [fileManager copyItemAtPath:varsBundlePath toPath:varsPath error:&error];
            
            if (copySuccess)
            {
                OUTPUT_LOG( @"[LeanPlum] plist variables copied to documents directory!" );
                
                // encrypt the variables plist file
                NSDictionary* dictionaryToEncrypt = [NSDictionary dictionaryWithContentsOfFile:varsPath];
                
                // set the variables
                [PluginLeanPlum setCachedVars:dictionaryToEncrypt];
                
                OUTPUT_LOG( @"[LeanPlum] encrypting variables file..." );
                
                // encrypt the file
                NSMutableData *plistFileData = [NSMutableData new];
                NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:plistFileData];
                
                [archiver encodeObject:dictionaryToEncrypt forKey:@"Variables"];
                [archiver finishEncoding];
                
                BOOL writeSuccess = [plistFileData writeToFile:varsPath atomically:YES];
                
                OUTPUT_LOG( writeSuccess ? @"[LeanPlum] variables file encryption succesful!": @"[LeanPlum] variables file encryption failed!" );
            }
            else
            {
                if (error)
                    OUTPUT_LOG(@"[LeanPlum] file writing failed with error %@", error.localizedDescription);
                
                //temp, just read it from bundle, careful, it's not encrypted
                leanplumVars = [LPVar define:@"Variables" withDictionary: [NSDictionary dictionaryWithContentsOfFile:varsBundlePath] ];
            }
        }
        else
        {
            // set the cached variable to use the saved plist file in documents directory
            OUTPUT_LOG( @"[LeanPlum] decrypting variables file..." );
            
            NSData *archivedData = [NSData dataWithContentsOfFile:varsPath];
            
            NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:archivedData];
            
            NSDictionary *decodedDictionary = [unarchiver decodeObjectForKey:@"Variables"];
            
            OUTPUT_LOG( @"[LeanPlum] variables file decrypted!" );
            
            OUTPUT_LOG(@"-------------- decodedDict Vars: %@ ------------", decodedDictionary);
            [PluginLeanPlum setCachedVars:decodedDictionary];
            
            // set the variable to always use the prices file from the bundle
            leanplumVars = [LPVar define:@"Variables" withDictionary: [NSDictionary dictionaryWithContentsOfFile:varsBundlePath]];
        }
    }
}

+(NSDictionary *)cachedPrices
{
    if (__pricesDict == nil)
        __pricesDict = [[NSDictionary alloc] init];
    
    return __pricesDict;
}


+(void)setCachedPrices:(NSDictionary *)dict
{
    [__pricesDict release];
    __pricesDict = [[NSDictionary alloc] initWithDictionary:dict];
}

+(NSDictionary *)cachedVars
{
    if (__varsDict == nil)
        __varsDict = [[NSDictionary alloc] init];
    
    return __varsDict;
}


+(void)setCachedVars:(NSDictionary *)dict
{
    [__varsDict release];
    __varsDict = [[NSDictionary alloc] initWithDictionary:dict];
}

+(void)setPluginDebugMode:(BOOL)isDebugMode
{
    __debugMode = isDebugMode;
}

+(BOOL)pluginDebugMode
{
    return __debugMode;
}

- (void) Initialize:(NSDictionary *)params
{
    OUTPUT_LOG( @"[LeanPlum] Initialize" );
    
    // load prices file first
    [self LoadPrices];
    
    NSString* appId         = [params objectForKey:@"Param1"];
    NSString* appSignature  = [params objectForKey:@"Param2"];
    BOOL debugging          = [[params objectForKey:@"Param3"] boolValue];
    
    if (debugging)
    {
        LEANPLUM_USE_ADVERTISING_ID;
        [Leanplum setAppId:appId withDevelopmentKey:appSignature];
    }
    else
    {
        NSString* idfaString = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        // set IDFA
        if ((idfaString != nil) && (idfaString.length > 0))
        {
            [Leanplum setDeviceId:idfaString];
        }

        [Leanplum setAppId:appId withProductionKey:appSignature];
    }
    
    // Optional: Syncs the files between your main bundle and Leanplum.
    // This allows you to swap out and A/B test any resource file
    // in your project in realtime.
    // Replace MyResources with a list of actual paths to include.
    // [Leanplum syncResourcePaths:@[@"MyResources/.*"] excluding:nil async:YES];
    
    // Optional: Tracks in-app purchases automatically as the "Purchase" event.
    // To require valid receipts upon purchase or change your reported
    // currency code from USD, update your app settings.
    // [Leanplum trackInAppPurchases];
    
    // Optional: Tracks all screens in your app as states in Leanplum.
    // [Leanplum trackAllAppScreens];
    
    // Starts a new session and updates the app content from Leanplum.
    [Leanplum start];
    
    [Leanplum onVariablesChanged:^{
        OUTPUT_LOG( @"[LeanPlum] onVariablesChangedCallback..." );
        
        if (leanplumPrices.hasChanged)
        {
            NSDictionary* allPrices = [leanplumPrices objectForKeyPath:nil];
            
            [PluginLeanPlum setCachedPrices:allPrices];
            
            OUTPUT_LOG( @"[LeanPlum] prices have been changed!" );
            
            //write the plist file to disk
            OUTPUT_LOG( @"[LeanPlum] writing price config file..." );
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *docsPath = [documentsDirectory stringByAppendingPathComponent:@"prices.plist"];
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            if ( ![fileManager fileExistsAtPath:docsPath] )
            {
                [fileManager createFileAtPath:docsPath contents:nil attributes:nil];
            }
            
            OUTPUT_LOG( @"[LeanPlum] encrypting price config file..." );
            
            NSDictionary* dictionaryToEncrypt = [PluginLeanPlum cachedPrices];
            
            // encrypt the file
            NSMutableData *plistFileData = [NSMutableData new];
            NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:plistFileData];
            
            [archiver encodeObject:dictionaryToEncrypt forKey:@"Prices"];
            [archiver finishEncoding];
            
            BOOL writeSuccess = [plistFileData writeToFile:docsPath atomically:YES];
            
            OUTPUT_LOG( writeSuccess ? @"[LeanPlum] price config file encryption succesfull!": @"[LeanPlum] price config file encryption failed!" );
        }
        
        if (leanplumVars.hasChanged)
        {
            NSDictionary* allVars = [leanplumVars objectForKeyPath:nil];
            
            [PluginLeanPlum setCachedVars:allVars];
            
            OUTPUT_LOG( @"[LeanPlum] variables have been changed!" );
            
            // write the plist file to disk
            OUTPUT_LOG( @"[LeanPlum] writing variables file..." );
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *varsPath = [documentsDirectory stringByAppendingPathComponent:@"variables.plist"];
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            if ( ![fileManager fileExistsAtPath:varsPath] )
            {
                [fileManager createFileAtPath:varsPath contents:nil attributes:nil];
            }
            
            OUTPUT_LOG( @"[LeanPlum] encrypting variables file..." );
            
            NSDictionary* dictionaryToEncrypt = [PluginLeanPlum cachedVars];
            
            // encrypt the file
            NSMutableData *plistFileData = [NSMutableData new];
            NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:plistFileData];
            
            [archiver encodeObject:dictionaryToEncrypt forKey:@"Variables"];
            [archiver finishEncoding];
            
            BOOL writeSuccess = [plistFileData writeToFile:varsPath atomically:YES];
            
            OUTPUT_LOG( writeSuccess ? @"[LeanPlum] variables file encryption succesfull!": @"[LeanPlum] variables file encryption failed!" );
        }
    }];
}

-(void)LoadPrices
{
    OUTPUT_LOG( @"[LeanPlum] loading prices & variables..." );
    
    initObjects();

    OUTPUT_LOG( @"[LeanPlum] loading prices variables completed!" );
}

-(NSString *)getPriceForItem:(NSDictionary*) params;
{
    OUTPUT_LOG( @"[LeanPlum] getting price for %@...", params );
    
    NSString* priceID = [[[PluginLeanPlum cachedPrices] objectForKey:(NSString*)params] stringValue];
    
    return priceID;
}

-(NSString *)getStringVar:(NSDictionary *)params
{
    OUTPUT_LOG( @"[LeanPlum] getting variable value for %@...", params );
    OUTPUT_LOG( @"[LeanPlum] cachedVars %@...", [PluginLeanPlum cachedVars] );
    
    NSString* var = [[PluginLeanPlum cachedVars] objectForKey:(NSString*)params];
    
    return var;
}

-(NSNumber *)getIntVar:(NSDictionary *)params
{
    OUTPUT_LOG( @"[LeanPlum] getting variable value for %@...", params );
    
    int var = [[[PluginLeanPlum cachedVars] objectForKey:(NSString*)params] intValue];
    
    return [[NSNumber alloc] initWithInt:var];
}

- (void) setDebugMode: (BOOL) isDebugMode
{
    OUTPUT_LOG( @"[LeanPlum] setDebugMode invoked(%d)", isDebugMode );
    self.debug = isDebugMode;
    
    [PluginLeanPlum setPluginDebugMode:self.debug];
}


- (void) logError: (NSString*) errorId withMsg:(NSString*) message
{
    OUTPUT_LOG( @"[LeanPlum] logError invoked(%@, %@)", errorId, message );
    NSString* msg = nil;
    if (nil == message) {
        msg = @"";
    } else {
        msg = message;
    }
}

- (NSString*) getSDKVersion
{
    return @"3.09";
}

@end
