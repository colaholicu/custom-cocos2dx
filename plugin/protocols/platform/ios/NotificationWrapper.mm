/****************************************************************************
Copyright (c) 2013 cocos2d-x.org

http://www.cocos2d+x.org

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

#import "NotificationWrapper.h"
#include "PluginUtilsIOS.h"
#include "ProtocolNotifications.h"

using namespace cocos2d::plugin;

@implementation NotificationWrapper

+ (void) onNotificationReceived:(id) obj withMsg:(NSString*) msg
{
    PluginProtocol* plugin = PluginUtilsIOS::getPluginPtr(obj);
    ProtocolNotifications* notificationsPlugin = dynamic_cast<ProtocolNotifications*>(plugin);
    
    if (notificationsPlugin)
    {
        const char* chMsg = [msg UTF8String];
        NotificationsListener* listener = notificationsPlugin->getNotificationListener();
        ProtocolNotifications::ProtocolNotificationCallback callback = notificationsPlugin->getCallback();
        
        if (listener)
        {
            listener->onNotificationReceived(chMsg);
        }
        else if(callback)
        {
            std::string stdmsg(chMsg);
            callback(stdmsg);
        }
    } else {
        PluginUtilsIOS::outputLog("Can't find the C++ object of the ads plugin");
    }
}

@end
