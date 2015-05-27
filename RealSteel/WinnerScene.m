//
//  GameOverScene.m
//  Cocos2DSimpleGame
//
//  Created by Tim Chen on 11/12/12.
//  Copyright (c) 2011年 NCCU. All rights reserved.
//

#import "WinnerScene.h"

@implementation WinnerScene
@synthesize layer = _layer;

- (id)init {
    
    if ((self = [super init])) {
        self.layer = [WinnerLayer node];
        [self addChild:_layer];
    }
    return self;
}

- (void)dealloc {
    [_layer release];
    _layer = nil;
    [super dealloc];
}

@end

@implementation WinnerLayer

@synthesize maxCombo = _maxCombo;
@synthesize knockOut = _knockOut;
@synthesize timeBonus = _timeBonus;

-(id) init
{
    if( (self=[super initWithColor:ccc4(0,0,0,0)] )) {
        // get window size first
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        // set up background
        CCSprite * background = [CCSprite spriteWithFile:@"background_winner.png"];
        background.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:background];
        
        [self setIsTouchEnabled:YES];
        
    }
    return self;
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self setIsTouchEnabled:NO];
    // set up animation
    
    int lv = [[NSUserDefaults standardUserDefaults] integerForKey:@"profile_level"];
    lvLbl = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"lv %d", lv] fontName:@"Alexis Grunge" fontSize:24];
    lvLbl.position = ccp(25 + lvLbl.contentSize.width/2, 240);
    [lvLbl setColor:ccc3(0, 0, 0)];
    [self addChild:lvLbl];
    
    int exp = [[NSUserDefaults standardUserDefaults] integerForKey:@"profile_exp"];
    newExp = exp + 1;
    expNeeded = [[NSUserDefaults standardUserDefaults] integerForKey:@"profile_expNeeded"];
    expLbl = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"exp %d/%d", newExp, expNeeded] fontName:@"Alexis Grunge" fontSize:24];
    expLbl.position = ccp(25 + expLbl.contentSize.width/2, 220);
    [expLbl setColor:ccc3(0, 0, 0)];
    [self addChild:expLbl];
    [[NSUserDefaults standardUserDefaults] setInteger:newExp forKey:@"profile_exp"];
    
    cmbLbl = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"combo: +%d", _maxCombo] fontName:@"Alexis Grunge" fontSize:24];
    cmbLbl.position = ccp(190 + cmbLbl.contentSize.width/2, 240);
    [cmbLbl setColor:ccc3(0, 0, 0)];
    [self addChild:cmbLbl];
    
    KOLbl = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"knock out: +%d", _knockOut] fontName:@"Alexis Grunge" fontSize:24];
    KOLbl.position = ccp(190 + KOLbl.contentSize.width/2, 220);
    [KOLbl setColor:ccc3(0, 0, 0)];
    [self addChild:KOLbl];
    
    _timeBonus = _timeBonus/3;
    tmLbl = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"time bonus: +%d", _timeBonus] fontName:@"Alexis Grunge" fontSize:24];
    tmLbl.position = ccp(190 + tmLbl.contentSize.width/2, 200);
    [tmLbl setColor:ccc3(0, 0, 0)];
    [self addChild:tmLbl];
    
    int total = _maxCombo + _knockOut + _timeBonus;
    ttLbl = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"= +%d", total] fontName:@"Alexis Grunge" fontSize:36];
    ttLbl.position = ccp(460 - ttLbl.contentSize.width/2, 220);
    [ttLbl setColor:ccc3(0, 0, 0)];
    [self addChild:ttLbl];
    int points = [[NSUserDefaults standardUserDefaults] integerForKey:@"profile_points"];
    points = points + total;
    [[NSUserDefaults standardUserDefaults] setInteger:points forKey:@"profile_points"];
    
    [self performSelector:@selector(detectLevelUp) withObject:nil afterDelay:3];
}

- (void)detectLevelUp
{
    if (newExp == expNeeded) {
        int lv = [[NSUserDefaults standardUserDefaults] integerForKey:@"profile_level"];
        int newLv = lv + 1;
        [[NSUserDefaults standardUserDefaults] setInteger:newLv forKey:@"profile_level"];
        newExp = 0;
        [[NSUserDefaults standardUserDefaults] setInteger:newExp forKey:@"profile_exp"];
        
        [lvLbl setString:[NSString stringWithFormat:@"lv %d", newLv]];
        [expLbl setString:[NSString stringWithFormat:@"exp %d/%d", newExp, expNeeded]];
        
        CCLabelTTF * lvupLbl = [CCLabelTTF labelWithString:@"level up!" fontName:@"Alexis Grunge" fontSize:24];
        lvupLbl.position = ccp(25 + lvLbl.contentSize.width/2 + lvupLbl.contentSize.width/2, 200);
        [lvupLbl setColor:ccc3(0, 0, 0 )];
        [self addChild:lvupLbl];
        [lvupLbl setScale:3];
        [lvupLbl runAction:[CCSpawn actionOne:[CCScaleTo actionWithDuration:1 scale:1] 
                                          two:[CCFadeIn actionWithDuration:1]
                            ]];
    }
    
    // back to menu button
    CCMenuItemImage * menuBtn = [CCMenuItemImage itemFromNormalImage:@"gameOver_menu.png" selectedImage:@"gameOver_menu_selected.png" target:self selector:@selector(menuBtnPressed:)];
    CCMenu * menu = [CCMenu menuWithItems:menuBtn, nil];
    menu.position = ccp(420, 30);
    [menu alignItemsVertically];
    [self addChild:menu];
}

- (void)menuBtnPressed:(id)sender
{
    // 斷開連線
    //    GKSession * session = [[GameSession sharedGameSession] gameSession];
    //    [session disconnectFromAllPeers];
    //    session.available = NO;
    //    [session setDataReceiveHandler: nil withContext: nil];
    //    session.delegate = nil;
    //    [session release];
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    [[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene]];
}

- (void)dealloc {
    [super dealloc];
}

@end

