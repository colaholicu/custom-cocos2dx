//
//  GameCenterManager.m
//  GameCenter
//
//  Created by Iosif Murariu on 09/02/2015.
//  Copyright (c) 2015 Iosif Murariu. All rights reserved.
//

#import "GameCenterManager.h"
#import "SocialWrapper.h"

@implementation GameCenterManager


#define OUTPUT_LOG(...)     if (m_debugMode) NSLog(__VA_ARGS__);


#pragma mark --- IntefaceSocial
-(void) showLeaderboard:(NSString *)leaderboardID
{
//    [[GameCenterHelper instance] requestHighScoreList: leaderboardID];
}

- (void) setDebugMode:(BOOL)debug
{
    m_debugMode = debug;
}

#pragma mark --- GKGameCenterViewController
- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:^{
        if ([GKLocalPlayer localPlayer].authenticated) {
            NSString *errorString = [NSString stringWithFormat:@"%s ---- user logged in", __FUNCTION__];
            [SocialWrapper onSocialResult:self withRet:kUserLoginSuccess withMsg:errorString];
        } else {
            NSString *errorString = [NSString stringWithFormat:@"%s ---- user login either failed or was cancelled", __FUNCTION__];
            [SocialWrapper onSocialResult:self withRet:kUserLoginFailed withMsg:errorString];
        }
    }];
}
#pragma mark --- utility
- (void) initialize:(NSString *)leaderboardID
{
    if (![GameCenterManager isGameCenterAvailable])
        return;
    
    m_isAuthenticated = FALSE;
    
    m_viewController = [GameCenterManager getRootViewController];
    
    // listener to authentication
    [[NSNotificationCenter defaultCenter] addObserver:self
           selector:@selector(authenticationChanged)
               name:GKPlayerAuthenticationDidChangeNotificationName
             object:nil];
    
    [[GKLocalPlayer localPlayer] setDefaultLeaderboardIdentifier:leaderboardID completionHandler:^(NSError *error) {
        NSString *errorString = [NSString stringWithFormat:@"%s ---- error=%@", __FUNCTION__, error];
        if (error != nil) {
            [SocialWrapper onSocialResult:self withRet:kLocalPlayerLeaderboardSetFailed withMsg:errorString];
        } else {
            [SocialWrapper onSocialResult:self withRet:kLocalPlayerLeaderboardSetSucceded withMsg:errorString];
        }
    }];
    
    m_playerScore = 0;
    m_highScoresList = NULL;
    m_highScoresListSize = 0;
    m_leaderboardIdentifier = nil;
}

- (void) authenticationChanged {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if (m_isAuthenticated == [GKLocalPlayer localPlayer].authenticated)
            return;
        
        m_isAuthenticated = [GKLocalPlayer localPlayer].authenticated;
        
        if ([GKLocalPlayer localPlayer].authenticated) {
            [SocialWrapper onSocialResult:self withRet:kUserLoginSuccess withMsg:@"authenticationChanged"];
        }
    });
}

+ (UIViewController*) getRootViewController
{
    UIViewController *result = nil;
    
    // Try to find the root view controller programmically
    
    // Find the top window (that is not an alert view or other window)
    UIWindow *topWindow = [[UIApplication sharedApplication] keyWindow];
    if (topWindow.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(topWindow in windows)
        {
            if (topWindow.windowLevel == UIWindowLevelNormal)
                break;
        }
    }
    
    UIView *rootView = [[topWindow subviews] objectAtIndex:0];
    id nextResponder = [rootView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else if ([topWindow respondsToSelector:@selector(rootViewController)] && topWindow.rootViewController != nil)
        result = topWindow.rootViewController;
    else
        NSAssert(NO, @"Could not find a root view controller.");
    
    return result;
}

/*
 @brief Checks if all requirements for using game center have been met
 @return a boolean that is true if all the requirements for game center have been met
 */
+ (BOOL) isGameCenterAvailable
{
    // check for presence of GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    // check if the device is running iOS 4.1 or later
    NSString *reqSysVer = @"4.1";
    
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}

- (bool) isUserLoggedInSettings
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"gameCenterOn"];
}
- (void) loginUser
{
    // user already logged in
    if ([GKLocalPlayer localPlayer].isAuthenticated) {
        NSString *errorString = [NSString stringWithFormat:@"%s ---- 1. user already logged in", __FUNCTION__];
        [SocialWrapper onSocialResult:self withRet:kUserLoginAlreadyLoggedIn withMsg:errorString];
        return;
    }
    
    // use non-deprecated method :D
    if (m_viewController)
    {
        [GKLocalPlayer localPlayer].authenticateHandler = ^(UIViewController* viewcontroller, NSError *error) {
            if ([GKLocalPlayer localPlayer].isAuthenticated) {
                NSString *errorString = [NSString stringWithFormat:@"%s ---- 2. user already logged in", __FUNCTION__];
                [SocialWrapper onSocialResult:self withRet:kUserLoginAlreadyLoggedIn withMsg:errorString];
                return;
            }
            
            // show login screen
            if (viewcontroller != nil) {
                [m_viewController presentViewController:viewcontroller animated:YES completion:nil];
                return;
            }
            
            NSString *errorString = [NSString stringWithFormat:@"%s >> error=%@", __FUNCTION__, error];
            if (!error) {
                [SocialWrapper onSocialResult:self withRet:kUserLoginAlreadyLoggedIn withMsg:errorString];
            } else {
                [SocialWrapper onSocialResult:self withRet:kUserLoginFailed withMsg:errorString];
            }
        };
    } else {
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error)  {
            NSString *errorString = [NSString stringWithFormat:@"%s >> error=%@", __FUNCTION__, error];
            if (error == nil) {
                [SocialWrapper onSocialResult:self withRet:kUserLoginSuccess withMsg:errorString];
            } else {
                [SocialWrapper onSocialResult:self withRet:kUserLoginFailed withMsg:errorString];
            }
        }];
    }
}

