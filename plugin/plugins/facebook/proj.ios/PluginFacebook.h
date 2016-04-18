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

#import "InterfaceShare.h"

#define USE_NEW_FACEBOOK_SDK

typedef struct {
    long        m_rank;
    int64_t     m_score;
    char*       m_fullName;
    char*       m_playerId;
} FBHighScoreList;

@interface PluginFacebook : NSObject <InterfaceShare>
{
    FBHighScoreList*        m_highScoresList;
    int64_t                 m_highScoresListSize;
    NSMutableDictionary*    m_profilePics;
    
    int64_t                 m_playerId;
    int64_t                 m_playerScore;
    
    NSString*               m_strFirstName;
    NSString*               m_strLastName;
}

@property BOOL debug;
@property (copy, nonatomic) NSMutableDictionary* mShareInfo;

/**
 * @brief interfaces of protocol : InterfaceShare
 */
- (void) configDeveloperInfo : (NSMutableDictionary*) cpInfo;
- (void) share: (NSMutableDictionary*) shareInfo;
- (void) shareScore:(long)score;
- (void) setDebugMode: (BOOL) debug;
- (NSString*) getSDKVersion;
- (NSString*) getPluginVersion;

- (void) getPlayerHighScoreFromServer;
- (NSNumber*) getLeaderboardLength;
- (void*) getLeaderboard;
- (NSNumber*) getLocalPlayerScore;
- (void) getPlayerProfilePicture: (NSDictionary*) params;
- (void) postImageToFB:(NSDictionary*) params;
- (void) postImageToFbImpl: (NSString*) strHighscore withMsg: (NSString*) strMessage;
- (NSString*) getPlayerFirstName;
- (NSString*) getPlayerLastName;
- (NSNumber*) getPlayerId;

/**
 * @brief facebook calls
 */
- (void) login;
- (BOOL) isLoggenIn;
- (void) logout;

@end
