package org.cocos2dx.plugin;

public class NotificationWrapper {

	public static void onNotificationReceived(InterfaceNotifications adapter, String msg) {
		final String curMsg = msg;
		final InterfaceNotifications curObj = adapter;
		PluginWrapper.runOnGLThread(new Runnable(){
			@Override
			public void run() {
				String name = curObj.getClass().getName();
				name = name.replace('.', '/');
				NotificationWrapper.nativeOnNotificationReceived(name, curMsg);
			}
		});
	}
	private native static void nativeOnNotificationReceived(String className, String msg);
	
}
