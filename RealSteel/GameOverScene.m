//
//  GameOverScene.m
//  Cocos2DSimpleGame
//
//  Created by Tim Chen on 11/12/12.
//  Copyright (c) 2011年 NCCU. All rights reserved.
//

#import "GameOverScene.h"

@implementation GameOverScene
@synthesize layer = _layer;

- (id)init {
    
    if ((self = [super init])) {
        self.layer = [GameOverLayer node];
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

@implementation GameOverLayer

-(id) init
{
    if( (self=[super initWithColor:ccc4(0,0,0,0)] )) {
        // get window size first
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        // set up background
        CCSprite * background = [CCSprite spriteWithFile:@"background_gameOver_lose.png"];
        background.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:background];
        
        // lose label
        CCLabelTTF * loseLabel = [CCLabelTTF labelWithString:@"you lose" fontName:@"Alexis Grunge" fontSize:60];
        loseLabel.position = ccp(160, 50);
        [self addChild:loseLabel];
        
        // back to menu button
        CCMenuItemImage * menuBtn = [CCMenuItemImage itemFromNormalImage:@"gameOver_menu.png" selectedImage:@"gameOver_menu_selected.png" target:self selector:@selector(menuBtnPressed:)];
        
        CCMenu * menu = [CCMenu menuWithItems:menuBtn, nil];
        menu.position = ccp(420, 30);
        [menu alignItemsVertically];
        [self addChild:menu];
    }
    return self;
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

