//
//  HelloWorldLayer.h
//  RealSteel
//
//  Created by Tim Chen on 11/12/19.
//  Copyright NCCU 2011年. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import <GameKit/GameKit.h>
#import "cocos2d.h"
#import "FightScene.h"
#import "GameSession.h"
#import "SimpleAudioEngine.h"
#import "AbilityScene.h"
#import "PracticeScene.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayerColor <GKPeerPickerControllerDelegate, UIAlertViewDelegate>
{
    CCLabelTTF * _connectLabel;
    GKPeerPickerController *_PeerPicker;
    
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+ (CCScene *) scene;
- (void)abilityBtnPressed:(id)sender;
- (void)practiceBtnPressed:(id)sender;
- (void)fightButtonPressed:(id)sender;
- (void)setUpMenuItem;

@end
