/****************************************************************************
 Copyright (c) 2013 cocos2d-x.org
 
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

#import "PluginFacebook.h"
#import "ShareWrapper.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKCoreKit/FBSDKGraphRequest.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>


#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);

#define FACEBOOK_APP_ID "827778650627063"

#define USE_HTTPS_INSTEAD_OF_GRAPH_API 1

@implementation PluginFacebook


@synthesize mShareInfo;
@synthesize debug = __debug;


- (void) configDeveloperInfo : (NSMutableDictionary*) cpInfo
{

}


- (void) share: (NSMutableDictionary*) shareInfo
{
    self.mShareInfo = shareInfo;
}


- (void) setDebugMode: (BOOL) debug
{
    self.debug = debug;
}


- (NSString*) getSDKVersion
{
    return @"2015-02-09";
}


- (NSString*) getPluginVersion
{
    return @"0.0.1";
}


- (void) doShare
{
//    if (nil == mShareInfo) {
//        [ShareWrapper onShareResult:self withRet:kShareFail withMsg:@"Shared info error"];
//        return;
//    }
//
//    NSString* strText = [mShareInfo objectForKey:@"SharedText"];
//    NSString* strImagePath = [mShareInfo objectForKey:@"SharedImagePath"];
//
//    BOOL oldConfig = [UIApplication sharedApplication].networkActivityIndicatorVisible;
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//    
//    NSError* returnCode = nil;
//    if (nil != strImagePath) {
//        NSData* data = [NSData dataWithContentsOfFile:strImagePath];
//        returnCode = [[FHSTwitterEngine sharedEngine] postTweet:strText withImageData:data];
//    } else {
//        returnCode = [[FHSTwitterEngine sharedEngine]postTweet:strText];
//    }
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = oldConfig;
//
//    if (returnCode) {
//        NSString* strErrorCode = [NSString stringWithFormat:@"ErrorCode %ld", (long)returnCode.code];
//        [ShareWrapper onShareResult:self withRet:kShareFail withMsg:strErrorCode];
//    } else {
//        [ShareWrapper onShareResult:self withRet:kShareSuccess withMsg:@"Share Succeed"];
//    }
}

- (UIViewController *)getCurrentRootViewController {

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


// --------------------------------------------------------------------------------------------------------------


- (BOOL) isLoggenIn
{
    return TRUE;
}


- (void) login
{
     NSLog(@"--------%@", [FBSDKSettings sdkVersion]);
    
    FBSDKAccessToken* token = [FBSDKAccessToken currentAccessToken];
    // ALWAYS check for user_friends
    if (token && [[token permissions] containsObject:@"user_friends"])
    {
        // success!!!
        [ShareWrapper onShareResult:self withRet:kShareUserLoginSuccess withMsg:[NSString stringWithFormat:@"already logged in with permissions: %@", [token permissions]]];
        
        // Get the player's id
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me?fields=id,first_name,last_name" parameters:nil HTTPMethod:@"GET"];
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            m_playerId = [[result objectForKey:@"id"] longLongValue];
            m_strFirstName = [NSString stringWithFormat:@"%@", [result objectForKey:@"first_name"]];
            m_strLastName = [NSString stringWithFormat:@"%@", [result objectForKey:@"last_name"]];
            [ShareWrapper onShareResult:self withRet:kShareSuccess withMsg:@"retrieved_player_info"];
            OUTPUT_LOG( @"\n-------------------------\n %s m_playerID = %lld, m_strFirstName = %@, m_strLastName = %@", __PRETTY_FUNCTION__, m_playerId, m_strFirstName, m_strLastName);
        }];
        return;
    }
    else
    {
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login logInWithReadPermissions:@[@"public_profile", @"email", @"user_friends"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
             NSString *errorString = [NSString stringWithFormat:@"%s ---- error=%@, approved=%@, declined=%@", __PRETTY_FUNCTION__, error, result.grantedPermissions, result.declinedPermissions];
             if (error) {
                 // error
                 [ShareWrapper onShareResult:self withRet:kShareUserLoginFailed withMsg:errorString];
             } else if (result.isCancelled) {
                 // login was cancelled
                 [ShareWrapper onShareResult:self withRet:kShareUserLoginFailed withMsg:errorString];
             } else if (result.declinedPermissions.count > 0) {
                 // some permissions were declined
                 [ShareWrapper onShareResult:self withRet:kShareUserLoginFailed withMsg:errorString];
             } else {
                 [ShareWrapper onShareResult:self withRet:kShareUserLoginSuccess withMsg:errorString];
                 
                 NSLog(@"--------%@", [FBSDKSettings sdkVersion]);
                 
                 
                 // Get the player's id
                 FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me?fields=id,first_name,last_name" parameters:nil HTTPMethod:@"GET"];
                 [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                     if (!error)
                     {
                         OUTPUT_LOG(@"\n-------------------------\n %s ---> initWithGraphPath: me?fields=id,first_name,last_name", __PRETTY_FUNCTION__);
                         m_playerId = [[result objectForKey:@"id"] longLongValue];
                         m_strFirstName = [NSString stringWithFormat:@"%@", [result objectForKey:@"first_name"]];
                         m_strLastName = [NSString stringWithFormat:@"%@", [result objectForKey:@"last_name"]];
                         [ShareWrapper onShareResult:self withRet:kShareSuccess withMsg:@"retrieved_player_info"];
                         OUTPUT_LOG( @"\n-------------------------\n %s m_playerID = %lld, m_strFirstName = %@, m_strLastName = %@", __PRETTY_FUNCTION__, m_playerId, m_strFirstName, m_strLastName);
                     }
                 }];
             }
        }];
    }
    
    m_highScoresList = NULL;
    m_highScoresListSize = 0;
}

- (void) logout
{
    OUTPUT_LOG( @"\n-------------------------\ncall logout\n-------------------------" );
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager logOut];
    
    [FBSDKAccessToken setCurrentAccessToken:nil];
}

- (void) postImageToFbImpl:(NSString *)strHighscore withMsg:(NSString *)strMessage
{
    NSDictionary *properties = @{
                                 @"og:type": @"fbrunningsquaredtest:score",
                                 @"og:title": strHighscore,
                                 @"og:description": strMessage,
                                 @"og:image": @"https://scontent-fra3-1.xx.fbcdn.net/hphotos-xpt1/t31.0-8/11703556_844206545647674_4089494194863302883_o.jpg",
                                 @"og:url": @"https://www.facebook.com/dontbesquaredgame",
                                 @"fb:app_id": @"827778650627063",
                                 };
    FBSDKShareOpenGraphObject *object = [FBSDKShareOpenGraphObject objectWithProperties:properties];
    FBSDKShareOpenGraphAction *action = [[FBSDKShareOpenGraphAction alloc] init];
    action.actionType = @"fbrunningsquaredtest:get";
    [action setObject:object forKey:@"score"];
    [action setString: @"true" forKey: @"fb:explicitly_shared"]; // <-- so that the post will be shared on the timeline
    FBSDKShareOpenGraphContent *content = [[FBSDKShareOpenGraphContent alloc] init];
    content.action = action;
    content.previewPropertyName = @"score";
    
    FBSDKShareAPI *shareAPI = [[FBSDKShareAPI alloc] init];
    
    // share it!
    shareAPI.shareContent = content;
    BOOL couldShare = [shareAPI share];
    NSString *errorString = [NSString stringWithFormat:@"%s ---- strHighscore=%@, strMessage=%@, couldShare=%d", __PRETTY_FUNCTION__, strHighscore, strMessage, couldShare];
    if (couldShare)
    {
        [ShareWrapper onShareResult:self withRet:kShareSuccess withMsg:@"share_score_success"];
    }
    else
    {
        [ShareWrapper onShareResult:self withRet:kShareFail withMsg:errorString];
    }
    
}

- (void) postImageToFB:(NSDictionary *)params
{
    NSString* strHighscore = [params objectForKey:@"Param1"];
    NSString* strMessage = [params objectForKey:@"Param2"];
    
    FBSDKAccessToken* token = [FBSDKAccessToken currentAccessToken];
    if (!token || ![[token permissions] containsObject:@"publish_actions"])
    {
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login logInWithPublishPermissions:@[@"publish_actions"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            NSString *errorString = [NSString stringWithFormat:@"%s ---- error=%@, approved=%@, declined=%@", __PRETTY_FUNCTION__, error, result.grantedPermissions, result.declinedPermissions];
            if (error) {
                // error
                [ShareWrapper onShareResult:self withRet:kShareFail withMsg:errorString];
            } else if (result.isCancelled) {
                // login was cancelled
                [ShareWrapper onShareResult:self withRet:kShareCancel withMsg:errorString];
            } else if (result.declinedPermissions.count > 0) {
                // some permissions were declined
                [ShareWrapper onShareResult:self withRet:kShareFail withMsg:errorString];
            } else {
                [self postImageToFbImpl:strHighscore withMsg:strMessage];
            }
        }];
    }
    else
    {
        [self postImageToFbImpl:strHighscore withMsg:strMessage];
    }
}

- (void) shareScore: (long) score
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [NSString stringWithFormat:@"%ld", score], @"score",
                                   nil];
    
    // Get the score, and only send the updated score if it's highter
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me/scores?fields=score" parameters:nil HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         OUTPUT_LOG( @"Result %@", result );
         NSString *errorString = [NSString stringWithFormat:@"%s ---- error=%@, result=%@", __FUNCTION__, error, result];
         if (result && !error)
         {
             int nCurrentScore = 0;
             if ([[result objectForKey:@"data"] count] > 0)
             {
                 nCurrentScore = [[[[result objectForKey:@"data"] objectAtIndex:0] objectForKey:@"score"] intValue];
             }
             
             OUTPUT_LOG( @"Current score is %d", nCurrentScore );
             
             if (score > nCurrentScore)
             {
                 OUTPUT_LOG( @"Posting new score of %ld", score );
                 
                 FBSDKGraphRequest *requestPost = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me/scores" parameters:params HTTPMethod:@"POST"];
                 [requestPost startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                     NSString *errorString2 = [NSString stringWithFormat:@"%s ---- error=%@, result=%@", __PRETTY_FUNCTION__, error, result];
                     if (error)
                     {
                         [ShareWrapper onShareResult:self withRet:kShareScoreSubmitFailed withMsg:errorString2];
                     }
                     else
                     {
                         [ShareWrapper onShareResult:self withRet:kShareScoreSubmitSuccess withMsg:errorString2];
                     }
                     OUTPUT_LOG( @"Score posted" );
                 }];
             }
             else
             {
                 OUTPUT_LOG( @"Existing score is higher - not posting new score" );
                 [ShareWrapper onShareResult:self withRet:kShareScoreSubmitSuccess withMsg:errorString];
             }
         }
         else
         {
             [ShareWrapper onShareResult:self withRet:kShareScoreSubmitFailed withMsg:errorString];
             OUTPUT_LOG( @"Error %@", error );
         }
     }];
}


- (void) getPlayerHighScoreFromServer
{
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:[NSString stringWithFormat:@"%s/scores?fields=score,user&limit=100", FACEBOOK_APP_ID] parameters:nil HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         OUTPUT_LOG( @"Result %@", result );
         NSString *errorString = [NSString stringWithFormat:@"%s ---- error=%@, result=%@", __PRETTY_FUNCTION__, error, result];
         if (result && !error)
         {
             if ([[result objectForKey:@"data"] count] <= 0)
             {
                 [ShareWrapper onShareResult:self withRet:kShareGetHighscoreFailed withMsg:errorString];
             }
             else
             {
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
                 
                 int count = (int)[[result objectForKey:@"data"] count];
                 
                 m_highScoresListSize = (count <= 100) ? count : 100;
                 m_highScoresList = (FBHighScoreList*) malloc(m_highScoresListSize * sizeof(FBHighScoreList));
                 memset(m_highScoresList, 0, m_highScoresListSize * sizeof(FBHighScoreList));
                 
                 for (int i = 0; i < count; i++)
                 {
                     long score = [[[[result objectForKey:@"data"] objectAtIndex:i] objectForKey:@"score"] intValue];
                     long long playerId = [[[[[result objectForKey:@"data"] objectAtIndex:i] objectForKey:@"user"] objectForKey:@"id"] longLongValue];
                     OUTPUT_LOG(@"%s --- current player ID = %lld", __FUNCTION__, playerId);
                     NSString* strPlayerId = [NSString stringWithFormat:@"%lld", playerId];
                     if (playerId == m_playerId)
                     {
                         OUTPUT_LOG( @"\n-------------------------\n m_playerID = %lld, playerId = %lld\n-------------------------", m_playerId, playerId );
                         m_playerScore = score;
                         NSString * name = [NSString stringWithFormat:@"ME"];
                         m_highScoresList[i].m_fullName = strdup([name UTF8String]);
                         OUTPUT_LOG( @"IF %d. %@ [%ld]----", i, name, score );
                     }
                     else
                     {
                         NSString * name = [[[[[result objectForKey:@"data"] objectAtIndex:i] objectForKey:@"user"] objectForKey:@"name"] uppercaseStringWithLocale:[NSLocale currentLocale]];
                         m_highScoresList[i].m_fullName = strdup([name UTF8String]);
                         OUTPUT_LOG( @"ELSE %d. %@ [%ld]----", i, name, score );
                     }
                     
                     m_highScoresList[i].m_rank = i+1;
                     m_highScoresList[i].m_score = score;
                     m_highScoresList[i].m_playerId = strdup([strPlayerId UTF8String]);
                 }
                 
                 [ShareWrapper onShareResult:self withRet:kShareGetHighscoreSuccess withMsg:errorString];
             }
         }
         else
         {
             NSString* strErrorCode = [NSString stringWithFormat:@"ErrorCode %@", error];
             [ShareWrapper onShareResult:self withRet:kShareFail withMsg:errorString];
         }
     }];
}


- (NSNumber*) getLeaderboardLength
{
    return [[NSNumber alloc] initWithInt:(int)m_highScoresListSize];
}


- (void*) getLeaderboard
{
    return m_highScoresList;
}

- (NSNumber*) getLocalPlayerScore
{
    return [[NSNumber alloc] initWithInt:(int)m_playerScore];
}

- (void) getPlayerProfilePictureFromServer: (NSNumber*) playerId
{
    int64_t playerIdValue = [playerId longLongValue];
    OUTPUT_LOG(@"%s --- getting picture for %lld", __FUNCTION__, playerIdValue);
    
#if USE_HTTPS_INSTEAD_OF_GRAPH_API
    // get profile pic via https
    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%lld/picture?type=square&return_ssl_resources=1", playerIdValue]];
    NSData *imageData = [NSData dataWithContentsOfURL:pictureURL];
    UIImage *img = [UIImage imageWithData:imageData];
    NSString *errorString = [NSString stringWithFormat:@"%s ---- img=%@", __FUNCTION__, img];
    if (img != nil)
    {
        [m_profilePics setObject:img forKey:@(playerIdValue)];
        [ShareWrapper onShareResult:self withRet:kShareGetPictureSuccess withMsg:errorString];
    }
    else
    {
        [ShareWrapper onShareResult:self withRet:kShareGetPictureFailed withMsg:errorString];
    }
    
#else
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"%lld/picture?redirect=false&fields=url", playerIdValue] completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSString *errorString = [NSString stringWithFormat:@"%s ---- error=%@, result=%@", __FUNCTION__, error, result];
        if (result && !error)
        {
            // nothing retrieved
            OUTPUT_LOG(@"%s --- result=%@", __FUNCTION__, result);
            if ([[result objectForKey:@"data"] count] <= 0)
            {
                [ShareWrapper onShareResult:self withRet:kShareGetPictureFailed withMsg:errorString];
            }
            else
            {
                // get image from retrieved url
                OUTPUT_LOG(@"%s --- URL=%@", __FUNCTION__, [[[[result objectForKey:@"data"] objectAtIndex:0] objectForKey:@"url"] stringValue]);
                NSString *strUrl = [[[result objectForKey:@"data"] objectForKey:@"url"] stringValue];
                NSURL *url = [NSURL URLWithString: strUrl];
                NSData *data = [NSData dataWithContentsOfURL:url];
                OUTPUT_LOG(@"\n\n\n-------\n\n\nDATA=%@\n\n\n-------\n\n\n", data);
                UIImage *img = [[UIImage alloc] initWithData:data];
                if (img != nil)
                {
                    [m_profilePics setObject:img forKey:@(playerIdValue)];
                }
                [ShareWrapper onShareResult:self withRet:kShareGetPictureSuccess withMsg:errorString];
            }
        }
        else
        {
           [ShareWrapper onShareResult:self withRet:kShareGetPictureFailed withMsg:errorString];
        }
    }];
#endif
}

- (void) getPlayerProfilePicture: (NSDictionary*) params
{
    OUTPUT_LOG(@"\n\n\n-------\n\n\nparams=%@\n\n\n-------\n\n\n", params);
    int64_t playerIdValue = [[params objectForKey:@"Param1"] longLongValue];
    NSString* strSavePath = [params objectForKey:@"Param2"];
    
#if USE_HTTPS_INSTEAD_OF_GRAPH_API
    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%lld/picture?type=square&return_ssl_resources=1", playerIdValue]];
    NSData *imageData = [NSData dataWithContentsOfURL:pictureURL];
    
    NSString *imgFile = [strSavePath stringByAppendingPathComponent:[NSString stringWithFormat:@"fbp_%lld", playerIdValue]];
    [imageData writeToFile:imgFile atomically:YES];
#else
    OUTPUT_LOG(@"%s --- m_profilePics=%@", __FUNCTION__, m_profilePics, playerIdValue, [m_profilePics objectForKey:@(playerIdValue)]);
    return (void*)[m_profilePics objectForKey:@(playerIdValue)];
#endif
}

- (NSString*)getPlayerFirstName
{
    return m_strFirstName;
}

- (NSString*)getPlayerLastName
{
    return m_strLastName;
}

- (NSNumber*)getPlayerId
{
    return [[NSNumber alloc] initWithLongLong:m_playerId];
}


@end
