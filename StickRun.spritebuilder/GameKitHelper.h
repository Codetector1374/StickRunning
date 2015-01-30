//
//  GameKitHelper.h
//  CoinCatcher
//
//  Created by Peter on 14/11/12.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//
#import <GameKit/GameKit.h>
#import <Foundation/Foundation.h>

@interface GameKitHelper : NSObject

@property (nonatomic) BOOL authed;

+(GameKitHelper*)sharedInstance;
-(void)authenticateLocalPlayer;
-(void)reportScore:(int64_t)score forLeaderboardID:(NSString*)boardID;
-(void)reportAchievement:(NSString*)AchievementID percentComplete:(float)percentage;
@end
