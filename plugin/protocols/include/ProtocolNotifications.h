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

#pragma once

#include "PluginProtocol.h"
#include <map>
#include <string>
#include <functional>

namespace cocos2d { namespace plugin {

typedef std::map<std::string, std::string> TNotificationsDeveloperInfo;
    
class ProtocolNotifications;
class NotificationsListener
{
public:
    /**
    @brief The notification message received
    */
    virtual void onNotificationReceived(const char* msg) = 0;
};

class ProtocolNotifications : public PluginProtocol
{
public:
	ProtocolNotifications();
	virtual ~ProtocolNotifications();

    typedef std::function<void(std::string&)> ProtocolNotificationCallback;

    /**
    @brief config the application info
    @param devInfo This parameter is the info of aplication,
           different plugin have different format
    @warning Must invoke this interface before other interfaces.
             And invoked only once.
    */
    void configDeveloperInfo(TNotificationsDeveloperInfo devInfo);

    /**
     @deprecated
     @brief set the notification listener
    */
    CC_DEPRECATED_ATTRIBUTE inline void setNotificationListener(NotificationsListener* listener)
    {
        _listener = listener;
    }

    /**
     @deprecated
     @brief set the notification listener
    */
    CC_DEPRECATED_ATTRIBUTE inline NotificationsListener* getNotificationListener()
    {
        return _listener;
    }

    /**
     @brief set the notification callback function
    */
    inline void setCallback(ProtocolNotificationCallback& cb)
    {
    	_callback = cb;
    }

    /**
     @brief get the notification callback function
    */
    inline ProtocolNotificationCallback getCallback()
    {
    	return _callback;
    }
protected:
    NotificationsListener* _listener;
    ProtocolNotificationCallback _callback;
};

}} // namespace cocos2d { namespace plugin {
