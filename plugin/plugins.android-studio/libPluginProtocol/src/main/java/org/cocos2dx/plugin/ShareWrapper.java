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

public class ShareWrapper {
	public static final int SHARERESULT_SUCCESS = 0;
	public static final int SHARERESULT_FAIL    = 1;
	public static final int SHARERESULT_CANCEL  = 2;
	public static final int SHARERESULT_TIMEOUT = 3;
    
    // code for leaderboard feature
    public static final int SHARE_SCORE_SUBMIT_SUCCESS                  = 4;
    public static final int SHARE_SCORE_SUBMIT_FAILED                   = 5;
    public static final int SHARE_USER_LOGIN_SUCCESS                    = 6;
    public static final int SHARE_USER_LOGIN_FAILED                     = 7;
    public static final int SHARE_USER_LOGIN_ALREADY_LOGGED_IN          = 8;
    public static final int SHARE_GET_HIGHSCORE_SUCCESS                 = 9;
    public static final int SHARE_GET_HIGHSCORE_FAILED                  = 10;
    public static final int SHARE_USER_NOT_AUTHENTICATED                = 11;
    public static final int SHARE_LOCAL_PLAYER_LEADERBOARD_SET_SUCCESS  = 12;
    public static final int SHARE_LOCAL_PLAYER_LEADERBOARD_SET_FAILED   = 13;
    public static final int SHARE_LEADERBOARD_INIT_SUCCESS              = 14;
    public static final int SHARE_LEADERBOARD_INIT_FAILED               = 15;
    public static final int SHARE_GET_PICTURE_SUCCESS                   = 16;
    public static final int SHARE_GET_PICTURE_FAILED                    = 17;

	public static void onShareResult(InterfaceShare obj, int ret, String msg) {
		final int curRet = ret;
		final String curMsg = msg;
		final InterfaceShare curAdapter = obj;
		PluginWrapper.runOnGLThread(new Runnable() {
			@Override
			public void run() {
				String name = curAdapter.getClass().getName();
				name = name.replace('.', '/');
				nativeOnShareResult(name, curRet, curMsg);
			}
		});
	}
	private static native void nativeOnShareResult(String className, int ret, String msg);
}