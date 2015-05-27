//
//  AbilityScene.h
//  RealSteel
//
//  Created by Tim Chen on 12/1/8.
//  Copyright (c) 2012年 NCCU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "HelloWorldLayer.h"

@interface AbilityLayer : CCLayerColor {
    CCLabelTTF * lvLbl;
    CCLabelTTF * expLbl;
    
    CCLabelTTF * avlbLbl;
    int pt;
    
    CCLabelTTF * hpLbl;
    CCLabelTTF * powerLbl;
    CCLabelTTF * spdLbl;
    
}

- (void)menuBtnPressed:(id)sender;
- (void)addHpBtnPressed:(id)sender;
- (void)addPowerBtnPressed:(id)sender;
- (void)addSpeedBtnPressed:(id)sender;
@end

@interface AbilityScene : CCScene {
    AbilityLayer *_layer;
}
@property (nonatomic, retain) AbilityLayer *layer;
@end
