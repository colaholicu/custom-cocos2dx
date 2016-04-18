package com.appatomic.lib.gamecenter;


import android.app.Activity;
import android.content.Context;

import android.content.IntentSender;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.common.api.ResultCallback;
import com.google.android.gms.common.api.ResultCallbacks;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.common.images.ImageManager;
import com.google.android.gms.games.Games;
import com.google.android.gms.games.Player;
import com.google.android.gms.games.PlayerBuffer;
import com.google.android.gms.games.Players;
import com.google.android.gms.games.achievement.Achievement;
import com.google.android.gms.games.achievement.AchievementBuffer;
import com.google.android.gms.games.achievement.Achievements;
import com.google.android.gms.games.leaderboard.LeaderboardScore;
import com.google.android.gms.games.leaderboard.LeaderboardScoreBuffer;
import com.google.android.gms.games.leaderboard.LeaderboardVariant;
import com.google.android.gms.games.leaderboard.Leaderboards;

import org.cocos2dx.plugin.InterfaceSocial;
import org.cocos2dx.plugin.SocialWrapper;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Collection;
import java.util.Hashtable;
import java.util.Vector;


class GCMOnImageLoadedListener implements ImageManager.OnImageLoadedListener
{
    public GCMOnImageLoadedListener(String iimagePath, String iplayerId)
    {
        imagePath = iimagePath;
        playerId = iplayerId;
    }

    @Override
    public void onImageLoaded(Uri uri, Drawable arg1, boolean isRequestedDrawable)
    {
        try
        {
            Bitmap bm = ((BitmapDrawable)arg1).getBitmap();
            ByteArrayOutputStream stream = new ByteArrayOutputStream();
            bm.compress(Bitmap.CompressFormat.PNG, 100, stream);
            byte[] byteArray = stream.toByteArray();

            try
            {
                File directory = new File(imagePath);

                // if specified not exist create new
                if(!directory.exists())
                {
                    directory.mkdir();
                }

                // checks the file and if it already exist delete
                String imageName = "gcm_" + playerId;
                File image = new File (directory, imageName);

                if (image.exists())
                {
                    image.delete();
                }

                FileOutputStream fos = new FileOutputStream(image);

                fos.write(byteArray, 0, byteArray.length);
                fos.close();
                SocialWrapper.onSocialResult(GameCenterManager.getInst(), GameCenterManager.GET_PICTURE_SUCCESS, playerId);
                Log.d("app", "Image Saved!");
            }
            catch(IOException io)
            {
                io.printStackTrace();
            }
            catch(Exception e)
            {
                e.printStackTrace();
            }

            //Log.d("app", "LoadImageFromGoogle Image added #" + uri);
        }
        catch (Exception e)
        {
            Log.d("app", "LoadImageFromGoogle after loading Exception = " + e.toString());
        }
    }

    private String imagePath;
    private String playerId;
}

