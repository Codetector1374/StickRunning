//
//  GameKitHelper.m
//  CoinCatcher
//
//  Created by Peter on 14/11/12.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "GameKitHelper.h"

@implementation GameKitHelper

+(GameKitHelper*)sharedInstance{
    static GameKitHelper*_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate,^{
        _sharedInstance = [[GameKitHelper alloc]init];
    });
    return _sharedInstance;
}

-(void)authenticateLocalPlayer{
    __weak GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
    __block BOOL authed= false;
    localPlayer.authenticateHandler = ^(UIViewController* viewController, NSError* error){
        if (localPlayer.isAuthenticated) {
            authed = true;
            [[NSNotificationCenter defaultCenter]postNotificationName:@"AuthedGC" object:nil];
        }
    };
    [self setAuthed:authed];
}

-(void)reportScore:(int64_t)score forLeaderboardID:(NSString*)boardID{
        GKScore* scoreRPTR = [[GKScore alloc]initWithLeaderboardIdentifier:boardID];
        scoreRPTR.value = score;
        scoreRPTR.context = 0;
        
        NSArray*scores = @[scoreRPTR];
        [GKScore reportScores:scores withCompletionHandler:^(NSError *error){
            NSLog(@"Success");
        }];
}

-(void)reportAchievement:(NSString*)AchievementID percentComplete:(float) percentage{
    GKAchievement*achieve = [[GKAchievement alloc]initWithIdentifier:AchievementID];
    if (achieve) {
        achieve.percentComplete = percentage;
        [achieve reportAchievementWithCompletionHandler:^(NSError *error){
            if (error != nil)
            {
                NSLog(@"Error in reporting achievements: %@", error);
            }
        }];
    }
}

@end
