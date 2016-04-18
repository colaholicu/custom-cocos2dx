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
package org.cocos2dx.plugin;

public class IAPWrapper {
	public static final int PAYRESULT_SUCCESS = 0;
	public static final int PAYRESULT_FAIL    = 1;
	public static final int PAYRESULT_CANCEL  = 2;
	public static final int PAYRESULT_TIMEOUT = 3;

	public static void onPayResult(InterfaceIAP obj, int ret, String msg) {
		final int curRet = ret;
		final String curMsg = msg;
		final InterfaceIAP curObj = obj;
		PluginWrapper.runOnGLThread(new Runnable() {
			@Override
			public void run() {
				String name = curObj.getClass().getName();
				name = name.replace('.', '/');
				nativeOnPayResult(name, curRet, curMsg);
			}
		});
	}

	public static void onRequestProductsResult(final InterfaceIAP obj, final int ret, final String[] jsonarray) {
		PluginWrapper.runOnGLThread(new Runnable() {
			@Override
			public void run() {
				String name = obj.getClass().getName();
				name = name.replace('.', '/');
				nativeOnRequestProductsResult(name, ret, jsonarray);
			}
		});
	}

	public static void onRequestOwnedProductsResult(final InterfaceIAP obj, final int ret, final String[] plist) {
		PluginWrapper.runOnGLThread(new Runnable() {
			@Override
			public void run() {
				String name = obj.getClass().getName();
				name = name.replace('.', '/');
				nativeOnRequestOwnedProductsResult(name, ret, plist);
			}
		});
	}

	public static boolean isConsumable(final InterfaceIAP obj, String productId)
	{
		String name = obj.getClass().getName();
		name = name.replace('.', '/');

		return nativeIsConsumable(name, productId);
	}

	private static native void nativeOnPayResult(String className, int ret, String msg);
	private static native void nativeOnRequestProductsResult(String className, int ret, String[] jsonarray);
	private static native void nativeOnRequestOwnedProductsResult(String className, int ret, String[] plist);
	private static native boolean nativeIsConsumable(String className, String productId);
}
