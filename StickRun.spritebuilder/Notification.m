//
//  Notification.m
//  StickRun
//
//  Created by Peter on 14/11/17.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "Notification.h"

@implementation Notification



+(void)Schedule{    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:3600];
    notification.alertBody = @"StickMan is ready and waiting for you!";
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.applicationIconBadgeNumber = 1;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];

}

@end