- (void) initializeLeaderboardForLoggedPlayer:(NSString *)leaderboardID
{
    if (![GKLocalPlayer localPlayer].isAuthenticated)
    {
        NSString *errorString = [NSString stringWithFormat:@"%s >> [GKLocalPlayer localPlayer].authenticated=%d", __FUNCTION__, [GKLocalPlayer localPlayer].authenticated];
        [SocialWrapper onSocialResult:self withRet:kLeaderboardInitFailed withMsg:errorString];
        return;
    }
    
    [[GKLocalPlayer localPlayer] loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString *leaderboardIdentifier, NSError *error) {
        NSString *errorString = [NSString stringWithFormat:@"%s >> error=%@", __FUNCTION__, error];
        if (error != nil) {
            [SocialWrapper onSocialResult:self withRet:kLeaderboardInitFailed withMsg:errorString];
        } else {
            m_leaderboardIdentifier = leaderboardIdentifier;
            OUTPUT_LOG(@"%s ----> m_leaderboardIdentifier = %@", __FUNCTION__, m_leaderboardIdentifier);
            
            if ((m_leaderboardIdentifier == nil) || !m_leaderboardIdentifier.length)
            {
                NSString *errorString = [NSString stringWithFormat:@"%s >> null or bad length -> m_leaderboardIdentifier=%@", __FUNCTION__, m_leaderboardIdentifier];
                [SocialWrapper onSocialResult:self withRet:kLeaderboardInitFailed withMsg:errorString];
            }
            else
            {
                [SocialWrapper onSocialResult:self withRet:kLeaderboardInitSuccess withMsg:errorString];
            }
        }
    }];
}


- (void) submitScore:(NSString *)leaderboardID withScore:(long)score
{
    if (![GKLocalPlayer localPlayer].isAuthenticated)
    {
        NSString *errorString = [NSString stringWithFormat:@"%s >> [GKLocalPlayer localPlayer].authenticated=%d", __FUNCTION__, [GKLocalPlayer localPlayer].authenticated];
        [SocialWrapper onSocialResult:self withRet:kSubmitScoreFailed withMsg:errorString];
        return;
    }
    
    if ((m_leaderboardIdentifier == nil) || !m_leaderboardIdentifier.length)
    {
        NSString *errorString = [NSString stringWithFormat:@"%s >> null or bad length -> m_leaderboardIdentifier=%@", __FUNCTION__, m_leaderboardIdentifier];
        [SocialWrapper onSocialResult:self withRet:kSubmitScoreFailed withMsg:errorString];
        return;
    }
    
    OUTPUT_LOG(@"%s ----> m_leaderboardIdentifier = %@", __FUNCTION__, m_leaderboardIdentifier);
    GKScore *scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier:m_leaderboardIdentifier];
    scoreReporter.value = (long long)score;
    [GKScore reportScores:@[scoreReporter] withCompletionHandler: ^(NSError *error)
     {
         NSString *errorString = [NSString stringWithFormat:@"%s >> scoreReporter.value=%@, error=%@", __FUNCTION__, scoreReporter, error];
         if (error != nil) {
             [SocialWrapper onSocialResult:self withRet:kSubmitScoreFailed withMsg:errorString];
         } else {
             [SocialWrapper onSocialResult:self withRet:kSubmitScoreSuccess withMsg:errorString];
         }
     }];
}

