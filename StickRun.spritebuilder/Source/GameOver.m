//
//  GameOver.m
//  StickRun
//
//  Created by Peter on 14/11/16.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "GameOver.h"
#import "GameKitHelper.h"
#import "AppDelegate.h"
#import "Notification.h"

@implementation GameOver{
    CCLabelTTF* _scorel,*_helperLeft;
    CCButton* _Buy10;
}

-(void)onEnter{
    [super onEnter];
    int score =[[[NSUserDefaults standardUserDefaults] valueForKey:@"LastScore"] intValue];
    
    
    [_scorel setString:[NSString stringWithFormat:@"%i",score]];
    [[GameKitHelper sharedInstance] reportScore:score forLeaderboardID:@"cn.codetector.stickrun.highscore"];
    [Notification Schedule];
    int left = [[[NSUserDefaults standardUserDefaults]valueForKey:@"Helper"] intValue];
    _Buy10.visible = false;
    if(left>0){_Buy10.enabled = false; _Buy10.label.opacity = 0.3;}
    [_helperLeft setString:[NSString stringWithFormat:@"%i",left]];
    
    PageAd = [[GADInterstitial alloc]init];
    PageAd.adUnitID = @"ca-app-pub-1939176793799928/7500692494";
    GADRequest*request = [GADRequest request];
    request.testDevices = @[@"5a76924f371751322854bae261467f75",@"e9fc2ee54d38dd8c78deffff064eb3ba"];
    [PageAd loadRequest:request];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"PopUp" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(ad) name:@"PopUp" object:nil];

}


-(void)NewGame{
    [[CCDirector sharedDirector]pushScene:[CCBReader loadAsScene:@"GameScene"] withTransition:[CCTransition transitionMoveInWithDirection:CCTransitionDirectionLeft duration:0.3]];
}

-(void)ad{
    [PageAd presentFromRootViewController:[[CCDirector sharedDirector] parentViewController]];
}

-(void)GameCenter{
    GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
    leaderboardViewController.leaderboardDelegate = self;
    
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    
    [[app navController] presentViewController:leaderboardViewController animated:YES completion:^{}];
    
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    [[app navController] dismissViewControllerAnimated:YES completion:nil];
}


@end
