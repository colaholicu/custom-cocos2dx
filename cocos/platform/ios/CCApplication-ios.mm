/****************************************************************************
 Copyright (c) 2010-2012 cocos2d-x.org
 Copyright (c) 2013-2014 Chukong Technologies Inc.
 
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

#import "CCApplication.h"

#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS

#import <UIKit/UIKit.h>

#import "math/CCGeometry.h"
#import "CCDirectorCaller-ios.h"

#include <sys/types.h>
#include <sys/sysctl.h>

NS_CC_BEGIN

Application* Application::sm_pSharedApplication = 0;

Application::Application()
{
    CC_ASSERT(! sm_pSharedApplication);
    sm_pSharedApplication = this;
}

Application::~Application()
{
    CC_ASSERT(this == sm_pSharedApplication);
    sm_pSharedApplication = 0;
}

int Application::run()
{
    if (applicationDidFinishLaunching()) 
    {        
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        
        [[CCDirectorCaller sharedDirectorCaller] startMainLoop];
    }
    return 0;
}

void Application::setAnimationInterval(float interval)
{
    [[CCDirectorCaller sharedDirectorCaller] setAnimationInterval: interval ];
}

/////////////////////////////////////////////////////////////////////////////////////////////////
// static member function
//////////////////////////////////////////////////////////////////////////////////////////////////

Application* Application::getInstance()
{
    CC_ASSERT(sm_pSharedApplication);
    return sm_pSharedApplication;
}

// @deprecated Use getInstance() instead
Application* Application::sharedApplication()
{
    return Application::getInstance();
}

const char * Application::getCurrentLanguageCode()
{
    static char code[3]={0};
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *currentLanguage = [languages objectAtIndex:0];
    
    // get the current language code.(such as English is "en", Chinese is "zh" and so on)
    NSDictionary* temp = [NSLocale componentsFromLocaleIdentifier:currentLanguage];
    NSString * languageCode = [temp objectForKey:NSLocaleLanguageCode];
    [languageCode getCString:code maxLength:3 encoding:NSASCIIStringEncoding];
    code[2]='\0';
    return code;
}

LanguageType Application::getCurrentLanguage()
{
    // get the current language and country config
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *currentLanguage = [languages objectAtIndex:0];
    
    // get the current language code.(such as English is "en", Chinese is "zh" and so on)
    NSDictionary* temp = [NSLocale componentsFromLocaleIdentifier:currentLanguage];
    NSString * languageCode = [temp objectForKey:NSLocaleLanguageCode];
    
    if ([languageCode isEqualToString:@"zh"]) return LanguageType::CHINESE;
    if ([languageCode isEqualToString:@"en"]) return LanguageType::ENGLISH;
    if ([languageCode isEqualToString:@"fr"]) return LanguageType::FRENCH;
    if ([languageCode isEqualToString:@"it"]) return LanguageType::ITALIAN;
    if ([languageCode isEqualToString:@"de"]) return LanguageType::GERMAN;
    if ([languageCode isEqualToString:@"es"]) return LanguageType::SPANISH;
    if ([languageCode isEqualToString:@"nl"]) return LanguageType::DUTCH;
    if ([languageCode isEqualToString:@"ru"]) return LanguageType::RUSSIAN;
    if ([languageCode isEqualToString:@"ko"]) return LanguageType::KOREAN;
    if ([languageCode isEqualToString:@"ja"]) return LanguageType::JAPANESE;
    if ([languageCode isEqualToString:@"hu"]) return LanguageType::HUNGARIAN;
    if ([languageCode isEqualToString:@"pt"]) return LanguageType::PORTUGUESE;
    if ([languageCode isEqualToString:@"ar"]) return LanguageType::ARABIC;
    if ([languageCode isEqualToString:@"nb"]) return LanguageType::NORWEGIAN;
    if ([languageCode isEqualToString:@"pl"]) return LanguageType::POLISH;
    if ([languageCode isEqualToString:@"tr"]) return LanguageType::TURKISH;
    if ([languageCode isEqualToString:@"uk"]) return LanguageType::UKRAINIAN;
    if ([languageCode isEqualToString:@"ro"]) return LanguageType::ROMANIAN;
    if ([languageCode isEqualToString:@"bg"]) return LanguageType::BULGARIAN;
    return LanguageType::ENGLISH;

}

Application::Platform Application::getTargetPlatform()
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) // idiom for iOS <= 3.2, otherwise: [UIDevice userInterfaceIdiom] is faster.
    {
        return Platform::OS_IPAD;
    }
    else 
    {
        return Platform::OS_IPHONE;
    }
}

std::string platform()
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char * machine = (char *) malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    std::string platformMachine = machine;
    free(machine);
    return platformMachine;
}

std::string Application::applicationDetectDevice()
{
    std::string deviceName = platform();

    // NOT SUPPORTED
//    if (deviceName.compare("iPhone1,1") == 0)    return "iPhone 1G";
//    if (deviceName.compare("iPhone1,2") == 0)    return "iPhone 3G";
//    if (deviceName.compare("iPhone2,1") == 0)    return "iPhone 3GS";
    if (deviceName.compare("iPhone3,1") == 0)    return "iPhone 4";// (GSM)";
    if (deviceName.compare("iPhone3,3") == 0)    return "iPhone 4";// (CDMA)";
    if (deviceName.compare("iPhone4,1") == 0)    return "iPhone 4S";
    if (deviceName.compare("iPhone5,1") == 0)    return "iPhone 5";// (GSM)";
    if (deviceName.compare("iPhone5,2") == 0)    return "iPhone 5";// (CDMA)";
    if (deviceName.compare("iPhone5,3") == 0)    return "iPhone 5C";
    if (deviceName.compare("iPhone5,4") == 0)    return "iPhone 5C";
    if (deviceName.compare("iPhone6,1") == 0)    return "iPhone 5S";
    if (deviceName.compare("iPhone6,2") == 0)    return "iPhone 5S";
    if (deviceName.compare("iPhone7,1") == 0)    return "iPhone 6 Plus";
    if (deviceName.compare("iPhone7,2") == 0)    return "iPhone 6";
    
    // NOT SUPPORTED
//    if (deviceName.compare("iPod1,1") == 0)      return "iPod Touch 1G";
//    if (deviceName.compare("iPod2,1") == 0)      return "iPod Touch 2G";
//    if (deviceName.compare("iPod3,1") == 0)      return "iPod Touch 3G";
    if (deviceName.compare("iPod4,1") == 0)      return "iPod Touch 4G";
    if (deviceName.compare("iPod5,1") == 0)      return "iPod Touch 5G";
    
    if (deviceName.compare("iPad1,1") == 0)      return "iPad";
    if (deviceName.compare("iPad2,1") == 0)      return "iPad 2";// (WiFi)";
    if (deviceName.compare("iPad2,2") == 0)      return "iPad 2";// (GSM)";
    if (deviceName.compare("iPad2,3") == 0)      return "iPad 2";// (CDMA)";
    if (deviceName.compare("iPad2,5") == 0)      return "iPad Mini";// (WiFi)";
    if (deviceName.compare("iPad2,6") == 0)      return "iPad Mini";// (GSM)";
    if (deviceName.compare("iPad2,7") == 0)      return "iPad Mini";// (CDMA)";
    if (deviceName.compare("iPad3,1") == 0)      return "iPad 3";// (WiFi)";
    if (deviceName.compare("iPad3,2") == 0)      return "iPad 3";// (CDMA)";
    if (deviceName.compare("iPad3,3") == 0)      return "iPad 3";// (GSM)";
    if (deviceName.compare("iPad3,4") == 0)      return "iPad 4";// (WiFi)";
    if (deviceName.compare("iPad3,5") == 0)      return "iPad 4";// (GSM)";
    if (deviceName.compare("iPad3,6") == 0)      return "iPad 4";// (CDMA)";
    
    if (deviceName.compare("iPad4,1") == 0)      return "iPad Air";// (WiFi)";
    if (deviceName.compare("iPad4,2") == 0)      return "iPad Air";// (GSM)";
    if (deviceName.compare("iPad4,3") == 0)      return "iPad Air";// (CDMA)";
    if (deviceName.compare("iPad5,3") == 0)      return "iPad Air 2";// (WiFi)";
    if (deviceName.compare("iPad5,4") == 0)      return "iPad Air 2";// (CDMA)";
    
    if (deviceName.compare("iPad4,4") == 0)      return "iPad Mini Retina";// (WiFi)";
    if (deviceName.compare("iPad4,5") == 0)      return "iPad Mini Retina";// (CDMA)";
    if (deviceName.compare("iPad4,7") == 0)      return "iPad Mini 3";// (WiFi)";
    if (deviceName.compare("iPad4,8") == 0)      return "iPad Mini 3";// (CDMA)";
    if (deviceName.compare("iPad4,9") == 0)      return "iPad Mini 3";// (CDMA)";
    
    return deviceName;
}

const char* Application::getVersion()
{
    NSDictionary *bundleIdentifier = [[NSBundle mainBundle] infoDictionary];
    NSString* version = bundleIdentifier[@"CFBundleVersion"];
    return version.UTF8String;
}

bool Application::openURL(const std::string &url)
{
    NSString* msg = [NSString stringWithCString:url.c_str() encoding:NSUTF8StringEncoding];
    NSURL* nsUrl = [NSURL URLWithString:msg];
    return [[UIApplication sharedApplication] openURL:nsUrl];
}

void Application::applicationScreenSizeChanged(int newWidth, int newHeight) {

}

NS_CC_END

#endif // CC_PLATFORM_IOS
