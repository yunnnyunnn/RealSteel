//
//  HelloWorldLayer.m
//  RealSteel
//
//  Created by Tim Chen on 11/12/19.
//  Copyright NCCU 2011年. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// HelloWorldLayer implementation
@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super initWithColor:ccc4(255, 255, 255, 255)])) {
        
        
        NSString * robotName = [[NSUserDefaults standardUserDefaults] valueForKey:@"profile_robotName"];
        
        if (!robotName) {
            
            UIAlertView *userInformationAlert = [[UIAlertView alloc] initWithTitle:@"Real Steel" message:@"Name your robot!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Start", nil];
            userInformationAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
            [userInformationAlert show];
            [userInformationAlert release];
        }
        else
            [self setUpMenuItem];
        
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        CCSprite * background = [CCSprite spriteWithFile:@"Menu_background.png"];
        background.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:background z:0];
        
        CCSprite * logo = [CCSprite spriteWithFile:@"Menu_Logo.png"];
        logo.position = ccp((logo.contentSize.width/2 + 30), (winSize.height - logo.contentSize.height/2) - 20);
        [self addChild:logo z:1];
        
        CCMenuItemImage * fight = [CCMenuItemImage itemFromNormalImage:@"Menu_fight.png" selectedImage:@"Menu_fight_selected.png" target:self selector:@selector(fightButtonPressed:)];
        CCMenuItemImage * practice = [CCMenuItemImage itemFromNormalImage:@"Menu_practice.png" selectedImage:@"Menu_practice_selected.png" target:self selector:@selector(practiceBtnPressed:)];
        CCMenuItemImage * ability = [CCMenuItemImage itemFromNormalImage:@"Menu_ability.png" selectedImage:@"Menu_ability_selected.png" target:self selector:@selector(abilityBtnPressed:)];
        
        CCMenu * menu = [CCMenu menuWithItems:fight, practice, ability, nil];
        
        [menu alignItemsVertically];
        
        menu.position = ccp(130, 120);
        [self addChild:menu z:2];
        
        [self setIsTouchEnabled:YES];
        
        if (![[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying]) {
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"preview.mp3"];
        }
        
        
	}
	return self;
}



- (void)setUpMenuItem
{
    
//    NSString * robotName = [[NSUserDefaults standardUserDefaults] stringForKey:@"profile_robotName"];
//    CCLabelTTF * nameLabel = [CCLabelTTF labelWithString:robotName fontName:@"Alexis Grunge" fontSize:30];
//    nameLabel.position = ccp(25 + nameLabel.contentSize.width/2, 210);
//    [self addChild:nameLabel z:2];
//    
//    NSString * lv = [NSString stringWithFormat:@"Lv %d", [[NSUserDefaults standardUserDefaults] integerForKey:@"profile_level"]];
//    CCLabelTTF * lvLabel = [CCLabelTTF labelWithString:lv fontName:@"" fontSize:30];
//    lvLabel.position = ccp(25 + lvLabel.contentSize.width/2, 180);
//    [self addChild:lvLabel z:2];
//    
//    NSString * exp = [NSString stringWithFormat:@"exp. %d / %d", [[NSUserDefaults standardUserDefaults] integerForKey:@"profile_exp"], [[NSUserDefaults standardUserDefaults] integerForKey:@"profile_expNeeded"]];
//    CCLabelTTF * expLabel = [CCLabelTTF labelWithString:exp fontName:@"Alexis Grunge" fontSize:30];
//    expLabel.position = ccp(25 + expLabel.contentSize.width/2, 150);
//    [self addChild:expLabel z:2];
//    
//    NSString * hp = [NSString stringWithFormat:@"hp %d", [[NSUserDefaults standardUserDefaults] integerForKey:@"profile_hp"]];
//    CCLabelTTF * hpLabel = [CCLabelTTF labelWithString:hp fontName:@"Alexis Grunge" fontSize:30];
//    hpLabel.position = ccp(25 + hpLabel.contentSize.width/2, 120);
//    [self addChild:hpLabel z:2];
//    
//    NSString * power = [NSString stringWithFormat:@"power %d", [[NSUserDefaults standardUserDefaults] integerForKey:@"profile_power"]];
//    CCLabelTTF * powerLabel = [CCLabelTTF labelWithString:power fontName:@"Alexis Grunge" fontSize:30];
//    powerLabel.position = ccp(25 + powerLabel.contentSize.width/2, 90);
//    [self addChild:powerLabel z:2];
    
}

- (void)practiceBtnPressed:(id)sender
{
    PracticeScene * practiceScene = [PracticeScene node];
    //[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    [[CCDirector sharedDirector] replaceScene:practiceScene];
}

- (void)abilityBtnPressed:(id)sender
{
    AbilityScene * abilityScene = [AbilityScene node];
    [[CCDirector sharedDirector] replaceScene:abilityScene];
}

- (void)fightButtonPressed:(id)sender
{
    // initialize peer picker
    _PeerPicker = [[GKPeerPickerController alloc] init];
    _PeerPicker.delegate = self;
    _PeerPicker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
    [_PeerPicker show];
}

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session
{
    
    // assign session to Gamesession instance
    [[GameSession sharedGameSession] setGameSession:session];
    session.delegate = [GameSession sharedGameSession];
    [session setDataReceiveHandler:[GameSession sharedGameSession] withContext:nil];
    
    picker.delegate = nil;
    [picker dismiss];
    [picker autorelease];
    
    // replace scene when connection established
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    [[CCDirector sharedDirector] replaceScene:[FightScene node]];
}

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker
{
    picker.delegate = nil;
    [picker autorelease];
}


// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
    
    
	// don't forget to call "super dealloc"
	[super dealloc];
}

#pragma UIAlertView delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // initialize new profile
    NSString * robotName = [alertView textFieldAtIndex:0].text;
    [[NSUserDefaults standardUserDefaults] setValue:robotName forKey:@"profile_robotName"];
    
    int level = 1;
    [[NSUserDefaults standardUserDefaults] setInteger:level forKey:@"profile_level"];
    
    int exp = 0;
    [[NSUserDefaults standardUserDefaults] setInteger:exp forKey:@"profile_exp"];
    
    int expNeeded = 5;
    [[NSUserDefaults standardUserDefaults] setInteger:expNeeded forKey:@"profile_expNeeded"];
    
    int hp = 50;
    [[NSUserDefaults standardUserDefaults] setInteger:hp forKey:@"profile_hp"];
    
    int power = 5;
    [[NSUserDefaults standardUserDefaults] setInteger:power forKey:@"profile_power"];
    
    int wins = 0;
    [[NSUserDefaults standardUserDefaults] setInteger:wins forKey:@"profile_wins"];
    
    int loses = 0;
    [[NSUserDefaults standardUserDefaults] setInteger:loses forKey:@"profile_loses"];
    
    int points = 0;
    [[NSUserDefaults standardUserDefaults] setInteger:points forKey:@"profile_points"];
    
    int spd = 1;
    [[NSUserDefaults standardUserDefaults] setInteger:spd forKey:@"profile_speed"];
    
    [self setUpMenuItem];
}

@end