- (void) getPlayerHighScoreFromServer
{
    OUTPUT_LOG(@"%s ----> m_leaderboardIdentifier = %@", __FUNCTION__, m_leaderboardIdentifier);
    if (![GKLocalPlayer localPlayer].isAuthenticated || (m_leaderboardIdentifier == nil) || !m_leaderboardIdentifier.length)
    {
        NSString *errorString = [NSString stringWithFormat:@"%s >> authenticated=%d, m_leaderboardIdentifier=%@", __FUNCTION__, [GKLocalPlayer localPlayer].authenticated, m_leaderboardIdentifier];
        [SocialWrapper onSocialResult:self withRet:kGetHighScoreFailed withMsg:errorString];
        return;
    }
    
    GKLeaderboard* leaderboardRequest = [[GKLeaderboard alloc] init];
    if  (leaderboardRequest == nil)
    {
        NSString *errorString = [NSString stringWithFormat:@"%s >> leaderboardRequest=%@", __FUNCTION__, leaderboardRequest];
        [SocialWrapper onSocialResult:self withRet:kGetHighScoreFailed withMsg:errorString];
        return;
    }
    
    leaderboardRequest.playerScope = GKLeaderboardPlayerScopeFriendsOnly ;
    leaderboardRequest.timeScope = GKLeaderboardTimeScopeAllTime ;
    leaderboardRequest.range =  NSMakeRange (1, 100);
    leaderboardRequest.identifier = m_leaderboardIdentifier;
    
    [leaderboardRequest loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error) {
        NSString *errorString = [NSString stringWithFormat:@"%s >> error=%@", __FUNCTION__, error];
        
        // time to cleanup first
        if (m_highScoresList != NULL)
        {
            for (int i = 0; i < m_highScoresListSize; i++)
            {
                if (m_highScoresList[i].m_fullName != NULL)
                {
                    free(m_highScoresList[i].m_fullName);
                    m_highScoresList[i].m_fullName = NULL;
                }
                
                if (m_highScoresList[i].m_playerId != NULL)
                {
                    free(m_highScoresList[i].m_playerId);
                    m_highScoresList[i].m_playerId = NULL;
                }
            }
            free(m_highScoresList);
            m_highScoresList = NULL;
        }
        
        m_highScoresListSize = 0;
        
        // error
        if (!scores || error)
        {
            [SocialWrapper onSocialResult:self withRet:kGetHighScoreFailed withMsg:errorString];
            return;
        }
        
        m_playerScore = leaderboardRequest.localPlayerScore.value;
        
        m_highScoresListSize = scores.count;
        m_highScoresList = (GCHighScoreList*)malloc(m_highScoresListSize * sizeof(GCHighScoreList));
        memset(m_highScoresList, 0, m_highScoresListSize * sizeof(GCHighScoreList));
        
        int i = 0;
        for (GKScore* score in scores)  {
            OUTPUT_LOG(@"%s >> SUCCESS >> score=%lld for player=%@", __FUNCTION__, score.value, score.player);
            m_highScoresList[i].m_rank = score.rank;
            m_highScoresList[i].m_score = score.value;
            m_highScoresList[i].m_fullName = strdup([score.player.displayName UTF8String]);
            m_highScoresList[i].m_playerId = strdup([score.player.playerID UTF8String]);
            i++;
        }
        [SocialWrapper onSocialResult:self withRet:kGetHighScoreSuccess withMsg:errorString];
    }];
    
    return;
}

- (NSNumber*) getPlayerHighScore
{
    return [[NSNumber alloc] initWithInt:(int)m_playerScore];
}

- (void*) getLeaderboard
{
    return m_highScoresList;
}

- (NSNumber*) getLeaderboardSize
{
    return [[NSNumber alloc] initWithInt:(int)m_highScoresListSize];
}

- (void) getPlayerProfilePicture: (NSDictionary*) params
{
    OUTPUT_LOG(@"\n\n\n-------\n\n\nparams=%@\n\n\n-------\n\n\n", params);
    NSString* playerId = [params objectForKey:@"Param1"];
    NSString* strSavePath = [params objectForKey:@"Param2"];
    
    NSArray *playerIDs = [[NSArray alloc] initWithObjects: playerId, nil];
    [GKPlayer loadPlayersForIdentifiers:playerIDs withCompletionHandler:^(NSArray *players, NSError *error) {
        NSString *errorString = [NSString stringWithFormat:@"1. %s >> error=%@", __FUNCTION__, error];
        if (error || (players == nil))
        {
            [SocialWrapper onSocialResult:self withRet:kGetPictureFailed withMsg:errorString];
            return;
        }
        
        OUTPUT_LOG(@"\n\n\n-------\n\n\n players=%@\n\n\n-------\n\n\n", players);
        [[players objectAtIndex:0] loadPhotoForSize:GKPhotoSizeSmall withCompletionHandler:^(UIImage *photo, NSError *error) {
            NSString *errorString = [NSString stringWithFormat:@"2. %s >> error=%@", __FUNCTION__, error];
            if (photo != nil)
            {
                NSData * binaryImageData = UIImagePNGRepresentation(photo);
                NSString *imgFile = [strSavePath stringByAppendingPathComponent:[NSString stringWithFormat:@"gcp_%@", [playerId substringFromIndex:1]]];
                [binaryImageData writeToFile:imgFile atomically:YES];
                [SocialWrapper onSocialResult:self withRet:kGetPictureSuccess withMsg:imgFile];
            }
            if (error != nil || (photo == nil))
            {
                [SocialWrapper onSocialResult:self withRet:kGetPictureFailed withMsg:errorString];
            }
        }];
    }];
}