public class GameCenterManager implements InterfaceSocial, GoogleApiClient.ConnectionCallbacks,
        GoogleApiClient.OnConnectionFailedListener
{
    // code for leaderboard feature
    public static final int SCORE_SUBMIT_SUCCESS = 1;
    public static final int SCORE_SUBMIT_FAILED = 2;
    // code for achievement feature
    public static final int ACH_UNLOCK_SUCCESS = 3;
    public static final int ACH_UNLOCK_FAILED = 4;
    public static final int USER_LOGIN_SUCCESS = 5;
    public static final int USER_LOGIN_FAILED = 6;
    public static final int USER_LOGIN_ALREADY_LOGGED_IN = 7;
    public static final int GET_HIGHSCORE_SUCCESS = 8;
    public static final int GET_HIGHSCORE_FAILED = 9;
    public static final int USER_NOT_AUTHENTICATED = 10;
    public static final int LOCAL_PLAYER_LEADERBOARD_SET_SUCCESS = 11;
    public static final int LOCAL_PLAYER_LEADERBOARD_SET_FAILED = 12;
    public static final int LEADERBOARD_INIT_SUCCESS = 13;
    public static final int LEADERBOARD_INIT_FAILED = 14;
    public static final int GET_PICTURE_SUCCESS = 15;
    public static final int GET_PICTURE_FAILED = 16;

	private final static String LOG_TAG = "GameCenterManager";
	private static Activity mContext = null;
    private static GameCenterManager inst = null;
	private static boolean bDebug = true;
    // Client used to interact with Google APIs
    private GoogleApiClient mGoogleApiClient;
    private boolean isLoggedIn = false;
    private int leaderboardSize = 0;
    private long leaderboardHighScore = 0;
    private Player playerRef;
    private JSONObject mHighScoreList;
    private Vector<ImageManager.OnImageLoadedListener> imgListners = new Vector<ImageManager.OnImageLoadedListener>();
    private ImageManager imageManager;

    public static GameCenterManager getInst()
    {
        return inst;
    }

    protected static void LogE(String msg, Exception e) {
		Log.e(LOG_TAG, msg, e);
		e.printStackTrace();
	}

	protected static void LogD(String msg) {
		if (bDebug)
        {
			Log.d(LOG_TAG, msg);
		}
	}

	public GameCenterManager(Context context)
    {
        LogD("GameCenterManager created");
		mContext = (Activity) context;
        imageManager = ImageManager.create(context);
        inst = this;
	}

    public void submitScore(String leadboardID, long score)
    {
        Games.Leaderboards.submitScore(mGoogleApiClient, leadboardID, score);
    }

    public void getPlayerHighScoreFromServer()
    {
        SocialWrapper.onSocialResult(this, GET_HIGHSCORE_SUCCESS, "");
    }

    public long getPlayerHighScore()
    {
        return leaderboardHighScore;
    }

    public void getLeaderboard()
    {
    }

    public long getLeaderboardSize()
    {
        return leaderboardSize;
    }

    public void unlockAchievementCustomBanner(String achievementId, float progress, String title, String message)
    {
        Games.Achievements.unlock(mGoogleApiClient, achievementId);
    }

    public void unlockAchievement(String achievementId, float progress)
    {
        Games.Achievements.unlock(mGoogleApiClient, achievementId);
    }

    public void forceResetAchievements()
    {
        // not available
    }

    public void showLeaderboard(String leaderboardID)
    {
    }

    public void getPlayerPictureFromServer(JSONObject info)
    {
        String playerId	 	= info.optString("Param1");
        String imagePath	= info.optString("Param2");
        Player p = null;

        if(playerRef != null && playerId.equals(playerRef.getPlayerId()))
        {
            p = Games.Players.getCurrentPlayer(mGoogleApiClient);
        }
        else
        {
            Players.LoadPlayersResult result = Games.Players.loadPlayer(mGoogleApiClient, playerId).await();
            PlayerBuffer pb = result.getPlayers();

            if(pb.getCount() > 0)
            {
                p = pb.get(0);
            }
        }

        if(p != null)
        {
            Uri uri = null;

            if(p.hasHiResImage())
            {
                uri = p.getHiResImageUri();
            }
            else if(p.hasIconImage())
            {
                uri = p.getIconImageUri();
            }

            if(uri != null)
            {
                final Uri furi = uri;
                final ImageManager.OnImageLoadedListener imgListener = new GCMOnImageLoadedListener(imagePath, playerId);
                imgListners.add(imgListener);

                Handler mainHandler = new Handler(mContext.getMainLooper());
                Runnable myRunnable = new Runnable()
                {
                    @Override
                    public void run()
                    {
                        imageManager.loadImage(imgListener, furi);
                    }
                };
                mainHandler.post(myRunnable);
            }
        }
    }

    public void getPlayerPicture(JSONObject info) {
        getPlayerPictureFromServer(info);
    }

    public void getPlayerProfilePicture(JSONObject info)
    {
        getPlayerPictureFromServer(info);
    }

    public void initializeLeaderboardForLoggedPlayer(String leaderboardID)
    {
        //leaderboardID = "CgkI49Kzv4keEAIQBw";
        int maxResults = 25;
        final InterfaceSocial adapter = this;
        mHighScoreList = new JSONObject();

        Games.Leaderboards.loadPlayerCenteredScores(mGoogleApiClient,
                leaderboardID,
                LeaderboardVariant.TIME_SPAN_ALL_TIME,
                LeaderboardVariant.COLLECTION_PUBLIC,
                maxResults).setResultCallback(
                new ResultCallbacks<Leaderboards.LoadScoresResult>()
                {
                    @Override
                    public void onSuccess(Leaderboards.LoadScoresResult result)
                    {
                        JSONArray scoresArray = new JSONArray();
                        LeaderboardScoreBuffer scores = result.getScores();
                        int scoreCount = scores.getCount();
                        String crtPlayerId = null;

                        if(playerRef != null)
                        {
                            crtPlayerId = playerRef.getPlayerId();
                        }

                        for (int k = 0; k < scoreCount; k++)
                        {
                            LeaderboardScore scr = scores.get(k);
                            JSONObject highScoreObject = new JSONObject();

                            try
                            {
                                String name = scr.getScoreHolder().getDisplayName();
                                long rawScore = scr.getRawScore();
                                String playerId = scr.getScoreHolder().getPlayerId();

                                if(crtPlayerId == playerId)
                                {
                                    leaderboardHighScore = scr.getRawScore();
                                }

                                highScoreObject.put("name", name);
                                highScoreObject.put("score", rawScore);
                                highScoreObject.put("id", playerId);
                                LogD("highscores name " + name + " score " + rawScore + " player-id " + playerId);
                            }
                            catch (JSONException e) { e.printStackTrace(); }

                            scoresArray.put(highScoreObject);
                            leaderboardSize = scoreCount;
                        }

                        try
                        {
                            mHighScoreList.put("data", scoresArray);
                        }
                        catch (JSONException e) { e.printStackTrace(); }

                        result.release();
                        SocialWrapper.onSocialResult(adapter, LEADERBOARD_INIT_SUCCESS, "");
                    }

                    @Override
                    public void onFailure(Status result)
                    {
                        SocialWrapper.onSocialResult(adapter, LEADERBOARD_INIT_FAILED, "");
                    }
                });

        // load achievements
//        Games.Achievements.load(mGoogleApiClient, true).setResultCallback(
//                new ResultCallback<Achievements.LoadAchievementsResult>()
//                {
//                    @Override
//                    public void onResult(Achievements.LoadAchievementsResult result)
//                    {
//                        AchievementBuffer achievements = result.getAchievements();
//                        int achievementCount = achievements.getCount();
//
//                        for (int k = 0; k < achievementCount; k++)
//                        {
//                            Achievement achv = achievements.get(k);
//
//                            if (achv.getState() == Achievement.STATE_UNLOCKED)
//                            {
//                                String achvId = achv.getName();
//                                LogD("achv on create" + achvId);
//                            }
//                        }
//
//                        result.release();
//                    }
//                });
    }

    public void loginUser()
    {
        LogD("loginUser");
        // Create the Google API Client with access to Games
        mGoogleApiClient = new GoogleApiClient.Builder(mContext)
                .addConnectionCallbacks(this)
                .addOnConnectionFailedListener(this)
                .addApi(Games.API).addScope(Games.SCOPE_GAMES)
                .build();

        LogD("starting GoogleApiClient");
        mGoogleApiClient.connect();
    }

    public String getLeaderboardJSON()
    {
        String jsonString = "[{}]";

        try
        {
            jsonString = mHighScoreList.toString(4);
        }
        catch (JSONException e)
        {
            e.printStackTrace();
        }

        return jsonString;
    }

    public boolean isUserLoggedInSettings()
    {
        return isLoggedIn;
    }

    public void update(float delta)
    {
    }

    public void configDeveloperInfo(Hashtable<String, String> var1)
    {
    }

    public void unlockAchievement(Hashtable<String, String> var1)
    {
        Collection<String> vals = var1.values();

        for (String val: vals)
        {
            Games.Achievements.unlock(mGoogleApiClient, val);
        }
    }

    public void showAchievements()
    {
    }

    public void setDebugMode(boolean var1)
    {
        bDebug = var1;
    }

    @Override
    public String getSDKVersion() {
        return null;
    }

    @Override
    public String getPluginVersion() {
        return null;
    }

    @Override
    public void onConnected(Bundle bundle)
    {
        LogD("onConnected(): connected to Google APIs");
        playerRef = Games.Players.getCurrentPlayer(mGoogleApiClient);
        isLoggedIn = true;
        SocialWrapper.onSocialResult(this, USER_LOGIN_SUCCESS, "");
    }

    @Override
    public void onConnectionSuspended(int i)
    {
        LogD("onConnectionSuspended(): attempting to connect");
        mGoogleApiClient.connect();
    }

    @Override
    public void onConnectionFailed(ConnectionResult connectionResult)
    {
        if (connectionResult.hasResolution())
        {
            try
            {
                connectionResult.startResolutionForResult(mContext, 1);
            }
            catch (IntentSender.SendIntentException e)
            {
                e.printStackTrace();
            }
        }
        else
        {
            SocialWrapper.onSocialResult(this, USER_LOGIN_FAILED, "");
        }
        LogD("onConnectionFailed(): attempting to resolve");
    }
}
