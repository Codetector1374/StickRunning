#import "GameScene.h"
#import "GameKitHelper.h"
#import "Notification.h"
#import "GADBannerView.h"
#import "AppDelegate.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "AchivementHandler.h"

@class AppDelegate;
typedef enum _bannerType
{
    kBanner_Portrait_Top,
    kBanner_Portrait_Bottom,
    kBanner_Landscape_Top,
    kBanner_Landscape_Bottom,
}CocosBannerType;

#define BANNER_TYPE  kBanner_Portrait_Top


@interface GameScene(){
    BOOL isGrowingUp;
}
@property (nonatomic)int Score;
@end

@implementation GameScene{
    id<ALSoundSource> rolleffect;
    CCSprite*_player,*stick,*helperStick;
    CGSize winSize,PlayerSize;
    NSMutableArray* Stands;
    float playerYpos;
    BOOL ismoving,isTouched,isHelper,isTouchValid;
    int touches;
    CCLabelTTF* _scorel;
    id Dice;
    GADBannerView *mBannerView;
    CocosBannerType mBannerType;
    float on_x, on_y, off_x, off_y;
}

-(void)setScore:(int)Score{
    _Score = Score;
    [_scorel setString:[NSString stringWithFormat:@"%i",Score]];
    [[OALSimpleAudio sharedInstance]playEffect:@"score.wav"];
    [[AchivementHandler alloc]ReportAchievements:[self Score]];
}

-(void)onEnter{
    [super onEnter];
    
    [self createAdmobAds];
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    int Left = [[[NSUserDefaults standardUserDefaults]valueForKey:@"Helper"] intValue];
    NSLog(@"Left Helper%i",Left);
    if (Left>0){
        [[NSUserDefaults standardUserDefaults]setValue:[[NSNumber alloc]initWithInt:Left-1] forKey:@"Helper"];
        isHelper =true;
    }else{
        isHelper = false;
    }
    
    
    // Measurements
    winSize = [[CCDirector sharedDirector]viewSize];
    playerYpos =  winSize.height/4;
    
    //Settings
    [self setUserInteractionEnabled:true];
    //Init Player
    
    _player = [CCSprite spriteWithImageNamed:@"player.png"];
    _player.scaleX = 0.25;
    _player.scaleY = 0.5;
    [self addChild:_player z:2];
    _player.position = ccp(winSize.width/5, playerYpos);
    _player.anchorPoint = ccp(0, 0);
    
    CCSprite*Stand = [CCSprite spriteWithImageNamed:@"Stand.png"];
    Stand.anchorPoint = ccp(0, 1);
    Stand.position = _player.position;
    Stand.scaleX = (_player.boundingBox.size.width/Stand.boundingBox.size.width)*2;
    [self addChild:Stand z:10];
    Stands = [[NSMutableArray alloc]initWithObjects:Stand,nil];
    
    //Score Lable
    
    [self GenStand];
    
    [self MovePlayer];
    [[GameKitHelper sharedInstance] authenticateLocalPlayer];
    [[OALSimpleAudio sharedInstance]playBg:@"backgroundLoop.mp3" loop:true];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    [[OALSimpleAudio sharedInstance]setBgVolume:0.7];
    [[OALSimpleAudio sharedInstance]setEffectsVolume:1.0];
}


-(void)GenStand{
    CCSprite*Stand = [CCSprite spriteWithImageNamed:@"Stand.png"];

    
    int width = (arc4random()%25)+_player.boundingBox.size.width+10;
    Stand.scaleX = width/Stand.boundingBox.size.width;
    
    CCSprite*nowOn = [Stands objectAtIndex:Stands.count-1];
    int distant = arc4random()%150+(_player.boundingBox.size.width*2)+nowOn.boundingBox.size.width;

    Stand.anchorPoint = ccp(0, 1);
    CCSprite*last = [Stands lastObject];
    Stand.position = ccp(last.position.x+distant, playerYpos);
    [self addChild:Stand z:10];
    [Stands addObject:Stand];
}

