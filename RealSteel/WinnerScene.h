//
//  WinnerScene.h
//  RealSteel
//
//  Created by Tim Chen on 12/1/8.
//  Copyright (c) 2012年 NCCU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "FightScene.h"

@interface WinnerLayer : CCLayerColor {
    int _maxCombo;
    int _knockOut;
    int _timeBonus;
    
    int newExp;
    int expNeeded;
    
    CCLabelTTF * lvLbl;
    CCLabelTTF * expLbl;
    CCLabelTTF * cmbLbl;
    CCLabelTTF * KOLbl;
    CCLabelTTF * tmLbl;
    CCLabelTTF * ttLbl;
}

@property (nonatomic, assign) int maxCombo;
@property (nonatomic, assign) int knockOut;
@property (nonatomic, assign) int timeBonus;

- (void)menuBtnPressed:(id)sender;
- (void)detectLevelUp;

@end

@interface WinnerScene : CCScene {
    WinnerLayer *_layer;
}
@property (nonatomic, retain) WinnerLayer *layer;
@end
