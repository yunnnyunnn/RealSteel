//
//  Player.m
//  RealSteel
//
//  Created by Tim Chen on 11/12/19.
//  Copyright (c) 2011年 NCCU. All rights reserved.
//

#import "Player.h"

@implementation Player

@synthesize name = _name;
@synthesize power = _power;
@synthesize hp = _curHp;
@synthesize totalHp = _totalHp;
@synthesize defense = _defense;
@synthesize hitten = _hitten;

@end


@implementation MyPlayer

+ (id)playerWithName:(NSString *)playerName totalHp:(int)playerHp andPower:(int)playerPower{
    Player * player = nil;
    if ((player = [[[super alloc] initWithFile:@"fighter.png"] autorelease])) {
        [player setName:playerName];
        [player setTotalHp:playerHp];
        [player setHp:playerHp];
        [player setPower:playerPower];
    }
    return player;
}

@end


@implementation Opponent

+ (id)playerWithName:(NSString *)playerName totalHp:(int)playerHp andPower:(int)playerPower{
    Player * player = nil;
    if ((player = [[[super alloc] initWithFile:@"opponent.png"] autorelease])) {
        [player setName:playerName];
        [player setTotalHp:playerHp];
        [player setHp:playerHp];
        [player setPower:playerPower];
    }
    return player;
}

@end
