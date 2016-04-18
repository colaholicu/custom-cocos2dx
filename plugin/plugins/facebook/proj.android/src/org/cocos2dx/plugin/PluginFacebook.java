package org.cocos2dx.plugin;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.Map;
import java.util.Set;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLConnection;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.facebook.AccessToken;
import com.facebook.AccessTokenTracker;
import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.FacebookRequestError;
import com.facebook.GraphRequest;
import com.facebook.GraphRequest.GraphJSONObjectCallback;
import com.facebook.GraphResponse;
import com.facebook.appevents.AppEventsLogger;
import com.facebook.login.LoginManager;
import com.facebook.login.LoginResult;
import com.facebook.share.ShareApi;
import com.facebook.share.Sharer;
import com.facebook.share.Sharer.Result;
import com.facebook.share.model.ShareOpenGraphAction;
import com.facebook.share.model.ShareOpenGraphContent;
import com.facebook.share.model.ShareOpenGraphObject;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Bundle;
import android.util.Log;
import android.app.DownloadManager;
import android.net.Uri;

public class PluginFacebook implements InterfaceShare {

	private final static String LOG_TAG = "PluginFacebook";
	
	private final static String FACEBOOK_APP_ID = "827778650627063";
	
	private static Activity mContext = null;
	private static InterfaceShare mAdapter = null;
	private static CallbackManager mCallbackManager = null;
	
	private static AccessTokenTracker mAccessTokenTracker = null;
	private static AccessToken mAccessToken = null;
	
	private static boolean bDebug = true;
		
	private String 	mUserFirstName;
	private String 	mUserLastName;
	private String 	mPlayerID;
	private int		mPlayerScore;
	
	public JSONObject mHighScoreList = null;

	private boolean mPostingToFacebook = false;
	private String mShareFacebookScore = "";
	private String mShareFacebookMessage = "";
	
	protected static void LogE(String msg, Exception e) {
        Log.e(LOG_TAG, msg, e);
        e.printStackTrace();
    }

    protected static void LogD(String msg) {
        if (bDebug) {
            Log.d(LOG_TAG, msg);
        }
    }
    
    public Map<String, String> convertSetToMap(Set<String> set)
    {
        Map<String, String> myObjectMap = new HashMap<String, String>();

        for(String myObject: set){
            myObjectMap.put(myObject, myObject);
        }
        return myObjectMap;
    }
	
    public PluginFacebook(Context context) {
		mContext = (Activity)context;		
		mAdapter = this;
		
		mCallbackManager = CallbackManager.Factory.create();
		
		mAccessTokenTracker = new AccessTokenTracker() {
	        @Override
	        protected void onCurrentAccessTokenChanged( AccessToken oldAccessToken, AccessToken currentAccessToken) {
	            // Set the access token using 
	            // currentAccessToken when it's loaded or set.
	        	mAccessToken = currentAccessToken;
	        }
	    };
	    
	    // If the access token is available already assign it.
	    mAccessToken = AccessToken.getCurrentAccessToken();
		
		PluginWrapper.addListener( new PluginListener() {
			
			@Override
			public void onResume() {
				AppEventsLogger.activateApp(mContext);
			}
			
			@Override
			public void onPause() {
				AppEventsLogger.deactivateApp(mContext);
			}
			
			@Override
			public void onDestroy() {
				mAccessTokenTracker.stopTracking();
			}
			
			@Override
			public boolean onActivityResult(int arg0, int arg1, Intent arg2) {
				
				boolean result = true;
				result = mCallbackManager.onActivityResult(arg0, arg1, arg2);
				return result;
			}
		});
		
		LoginManager.getInstance().registerCallback(mCallbackManager, new FacebookCallback<LoginResult>() {
			
			@Override
			public void onSuccess(LoginResult result) {
				// TODO Auto-generated method stub
				LogD("login successful");
				ShareWrapper.onShareResult(mAdapter, ShareWrapper.SHARE_USER_LOGIN_SUCCESS, "Login Successful");
				
				doUserInfoRequest();
				
				if (mPostingToFacebook && !mShareFacebookMessage.isEmpty() && !mShareFacebookScore.isEmpty()) {
					postImageToFacebook(mShareFacebookScore, mShareFacebookMessage);
				}
					
			}
			
			@Override
			public void onError(FacebookException error) { 
				// TODO Auto-generated method stub
				LogD("error on login");
				ShareWrapper.onShareResult(mAdapter, ShareWrapper.SHARE_USER_LOGIN_FAILED, error.toString());
			}
			
			@Override
			public void onCancel() {
				// TODO Auto-generated method stub
				LogD("cancelled login");
				ShareWrapper.onShareResult(mAdapter, ShareWrapper.SHARE_USER_LOGIN_FAILED, "Login Cancelled");
			}
		});
	}
	
