//
//  GameOverScene.h
//  Cocos2DSimpleGame
//
//  Created by Tim Chen on 11/12/12.
//  Copyright (c) 2011年 NCCU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "FightScene.h"

@interface GameOverLayer : CCLayerColor {
}
- (void)menuBtnPressed:(id)sender;

@end

@interface GameOverScene : CCScene {
    GameOverLayer *_layer;
}
@property (nonatomic, retain) GameOverLayer *layer;
@end
