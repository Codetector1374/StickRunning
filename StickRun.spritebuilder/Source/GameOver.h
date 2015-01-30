//
//  GameOver.h
//  StickRun
//
//  Created by Peter on 14/11/16.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//
#import <GameKit/GameKit.h>
#import "CCNode.h"
#import "GADInterstitial.h"
#import "GADInterstitialDelegate.h"

@interface GameOver : CCNode <GKLeaderboardViewControllerDelegate>{
    GADInterstitial* PageAd;
}


@end