    public void login() {
    	PluginWrapper.runOnMainThread(new Runnable() {
			@Override
			public void run() {

				LogD("logging in to facebook!");
								
				if (mAccessToken != null && !mAccessToken.isExpired()) {
					Map<String, String> myObjectMap = convertSetToMap(mAccessToken.getPermissions());
					
					if (myObjectMap.containsValue("user_friends")) {
						
						ShareWrapper.onShareResult(mAdapter, ShareWrapper.SHARE_USER_LOGIN_SUCCESS, "Login Successful");
						
						// graph request to get user first and last name
						doUserInfoRequest();
						
						// return, we're already logged in with proper permissions
						return;
					}
				}
				
				LoginManager.getInstance().logInWithReadPermissions(mContext, Arrays.asList("public_profile", "email", "user_friends"));
			}
		});
    }
    
    private void doUserInfoRequest () {
    	
    	GraphRequest request = GraphRequest.newMeRequest(mAccessToken, new GraphJSONObjectCallback() {
			
			@Override
			public void onCompleted(JSONObject object, GraphResponse response) {

				try {
					
					mPlayerID 		= object.getString("id");
					mUserFirstName 	= object.getString("first_name");
					mUserLastName 	= object.getString("last_name");
					
					ShareWrapper.onShareResult(mAdapter, ShareWrapper.SHARERESULT_SUCCESS, "retrieved_player_info");
					
					LogD("\n-------------------------\n mPlayerID = " + mPlayerID + ", mUserFirstName = " + mUserFirstName + ", mUserLastName = " + mUserLastName);
				}
				catch (NullPointerException e) { e.printStackTrace(); }
				catch (NumberFormatException e) { e.printStackTrace(); } 
				catch (JSONException e) { e.printStackTrace(); }								
			}
		});
		
		Bundle parameters = new Bundle();
		parameters.putString("fields", "id,first_name,last_name");
		
		request.setParameters(parameters);
		request.executeAsync();
    }
    
    public boolean isLoggedIn() {
    	return mAccessToken != null;
    }
    
    public void logout() {
    	
    }
    
    public void postImageToFacebook(String highscore, String message) {
    	
    	ShareOpenGraphObject graphObject = new ShareOpenGraphObject.Builder()
    			.putString("og:type", "fbrunningsquaredtest:score")
    			.putString("og:title", highscore)
    			.putString("og:description", message)
    			.putString("og:image", "https://scontent-fra3-1.xx.fbcdn.net/hphotos-xpt1/t31.0-8/11703556_844206545647674_4089494194863302883_o.jpg")
    			.putString("og:url", "https://www.facebook.com/dontbesquaredgame")
    			.putString("fb:app_id", FACEBOOK_APP_ID)
    			.build();
    	
    	ShareOpenGraphAction graphAction = new ShareOpenGraphAction.Builder()
    			.setActionType("fbrunningsquaredtest:get")
    			.putObject("score", graphObject)
    			.putString("fb:explicitly_shared", "true")
    			.build();
    	
    	ShareOpenGraphContent graphContent = new ShareOpenGraphContent.Builder()
    			.setPreviewPropertyName("score")
    			.setAction(graphAction)
    			.build();
    	
    	ShareApi.share(graphContent, new FacebookCallback<Sharer.Result>() {

			@Override
			public void onSuccess(Result result) {
				// TODO Auto-generated method stub
				ShareWrapper.onShareResult(mAdapter, ShareWrapper.SHARERESULT_SUCCESS, "share_score_success");
			}

			@Override
			public void onCancel() {
				// TODO Auto-generated method stub
				ShareWrapper.onShareResult(mAdapter, ShareWrapper.SHARERESULT_CANCEL, "share_score_cancelled");
			}

			@Override
			public void onError(FacebookException error) {
				// TODO Auto-generated method stub
				ShareWrapper.onShareResult(mAdapter, ShareWrapper.SHARERESULT_FAIL, error.getMessage());
			}
		});
    }
    
