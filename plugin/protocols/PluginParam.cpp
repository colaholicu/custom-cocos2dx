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

#include "PluginParam.h"

namespace cocos2d { namespace plugin {

PluginParam::PluginParam()
{
    _type = kParamTypeNull;
}

PluginParam::PluginParam(int nValue)
: _intValue(nValue)
{
	_type = kParamTypeInt;
}
    
PluginParam::PluginParam(int64_t nValue)
: _int64Value(nValue)
{
    _type = kParamTypeInt64;
}


PluginParam::PluginParam(float fValue)
: _floatValue(fValue)
{
	_type = kParamTypeFloat;
}

PluginParam::PluginParam(bool bValue)
: _boolValue(bValue)
{
	_type = kParamTypeBool;
}

PluginParam::PluginParam(const char* strValue)
: _strValue(strValue)
{
	_type = kParamTypeString;
}

PluginParam::PluginParam(std::map<std::string, PluginParam*> mapValue)
: _mapValue(mapValue)
{
	_type = kParamTypeMap;
}

PluginParam::PluginParam(StringMap strMapValue)
: _strMapValue(strMapValue)
{
    _type = kParamTypeStringMap;
}
    
PluginParam::PluginParam(void* ptrValue, int ptrLen)
: _ptrValue(ptrValue)
, _ptrLen(ptrLen)
{
    _type = kParamTypeVoidPtr;
}
    
PluginParam::PluginParam(void* ptrValue, ParamType paramType)
: _ptrValue(ptrValue)
, _type(paramType)
{
}

}} //namespace cocos2d { namespace plugin {