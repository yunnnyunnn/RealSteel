//
//  PracticeScene.h
//  RealSteel
//
//  Created by Tim Chen on 12/1/9.
//  Copyright (c) 2012年 NCCU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Player.h"
#import "GameOverScene.h"
#import "SimpleAudioEngine.h"
#import "WinnerScene.h"

@interface PracticeLayer : CCLayerColor <UIAccelerometerDelegate>{
    CCSprite * background;
    
    int _timeLeft;
    BOOL _gameStarted;
    CCLabelTTF * _timer;
    
    CCSprite * _playerHpBorder;
    CCProgressTimer * _playerHpBar;
    
    CCSprite * _opponentHpBorder;
    CCProgressTimer * _opponentHpBar;
    
    Player * _player;
    Player * _opponent;
    
    NSMutableArray * _opponentAttacks;
    NSMutableArray * _playerAttacks;
    
    UIAccelerometer *_accelerometer;
    
    int _maxCombo;
    int _combo;
    int _knockOut;
    BOOL _punching;
    BOOL _opponentPunching;
}

- (void)opponentAutoDefense;
- (void)opponentAutoRotate;
- (void)opponentAutoAttack;
- (void)opponentFinishAttack:(id)sender;
- (void)playerFinishAttack:(id)sender;
- (void)detectOpponentPunch:(ccTime)dt;
- (void)detectPlayerPunch:(ccTime)dt;
- (void)detectDie:(ccTime)dt;
- (void)playerBackToFightPositionAfterHitten;
- (void)opponentBackToFightPositionAfterHitten;
- (void)countDown;
- (void)shakeTheBackground;
- (void)redTheBackgroundWithTimes:(NSString *)times;
- (void)opponentCelebrate;
- (void)opponentLastShot;
- (void)playerCelebrate;
- (void)playerLastShot;
- (void)turnPunchingToNo;

@end



@interface PracticeScene : CCScene
{
    PracticeLayer * _practiceLayer;
}

@property (nonatomic, retain) PracticeLayer * practiceLayer;

@end