-(void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event{
    touches++;
    isTouchValid = false;
    NSLog(@"Current Touch%i",touches);
    if (!isTouched && touches==1 && !ismoving) {
        isTouched = true;
        isTouchValid = true;
        [self GenAndGrow];
    }
}

-(void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event{
    NSLog(@"Current Touch @End %i",touches);

    if (touches>0) {
        touches--;
    }
    if (touches == 0 && !ismoving && isTouchValid) {
        isTouched = false;
//        if (!ismoving && [[self children]containsObject:stick]) {
            [self SwipeDownAndRun];
            if ([[self children]containsObject:helperStick]) {
                [self removeChild:helperStick];
            }
        }
    }

-(void)GenAndGrow{
    //Generating
    stick =[CCSprite spriteWithImageNamed:@"Stick.png"];
    stick.anchorPoint = ccp(1, 0);
    stick.position = ccp(_player.position.x+stick.boundingBox.size.width , _player.position.y);
    stick.scaleX = 0.5;
    stick.scaleY = 0.01;
    
    
    if(isHelper) {
        helperStick =[CCSprite spriteWithImageNamed:@"helper.png"];
        helperStick.anchorPoint = ccp(0, 0);
        helperStick.position = ccp(_player.position.x+_player.boundingBox.size.width, _player.position.y);
        helperStick.scaleY = .5;
        helperStick.scaleX = 0.01;
        helperStick.opacity = 0.5;
        [self addChild:helperStick];
    }
    
    [self addChild:stick]; 
    isGrowingUp = true;
    [self schedule:@selector(Grow) interval:0.03];
    
    rolleffect = [[OALSimpleAudio sharedInstance] playEffect:@"roll.wav" loop:true];
}

-(void)Grow{
    if (isGrowingUp) {
        stick.scaleY = stick.scaleY+0.01f;
        helperStick.scaleX = helperStick.scaleX+0.01f;
    }else{
        stick.scaleY = stick.scaleY-0.01f;
        helperStick.scaleX = helperStick.scaleX-0.01f;
    }
    if (stick.boundingBox.size.height+stick.position.x>= winSize.height) {
        isGrowingUp = false;
    }else if (stick.scaleY<=0.01f){
        isGrowingUp = true;
    }
}

-(void)SwipeDownAndRun{
    [rolleffect stop];
    [[OALSimpleAudio sharedInstance]playEffect:@"throw.caf" loop:false];
    [self unschedule:@selector(Grow)];
    ismoving = true;
    id rotate = [CCActionRotateBy actionWithDuration:0.4 angle:90];
    [stick runAction:rotate];
    [self MoveThePlayer];
}


-(void)MoveThePlayer{
    //Define Actions
    id MovePlayerUp = [CCActionMoveBy actionWithDuration:0.2 position:ccp(0, stick.boundingBox.size.width)];
    id MoveTowardsEndOfStick = [CCActionMoveBy actionWithDuration:1 position:ccp(stick.boundingBox.size.height, 0)];
    id moveBack = [MovePlayerUp reverse];
    id CheckPlayerPosition = [CCActionCallBlock actionWithBlock:^{
        //Check Collide
        BOOL contain = false;
        int Count = 0;
        for (CCNode*thisStand in Stands) {
            Count =(int)[Stands indexOfObject:thisStand];
            if ([thisStand isKindOfClass:[CCSprite class]]) {
                CCSprite*Stand = (CCSprite*)thisStand;
                if (CGRectContainsPoint(Stand.boundingBox, ccp(_player.position.x, _player.position.y-20))||CGRectContainsPoint(Stand.boundingBox, ccp(_player.position.x+_player.boundingBox.size.width, _player.position.y-20))) {
                    contain = true;
                    break;
                }
            }
        }
        if (!contain) {
            //Die
            CCSprite*CollideStand = (CCSprite*)[Stands objectAtIndex:Count];
            if (CollideStand.position.x>_player.position.x) {
                //Case Stick it too short.
                id FallDown = [CCActionMoveBy actionWithDuration:0.4 position:ccp(-winSize.width/3, -winSize.height)];
                id rotate = [CCActionRepeat actionWithAction:[CCActionRotateBy actionWithDuration:0.1 angle:40] times:30];
                [_player runAction:FallDown];
                [_player runAction:rotate];
                [stick runAction:[CCActionSequence actions:[CCActionRotateBy actionWithDuration:0.5 angle:90],[CCActionCallFunc actionWithTarget:self selector:@selector(showGameOver)], nil]];
            }else{
                id FallDown = [CCActionMoveBy actionWithDuration:1 position:ccp(-winSize.width/5, -winSize.height)];
                id rotate = [CCActionRepeat actionWithAction:[CCActionRotateBy actionWithDuration:0.4 angle:90]times:1];
                id KeepMove = [CCActionMoveBy actionWithDuration:0.1 position:ccp(_player.boundingBox.size.width+2, 0)];
                [_player runAction:[CCActionSequence actions:KeepMove,[CCActionCallBlock actionWithBlock:^{
                    [_player runAction:[CCActionSequence actions:FallDown, [CCActionCallFunc actionWithTarget:self selector:@selector(showGameOver)],nil]];
                    [_player runAction:rotate];
                }], nil]];
            }
        }else{
//            Survive
            id callblock = [CCActionCallBlock actionWithBlock:^(){
                if ([[self children] containsObject:stick]) {
                    [self removeChild:stick];
                }
            }];
            id Part2Check = [CCActionSequence actions:moveBack,callblock,[CCActionCallFunc actionWithTarget:self selector:@selector(StartNewRole)],[CCActionCallBlock actionWithBlock:^{
                [self setScore:[self Score]+1];
            }] ,nil];
            [_player runAction:Part2Check];
        }
    }];
    id BeginCheck = [CCActionSequence actions:MovePlayerUp,MoveTowardsEndOfStick,CheckPlayerPosition, nil];
    [_player runAction:BeginCheck];
}

-(void)StartNewRole{
    float DeltaPlayer = _player.position.x - winSize.width/5;
    id MoveScene = [CCActionMoveBy actionWithDuration:0.4 position:ccp(-DeltaPlayer, 0)];
    id Reenable = [CCActionCallBlock actionWithBlock:^{
        ismoving = false;
    }];
    BOOL WaitForRm = false;
    [self GenStand];
    for(CCSprite* thisSP in Stands){
        [thisSP runAction:[CCActionMoveBy actionWithDuration:0.4 position:ccp(-DeltaPlayer, 0)]];
        if (thisSP.position.x<-50) {
            WaitForRm = true;
        }
    }
    [_player runAction:[CCActionSequence actions:MoveScene,Reenable, nil]];
    if (WaitForRm) {
        [self removeChild:[Stands objectAtIndex:0]];
        [Stands removeObjectAtIndex:0];
    }
    [self MovePlayer];

}

-(void)showGameOver{
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    
    // Set the custom metric to be incremented by 5 using its index.
    NSString *metricValue = [[[NSNumber alloc]initWithInt:[self Score]] stringValue];
    [tracker set:[GAIFields customMetricForIndex:1]
           value:metricValue];
    
    
    [tracker set:kGAIScreenName
           value:@"Game Screen"];
    
    // Custom metric value is sent with this screen view.
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    [[NSUserDefaults standardUserDefaults] setValue:[[NSNumber alloc]initWithInt:[self Score]] forKey:@"LastScore"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PopUp" object:nil];
    
    [[CCDirector sharedDirector]pushScene:[CCBReader loadAsScene:@"GameOver"] withTransition:[CCTransition transitionFadeWithDuration:0.5]];
    [[OALSimpleAudio sharedInstance]stopBg];
    
    [[AchivementHandler alloc]ReportAchievements:[self Score]];
}

-(void)MovePlayer{
    CCSprite*last = [Stands objectAtIndex:Stands.count-2];
    float pos1 = last.position.x+last.boundingBox.size.width-_player.boundingBox.size.width;
    id a = [CCActionMoveBy actionWithDuration:0.5 position:ccp(pos1 - _player.position.x, 0)];

    [_player runAction:[CCActionSequence actions:a, nil]];
}

-(void)onExit{
    [super onExit];
    [Notification Schedule];
}

-(void)createAdmobAds
{
    mBannerType = BANNER_TYPE;
    
    AppController *app = (AppController*)[UIApplication sharedApplication].delegate;    // Create a view of the standard size at the bottom of the screen.
    // Available AdSize constants are explained in GADAdSize.h.
    
    if(mBannerType <= kBanner_Portrait_Bottom)
        mBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
    else
        mBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerLandscape];
    
    // Specify the ad's "unit identifier." This is your AdMob Publisher ID.
    mBannerView.adUnitID = @"ca-app-pub-1939176793799928/6023959296";
    
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    
    mBannerView.rootViewController = app.navController;
    [app.navController.view addSubview:mBannerView];
    
    // Initiate a generic request to load it with an ad.
    GADRequest*request = [GADRequest request];
    request.testDevices = @[@"5a76924f371751322854bae261467f75",@"e9fc2ee54d38dd8c78deffff064eb3ba"];
    [mBannerView loadRequest:request];
    
    CGSize s = [[CCDirector sharedDirector] viewSize];
    
    CGRect frame = mBannerView.frame;
    
    off_x = 0.0f;
    on_x = 0.0f;
    
    switch (mBannerType)
    {
        case kBanner_Portrait_Top:
        {
            off_y = -frame.size.height;
            on_y = 0.0f;
        }
            break;
        case kBanner_Portrait_Bottom:
        {
            off_y = s.height;
            on_y = s.height-frame.size.height;
        }
            break;
        case kBanner_Landscape_Top:
        {
            off_y = -frame.size.height;
            on_y = 0.0f;
        }
            break;
        case kBanner_Landscape_Bottom:
        {
            off_y = s.height;
            on_y = s.height-frame.size.height;
        }
            break;
            
        default:
            break;
    }
    
    frame.origin.y = off_y;
    frame.origin.x = off_x;
    
    mBannerView.frame = frame;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    frame = mBannerView.frame;
    frame.origin.x = on_x;
    frame.origin.y = on_y;
    
    
    mBannerView.frame = frame;
    [UIView commitAnimations];
}


-(void)showBannerView
{
    if (mBannerView)
    {
        [UIView animateWithDuration:0.5
                              delay:0.1
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^
         {
             CGRect frame = mBannerView.frame;
             frame.origin.y = on_y;
             frame.origin.x = on_x;
             
             mBannerView.frame = frame;
         }
                         completion:nil];
    }
    
}


-(void)hideBannerView
{
    if (mBannerView)
    {
        [UIView animateWithDuration:0.5
                              delay:0.1
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^
         {
             CGRect frame = mBannerView.frame;
             frame.origin.y = off_y;
             frame.origin.x = off_x;
         }
                         completion:^(BOOL finished)
         {
         }];
    }
    
}

-(void)dismissAdView
{
    if (mBannerView)
    {
        [UIView animateWithDuration:0.5
                              delay:0.1
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^
         {
             CGRect frame = mBannerView.frame;
             frame.origin.y = off_y;
             frame.origin.x = off_x;
             mBannerView.frame = frame;
         }
                         completion:^(BOOL finished)
         {
             [mBannerView setDelegate:nil];
             [mBannerView removeFromSuperview];
             mBannerView = nil;
             
         }];
    }
}


@end