    public void postImageToFB(JSONObject info) {
    	String highScore	= info.optString("Param1");
    	String message		= info.optString("Param2");
    	
    	mShareFacebookScore		= new String();
		mShareFacebookMessage	= new String();
    	
    	if (mAccessToken != null && !mAccessToken.isExpired()) {
    		Map<String, String> myObjectMap = convertSetToMap(mAccessToken.getPermissions());
			
			if (!myObjectMap.containsValue("publish_actions")) {
				
				mPostingToFacebook 		= true;
				mShareFacebookScore 	= highScore;
				mShareFacebookMessage	 = message;
				
				LoginManager.getInstance().logInWithPublishPermissions(mContext, Arrays.asList("publish_actions"));
				return;
			}
    	}
    	
    	postImageToFacebook(highScore, message);
    }
    
	public void shareScoreString(final String score) {    	
		if (isLoggedIn())
		{
			GraphRequest request = GraphRequest.newGraphPathRequest( mAccessToken, "/me/scores", new GraphRequest.Callback() {
			    @Override
			    public void onCompleted(GraphResponse response) {
			    	FacebookRequestError error = response.getError();
  			    	if (error == null) {
  			    		
  			    		JSONArray responseData = null;
  	  			    	
  						try {
  							responseData = response.getJSONObject().getJSONArray("data");
  						} 
  						catch (JSONException e) { e.printStackTrace(); }
  						
  						int currentScore = 0;
  						if (responseData.length() > 0) {
  							currentScore = responseData.optJSONObject(0).optInt("score");
  						}
  						
  						int newScore = Integer.valueOf(score);
  						
  						// check if new score > current score
  						if (newScore > currentScore) {
  							
  							JSONObject scoreParam = null;
							try {
								scoreParam = new JSONObject().put("score", newScore);
							} 
							catch (JSONException e) { e.printStackTrace(); }
  							
  							GraphRequest request = GraphRequest.newPostRequest(
  								  mAccessToken,
  								  "/me/scores",
  								  scoreParam,
  								  new GraphRequest.Callback() {
  								    @Override
  								    public void onCompleted(GraphResponse response) {
  								    	if (response.getError() == null) {
  								    		ShareWrapper.onShareResult(mAdapter, ShareWrapper.SHARE_SCORE_SUBMIT_SUCCESS, "score submit succesful");
  								    	} else {
  								    		ShareWrapper.onShareResult(mAdapter, ShareWrapper.SHARE_SCORE_SUBMIT_FAILED, response.getError().getErrorMessage());
  								    	}
  								    }
  								});
  								request.executeAsync();
  						}
  						else {
  							ShareWrapper.onShareResult(mAdapter, ShareWrapper.SHARE_SCORE_SUBMIT_SUCCESS, "score submit succesful");
  						}
  			    	}
  			    	else {
  			    		ShareWrapper.onShareResult(mAdapter, ShareWrapper.SHARE_SCORE_SUBMIT_FAILED, error.getErrorMessage());
  			    	}
			    }
			});

			Bundle parameters = new Bundle();
			parameters.putString("fields", "score");
			request.setParameters(parameters);
			request.executeAsync();
		}
	}
    
