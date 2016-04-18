package org.cocos2dx.plugin;

import java.util.Hashtable;

public interface InterfaceNotifications {

	public final int PluginType = 7;

	public void configDeveloperInfo(Hashtable<String, String> cpInfo);
	public void setDebugMode(boolean debug);
	public String getPluginVersion();
}
