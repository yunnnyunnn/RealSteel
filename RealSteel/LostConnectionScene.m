//
//  LostConnectionScene.m
//  RealSteel
//
//  Created by Tim Chen on 11/12/28.
//  Copyright (c) 2011年 NCCU. All rights reserved.
//

#import "LostConnectionScene.h"

@implementation LostConnectionScene
@synthesize layer = _layer;

- (id)init {
    
    if ((self = [super init])) {
        self.layer = [LostConnectionLayer node];
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

@implementation LostConnectionLayer
@synthesize label = _label;

-(id) init
{
    if( (self=[super initWithColor:ccc4(255,255,255,255)] )) {
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        CCSprite * background = [CCSprite spriteWithFile:@"background_gameOver_lose.png"];
        background.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:background];
        
        self.label = [CCLabelTTF labelWithString:@"Lost connection" fontName:@"Arial" fontSize:50];
        _label.color = ccc3(255,255,255);
        _label.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:_label];
        
        [self performSelector:@selector(restart) withObject:nil afterDelay:5.0];
        
    }	
    return self;
}


- (void)restart {
    [[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene]];
}


- (void)dealloc {
    [_label release];
    _label = nil;
    [super dealloc];
}

@end