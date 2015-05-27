//
//  FightScene.h
//  RealSteel
//
//  Created by Tim Chen on 11/12/27.
//  Copyright (c) 2011年 NCCU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "cocos2d.h"
#import "GameSession.h"
#import "Player.h"
#import "GameOverScene.h"
#import "SimpleAudioEngine.h"
#import "WinnerScene.h"

@interface FightLayer : CCLayerColor <UIAccelerometerDelegate, GameSessionProtocol>{
    GKSession * _fightSession;
    
    CCSprite * background;
    
    int readyToGoFlag;
    
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
    
    CCLabelTTF * _pauseLabel;
    
    int _maxCombo;
    int _combo;
    int _knockOut;
    BOOL _punching;
}

@property (nonatomic, retain) GKSession *fightSession;

- (void)opponentFinishAttack:(id)sender;
- (void)playerFinishAttack:(id)sender;
- (void)detectOpponentPunch:(ccTime)dt;
- (void)detectPlayerPunch:(ccTime)dt;
- (void)detectDie:(ccTime)dt;
- (void)playerBackToFightPositionAfterHitten;
- (void)opponentBackToFightPositionAfterHitten;
- (void)sendPlayerData;
- (void)checkOpponentExist;
- (void)countDown;
- (void)detectReadyToGo;
- (void)shakeTheBackground;
- (void)redTheBackgroundWithTimes:(NSString *)times;
- (void)opponentCelebrate;
- (void)opponentLastShot;
- (void)playerCelebrate;
- (void)playerLastShot;
- (void)turnPunchingToNo;

@end



@interface FightScene : CCScene
{
    FightLayer * _fightLayer;
}

@property (nonatomic, retain) FightLayer * fightLayer;

@end
