//
//  AchivementHandler.m
//  StickRun
//
//  Created by Peter on 11/27/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "AchivementHandler.h"

@implementation AchivementHandler{
    GameKitHelper*kit;
}

-(void)ReportAchievements:(int)Score{
    kit = [GameKitHelper sharedInstance];
    NSArray*ID = @[@"cn.codetector.stickrun.Beginner",@"cn.codetector.stickrun.getitdone",@"cn.codetector.stickrun.Ontheway"];
    NSArray*fullMarks = @[@10,@25,@50];
    for (int u = 0; u<[ID count];u++) {
        NSLog(@"Percentage %f",[self percent:Score fullScore:[[fullMarks objectAtIndex:u] intValue]]);
        [self report:[self percent:Score fullScore:[[fullMarks objectAtIndex:u] intValue]] id:[ID objectAtIndex:u]];
    }
}

-(void)report:(float)percent id:(NSString*)achieve{
    [kit reportAchievement:achieve percentComplete:percent];
}

-(float)percent:(int)score fullScore:(int)full{
    NSLog(@"%f",(float)score/(float)full);
    if ((float)score/(float)full<=1) {
        return (float)score/(float)full*100;
    }else{
        return 100;
    }
}

@end