    public void getPlayerHighScoreFromServer() {
    	if (isLoggedIn())
		{
    		GraphRequest request = GraphRequest.newGraphPathRequest(
  			  mAccessToken,
  			  "/" + FACEBOOK_APP_ID +"/scores",
  			  new GraphRequest.Callback() {
  			    @Override
  			    public void onCompleted(GraphResponse response) {
  			    	
  			    	FacebookRequestError error = response.getError();
  			    	if (error == null) {
  			    		
  			    		JSONArray responseData = null;
  	  			    	
  						try {
  							responseData = response.getJSONObject().getJSONArray("data");
  						} 
  						catch (JSONException e) { e.printStackTrace(); }
  	  			    	
  	  			    	if (responseData.length() <= 0) {
  	  			    		ShareWrapper.onShareResult(mAdapter, ShareWrapper.SHARE_GET_HIGHSCORE_FAILED, "No scores found for this app!");
  	  			    	}
  	  			    	else {
  	  			    		
  	  			    		mHighScoreList = new JSONObject();
  	  			    		
  	  			    		JSONArray scoresArray = new JSONArray();
  	  			    		  			    		
  	  			    		for (int i = 0; i < responseData.length(); i++) {
  								
  	  			    			JSONObject userData = responseData.optJSONObject(i);
  								if (userData == null) continue;
  								
  								JSONObject userJson = userData.optJSONObject("user");
  								if (userJson == null) continue;
  								
  								int score = userData.optInt("score");
  								String userID = userJson.optString("id");
  								
  								LogD("current user ID = " + userID);
  								
  								JSONObject highScoreObject = new JSONObject();
  								try {
									highScoreObject.put("rank", i+1);
									highScoreObject.put("score", score);
	  								highScoreObject.put("id", userID);
	  								
	  								if (userID.equals(mPlayerID)) {
	  									mPlayerScore = score;
	  									highScoreObject.put("name", "ME");
	  								} else {
	  									highScoreObject.put("name", userJson.optString("name"));
	  								}
								} 
  								catch (JSONException e) { e.printStackTrace(); }

  								LogD("HighScoreObject : " + highScoreObject.toString());
  								
  								scoresArray.put(highScoreObject);
  							}
  	  			    		
  	  			    		try {
								mHighScoreList.put("data", scoresArray);
							} 
  	  			    		catch (JSONException e) { e.printStackTrace(); }

  	  			    		ShareWrapper.onShareResult(mAdapter, ShareWrapper.SHARE_GET_HIGHSCORE_SUCCESS, "share success");
  	  			    	}
  			    	
  			    	
  			    	}
  			    	else {
  			    		ShareWrapper.onShareResult(mAdapter, ShareWrapper.SHARE_GET_HIGHSCORE_FAILED, error.toString());
  			    	}
  			    }
  			});

  			Bundle parameters = new Bundle();
  			parameters.putString("fields", "score,user");
  			parameters.putString("limit", "100");
  			request.setParameters(parameters);
  			request.executeAsync();
		}
    	
    	
    }
    
    public String getPlayerId(String item) {
    	return mPlayerID;
    }
    
    public int getLocalPlayerScore() {
    	return mPlayerScore;
    }
    
    public String getPlayerFirstName() {
    	return mUserFirstName;
    }
    
    public String getPlayerLastName() {
    	return mUserLastName;
    }
    
    public String getLeaderboardJSON() {
    	
    	String jsonString = "[{}]";
		try {
			jsonString = mHighScoreList.toString(4);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    	return jsonString;
    }
    
    public void getPlayerProfilePicture(JSONObject info) {
    	
    	String playerID	 	= info.optString("Param1");
    	String imagePath	= info.optString("Param2");
    	    	
    	LogD("playerID" + playerID + "image path" + imagePath);
    	
        try {
            URL url = new URL("https://graph.facebook.com/" + playerID + "/picture?type=square&return_ssl_resources=1"); 

            File directory = new File(imagePath);

            /*  if specified not exist create new */
            if(!directory.exists())
            {
            	directory.mkdir();
            }

            /* checks the file and if it already exist delete */
            String imageName = "fbp_" + playerID;
            File image = new File (directory, imageName);
            if (image.exists ()) 
            	image.delete (); 

            /* Open a connection */
            URLConnection urlConnection = url.openConnection();
            InputStream inputStream = null;
            HttpURLConnection httpConnection = (HttpURLConnection)urlConnection;
            httpConnection.setRequestMethod("GET");
            httpConnection.connect();
            inputStream = httpConnection.getInputStream();

            FileOutputStream fos = new FileOutputStream(image);  
            
            int totalSize = httpConnection.getContentLength();
            int downloadedSize = 0;   
            byte[] buffer = new byte[1024];
            int bufferLength = 0;
            
            while ( (bufferLength = inputStream.read(buffer)) >0 )  {                 
                fos.write(buffer, 0, bufferLength);                  
                downloadedSize += bufferLength;                 
                Log.i("Progress:","downloadedSize:"+downloadedSize+"totalSize:"+ totalSize);
            }   

            fos.close();
            LogD("Image Saved!");  
        }
        catch(IOException io) {                  
            io.printStackTrace();
        }
        catch(Exception e) {                     
            e.printStackTrace();
        }
    }
    
	@Override
	public void configDeveloperInfo(Hashtable<String, String> arg0) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public String getPluginVersion() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public String getSDKVersion() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public void setDebugMode(boolean arg0) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void share(Hashtable<String, String> arg0) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void shareScore(long arg0) {
		// TODO Auto-generated method stub
	}
}
