//
//  Player.h
//  RealSteel
//
//  Created by Tim Chen on 11/12/19.
//  Copyright (c) 2011年 NCCU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Player : CCSprite {
    NSString * _name;
    int _power;
    int _curHp;
    int _totalHp;
    BOOL _defense;
    BOOL _hitten;
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, assign) int power;
@property (nonatomic, assign) int hp;
@property (nonatomic, assign) int totalHp;
@property (nonatomic, assign) BOOL defense;
@property (nonatomic, assign) BOOL hitten;

@end


@interface MyPlayer : Player {
}

+ (id)playerWithName:(NSString *)playerName totalHp:(int)playerHp andPower:(int)playerPower;

@end


@interface Opponent : Player {
}

+ (id)playerWithName:(NSString *)playerName totalHp:(int)playerHp andPower:(int)playerPower;

@end