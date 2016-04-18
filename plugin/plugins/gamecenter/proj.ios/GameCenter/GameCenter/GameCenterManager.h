//
//  GameCenterManager.h
//  GameCenter
//
//  Created by Iosif Murariu on 09/02/2015.
//  Copyright (c) 2015 Iosif Murariu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InterfaceSocial.h"
#import "GameKit/GameKit.h"

typedef struct {
    long    m_rank;
    int64_t m_score;
    char*   m_fullName;
    char*   m_playerId;
} GCHighScoreList;

@interface GameCenterManager : NSObject<InterfaceSocial, GKGameCenterControllerDelegate>
{
    int64_t             m_playerScore;
    
    NSString*           m_leaderboardIdentifier;
    
    UIViewController*   m_viewController;
    
    BOOL                m_isAuthenticated;
    BOOL                m_debugMode;
    
    GCHighScoreList*    m_highScoresList;
    int64_t             m_highScoresListSize;
}

// InterfaceSocial
- (void) setDebugMode: (BOOL) debug;
- (void) showLeaderboard:(NSString *)leaderboardID;
- (void) submitScore:(NSString *)leaderboardID withScore:(long)score;
- (void) getPlayerHighScoreFromServer;

// GKGameCenterControllerDelegate
- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController;

// utility
- (void) authenticationChanged;
- (void) initialize:(NSString *)leaderboardID;
- (void) loginUser;
- (void) initializeLeaderboardForLoggedPlayer:(NSString *)leaderboardID;
- (NSNumber*) getPlayerHighScore;
- (bool) isUserLoggedInSettings;
- (void*) getLeaderboard;
- (NSNumber*) getLeaderboardLength;
- (void) getPlayerProfilePicture: (NSDictionary*) params;

// achievements
+ (void) reportAchievementById:(NSString*) achievementId percentage:(NSNumber*) percentage banner:(NSString*) bannerTitle message: (NSString*) bannerMessage;
- (void) unlockAchievement:(NSMutableDictionary *)achInfo;
- (void) unlockAchievementWithParams:(NSDictionary*) params;
- (void) forceResetAchievements;

+ (UIViewController*) getRootViewController;

+ (BOOL) isGameCenterAvailable;
@end