+ (void) reportAchievementById:(NSString*) achievementId
                    percentage:(NSNumber*) percentage
                        banner:(NSString*) bannerTitle
                       message: (NSString*) bannerMessage
{
    GKAchievement * achievement = [[GKAchievement alloc] initWithIdentifier:achievementId];
    if (achievement) {
        [achievement setPercentComplete: [percentage doubleValue]];
    }
    [GKAchievement reportAchievements: @[achievement] withCompletionHandler: ^(NSError *error){
        if (error) {
            // Shit
        } else {
            if ([achievement isCompleted] && [bannerTitle length]) { // Show our banner
                [GKNotificationBanner showBannerWithTitle:bannerTitle
                                                  message:bannerMessage
                                        completionHandler:^{
                                            // Banner showed
                                        }];
            }
        }
    }];
}

- (void) unlockAchievementWithParams:(NSDictionary*) params
{
    OUTPUT_LOG(@"\n\n\n-------\n\n\nparams=%@\n\n\n-------\n\n\n", params);
    NSString* achievementId = [params objectForKey:@"Param1"];
    NSNumber* percentage = [params objectForKey:@"Param2"];
    NSString* bannerTitle = [params objectForKey:@"Param3"];
    NSString* bannerMessage = [params objectForKey:@"Param4"];
    // for eventual repeatable achievements, add another param to force show the banner again
    
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error)
    {
        if (error == nil) {                
            BOOL reportAchievement = TRUE;
            for (GKAchievement* achievement in achievements)
            {
                if ([achievementId isEqualToString:achievement.identifier])
                {
                    reportAchievement = FALSE;
                    if (![achievement isCompleted]) // we have no repeatable achievements, so if it's already done, don't resend cause it'll show the banner again
                    {
                        achievement.percentComplete += [percentage doubleValue];
                        [GameCenterManager reportAchievementById:achievementId percentage:[NSNumber numberWithDouble:achievement.percentComplete] banner:bannerTitle message:bannerMessage];
                    }
                    break;
                }
            }
            if (reportAchievement) // not found in the list above, thus this is the first submission for this particular achievement
                [GameCenterManager reportAchievementById:achievementId percentage:percentage banner:bannerTitle message:bannerMessage];
        }
        else {
            NSLog(@"Error in loading achievements: %@", error);
        }
    }];
}

- (void) unlockAchievement:(NSMutableDictionary *) achInfo
{
    BOOL getProgress = FALSE;
    NSMutableArray<GKAchievement *> * achievementsToComplete = [NSMutableArray arrayWithCapacity: [achInfo count]];
    for (NSString* key in achInfo)
    {
        GKAchievement * achievement = [[GKAchievement alloc] initWithIdentifier:key];
        if (achievement) {
            NSString* percentage = achInfo[key];
            if ([percentage doubleValue] < 100.)
                getProgress = TRUE;
            [achievement setPercentComplete: [percentage doubleValue]];
            [achievement setShowsCompletionBanner:YES];
            [achievementsToComplete addObject:achievement];
        }
    }
    
    if (getProgress)
    {
        [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error)
         {
             if (error == nil) {
                 for (GKAchievement* achievementToUpdate in achievementsToComplete)
                     for (GKAchievement* achievement in achievements)
                         if ([[achievement identifier] isEqualToString:[achievementToUpdate identifier]])
                         {
                             achievementToUpdate.percentComplete += achievement.percentComplete;
                         }
                 [GKAchievement reportAchievements: achievementsToComplete withCompletionHandler: ^(NSError *error){}];
             }
         }];
    }
    else
        [GKAchievement reportAchievements: achievementsToComplete withCompletionHandler: ^(NSError *error){}];
}

- (void) forceResetAchievements
{
    [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error){}];
}
@end
