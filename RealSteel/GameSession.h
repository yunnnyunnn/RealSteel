//
//  GameSession.h
//  RealSteel
//
//  Created by Tim Chen on 11/12/27.
//  Copyright (c) 2011年 NCCU. All rights reserved.
//



@protocol GameSessionProtocol <NSObject>

- (void)readyToSendPlayerData;
- (void)didReceiveData:(NSData *)data;
- (void)didReceiveAttack:(NSData *)data;
- (void)didReceiveNameAndTotalHpAndPower:(NSData *)data;
- (void)didReceiveStartMessage;
- (void)didReceivePauseMessage;
- (void)didReceiveResumeMessage;
- (void)didReceiveLostConnectionMessage;

@end

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "cocos2d.h"
#import "LostConnectionScene.h"

@interface GameSession : NSObject <GKSessionDelegate> {
    id <GameSessionProtocol> delegate;
    GKSession * _gameSession;
}

@property (retain) id delegate;
@property (nonatomic, retain) GKSession * gameSession;

+ (GameSession *)sharedGameSession;
- (void)sendPlayerHp:(int)hp defense:(BOOL)isDefense hitten:(BOOL)isHitten rotation:(float)rotationValue;
- (void)sendAttackPosition:(int)position;
- (void)sendName:(NSString *)name totalHp:(int)hp andPower:(int)power;
- (void)readyToReceivePlayerData;
- (void)sendStartMessage;
- (void)sendPauseMessage;
- (void)sendResumeMessage;

@end
