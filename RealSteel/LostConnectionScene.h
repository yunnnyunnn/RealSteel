//
//  LostConnectionScene.h
//  RealSteel
//
//  Created by Tim Chen on 11/12/28.
//  Copyright (c) 2011年 NCCU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "HelloWorldLayer.h"

@interface LostConnectionLayer : CCLayerColor {
    CCLabelTTF *_label;
}
@property (nonatomic, retain) CCLabelTTF *label;
- (void)restart;
@end

@interface LostConnectionScene : CCScene {
    LostConnectionLayer *_layer;
}
@property (nonatomic, retain) LostConnectionLayer *layer;
@end
