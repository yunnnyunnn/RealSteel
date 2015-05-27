//
//  AbilityScene.m
//  RealSteel
//
//  Created by Tim Chen on 12/1/8.
//  Copyright (c) 2012年 NCCU. All rights reserved.
//

#import "AbilityScene.h"

@implementation AbilityScene
@synthesize layer = _layer;

- (id)init {
    
    if ((self = [super init])) {
        self.layer = [AbilityLayer node];
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

@implementation AbilityLayer

-(id) init
{
    if( (self=[super initWithColor:ccc4(0,0,0,0)] )) {
        // get window size first
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        // set up background
        CCSprite * background = [CCSprite spriteWithFile:@"ability.png"];
        background.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:background];
        
        // set up all label
        int lv = [[NSUserDefaults standardUserDefaults] integerForKey:@"profile_level"];
        lvLbl = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"lv %d", lv] fontName:@"Alexis Grunge" fontSize:30];
        [lvLbl setColor:ccc3(0, 0, 0)];
        
        int exp = [[NSUserDefaults standardUserDefaults] integerForKey:@"profile_exp"];
        int expNeeded = [[NSUserDefaults standardUserDefaults] integerForKey:@"profile_expNeeded"];
        expLbl = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"exp %d/%d", exp, expNeeded] fontName:@"Alexis Grunge" fontSize:30];
        [expLbl setColor:ccc3(0, 0, 0)];
        
        pt = [[NSUserDefaults standardUserDefaults] integerForKey:@"profile_points"];
        avlbLbl = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"available: %d", pt] fontName:@"Alexis Grunge" fontSize:30];
        [avlbLbl setColor:ccc3(0, 0, 0)];
        
        int hp = [[NSUserDefaults standardUserDefaults] integerForKey:@"profile_hp"];
        hpLbl = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"hp %d     cost:1", hp] fontName:@"Alexis Grunge" fontSize:30];
        [hpLbl setColor:ccc3(0, 0, 0)];
        
        int pwr = [[NSUserDefaults standardUserDefaults] integerForKey:@"profile_power"];
        powerLbl = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"power %d  cost:5", pwr] fontName:@"Alexis Grunge" fontSize:30];
        [powerLbl setColor:ccc3(0, 0, 0)];
        
        int spd = [[NSUserDefaults standardUserDefaults] integerForKey:@"profile_speed"];
        spdLbl = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"speed %d  cost:15", spd] fontName:@"Alexis Grunge" fontSize:30];
        [spdLbl setColor:ccc3(0, 0, 0)];
        
        lvLbl.position = ccp(winSize.width/2, 230);
        expLbl.position = ccp(winSize.width/2, 200);
        avlbLbl.position = ccp(350, 155);
        hpLbl.position = ccp(50 + hpLbl.contentSize.width/2, 125);
        powerLbl.position = ccp(50 + powerLbl.contentSize.width/2, 95);
        spdLbl.position = ccp(50 + spdLbl.contentSize.width/2, 65);
        
        [self addChild:lvLbl];
        [self addChild:expLbl];
        [self addChild:avlbLbl];
        [self addChild:hpLbl];
        [self addChild:powerLbl];
        [self addChild:spdLbl];
        
        // back to menu button
        CCMenuItemImage * menuBtn = [CCMenuItemImage itemFromNormalImage:@"gameOver_menu.png" selectedImage:@"gameOver_menu_selected.png" target:self selector:@selector(menuBtnPressed:)];
        CCMenu * menu = [CCMenu menuWithItems:menuBtn, nil];
        menu.position = ccp(winSize.width/2, 30);
        [menu alignItemsVertically];
        [self addChild:menu];
        
        CCMenuItemImage * addBtn1 = [CCMenuItemImage itemFromNormalImage:@"addBtn.png" selectedImage:@"addBtn_selected.png" target:self selector:@selector(addHpBtnPressed:)];
        CCMenuItemImage * addBtn2 = [CCMenuItemImage itemFromNormalImage:@"addBtn.png" selectedImage:@"addBtn_selected.png" target:self selector:@selector(addPowerBtnPressed:)];
        CCMenuItemImage * addBtn3 = [CCMenuItemImage itemFromNormalImage:@"addBtn.png" selectedImage:@"addBtn_selected.png" target:self selector:@selector(addSpeedBtnPressed:)];
        CCMenu * menuAdd = [CCMenu menuWithItems:addBtn1, addBtn2, addBtn3, nil];
        menuAdd.position = ccp(380, 95);
        [menuAdd alignItemsVerticallyWithPadding:4];
        [self addChild:menuAdd];
    }
    return self;
}

- (void)addHpBtnPressed:(id)sender
{
    if (pt > 0) {
        int hp = [[NSUserDefaults standardUserDefaults] integerForKey:@"profile_hp"];
        int newHp = hp + 1;
        [[NSUserDefaults standardUserDefaults] setInteger:newHp forKey:@"profile_hp"];
        pt--;
        
        [hpLbl setString:[NSString stringWithFormat:@"hp %d     cost:1", newHp]];
        [avlbLbl setString:[NSString stringWithFormat:@"available: %d", pt]];
    }
    
}

- (void)addPowerBtnPressed:(id)sender
{
    if (pt > 4) {
        int power = [[NSUserDefaults standardUserDefaults] integerForKey:@"profile_power"];
        int newPower = power + 1;
        [[NSUserDefaults standardUserDefaults] setInteger:newPower forKey:@"profile_power"];
        pt = pt - 5;
        
        [powerLbl setString:[NSString stringWithFormat:@"power %d  cost:5", newPower]];
        [avlbLbl setString:[NSString stringWithFormat:@"available: %d", pt]];
    }
}

- (void)addSpeedBtnPressed:(id)sender
{
    if (pt > 14) {
        int spd = [[NSUserDefaults standardUserDefaults] integerForKey:@"profile_speed"];
        int newSpd = spd + 1;
        [[NSUserDefaults standardUserDefaults] setInteger:newSpd forKey:@"profile_speed"];
        pt = pt - 15;
        
        [spdLbl setString:[NSString stringWithFormat:@"speed %d  cost:15", newSpd]];
        [avlbLbl setString:[NSString stringWithFormat:@"available: %d", pt]];
    }
}

- (void)menuBtnPressed:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setInteger:pt forKey:@"profile_points"];
    [[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene]];
}

- (void)dealloc {
    [super dealloc];
}

@end
