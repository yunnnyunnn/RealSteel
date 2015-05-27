//
//  GameSession.m
//  RealSteel
//
//  Created by Tim Chen on 11/12/27.
//  Copyright (c) 2011年 NCCU. All rights reserved.
//

#import "GameSession.h"

@implementation GameSession
@synthesize delegate;
@synthesize gameSession = _gameSession;

+ (GameSession *)sharedGameSession
{
    static dispatch_once_t pred;
    static GameSession * gameSession = nil;
    
    dispatch_once(&pred, ^{
        gameSession = [[GameSession alloc] init];
    });
    
    return gameSession;
}

- (id)init {
    
    if ((self = [super init])) {
        
    }
    return self;
}

- (void)sendPlayerHp:(int)hp defense:(BOOL)isDefense hitten:(BOOL)isHitten rotation:(float)rotationValue
{
    NSString * defense;
    if (isDefense) {
        defense = @"YES";
    } else {
        defense = @"NO";
    }
    
    NSString *hitten;
    if (isHitten) {
        hitten = @"YES";
    } else {
        hitten = @"NO";
    }
    
    NSString * dataString = [NSString stringWithFormat:@"state?%d?%@?%@?%f", hp, defense, hitten, rotationValue];
    NSData * data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    [self.gameSession sendDataToAllPeers:data withDataMode:GKSendDataUnreliable error:nil];
}

- (void)sendAttackPosition:(int)position
{
    NSString * dataString = [NSString stringWithFormat:@"attack?%d", position];
    NSData * data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    [self.gameSession sendDataToAllPeers:data withDataMode:GKSendDataReliable error:nil];
}

- (void)sendName:(NSString *)name totalHp:(int)hp andPower:(int)power
{
    NSString * dataString = [NSString stringWithFormat:@"initial?%@?%d?%d",name ,hp, power];
    NSData * data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    [self.gameSession sendDataToAllPeers:data withDataMode:GKSendDataReliable error:nil];
}

- (void)readyToReceivePlayerData
{
    NSString * dataString = @"ready?";
    NSData * data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    [self.gameSession sendDataToAllPeers:data withDataMode:GKSendDataReliable error:nil];
}

- (void)sendStartMessage
{
    NSString * dataString = @"start?";
    NSData * data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    [self.gameSession sendDataToAllPeers:data withDataMode:GKSendDataReliable error:nil];
}

- (void)sendPauseMessage
{
    NSString * dataString = @"pause?";
    NSData * data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    [self.gameSession sendDataToAllPeers:data withDataMode:GKSendDataReliable error:nil];
}

- (void)sendResumeMessage
{
    NSString * dataString = @"resume?";
    NSData * data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    [self.gameSession sendDataToAllPeers:data withDataMode:GKSendDataReliable error:nil];
}

#pragma GKSessionDelegate

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
    switch (state) {
        case GKPeerStateConnected:
            NSLog(@"connected with %@", peerID);
            break;
            
        case GKPeerStateDisconnected:
            NSLog(@"disconnected with %@", peerID);
            
            [delegate didReceiveLostConnectionMessage];
            
            break;
            
        default:
            break;
    }
}

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context
{
    // Read the bytes in data and perform an application-specific action.
    
    NSString * dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray * dataArray = [dataString componentsSeparatedByString:@"?"];
    [dataString release];
    if ([[dataArray objectAtIndex:0] isEqualToString:@"state"]) {
        [self.delegate didReceiveData:data];
    } else if ([[dataArray objectAtIndex:0] isEqualToString:@"attack"]) {
        [self.delegate didReceiveAttack:data];
    }
    else if ([[dataArray objectAtIndex:0] isEqualToString:@"initial"]) {
        [self.delegate didReceiveNameAndTotalHpAndPower:data];
    }
    else if ([[dataArray objectAtIndex:0] isEqualToString:@"ready"]) {
        [self.delegate readyToSendPlayerData];
    }
    else if ([[dataArray objectAtIndex:0] isEqualToString:@"start"]) {
        [self.delegate didReceiveStartMessage];
    }
    else if ([[dataArray objectAtIndex:0] isEqualToString:@"pause"]) {
        [self.delegate didReceivePauseMessage];
    }
    else if ([[dataArray objectAtIndex:0] isEqualToString:@"resume"]) {
        [self.delegate didReceiveResumeMessage];
    }
}

@end
