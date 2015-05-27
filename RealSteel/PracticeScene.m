//
//  PracticeScene.m
//  RealSteel
//
//  Created by Tim Chen on 12/1/9.
//  Copyright (c) 2012年 NCCU. All rights reserved.
//

#import "PracticeScene.h"

@implementation PracticeScene
@synthesize practiceLayer = _practiceLayer;

- (id)init {
    
    if ((self = [super init])) {
        self.practiceLayer = [PracticeLayer node];
        [self addChild:_practiceLayer];
    }
    return self;
}

- (void)dealloc {
    [_practiceLayer release];
    _practiceLayer = nil;
    [super dealloc];
}

@end




@implementation PracticeLayer

-(id) init
{
    if( (self=[super initWithColor:ccc4(0,0,0,0)] )) {
        
        // initial accelerometer
        _accelerometer = [UIAccelerometer sharedAccelerometer];
        _accelerometer.delegate = self;
        _accelerometer.updateInterval = 1.0f/60.0f;
        
        // initial attacks array to track them
        _opponentAttacks = [[NSMutableArray alloc] init];
        _playerAttacks = [[NSMutableArray alloc] init];
        
        // get the window size first
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        // set background
        background = [CCSprite spriteWithFile:@"Background.png"];
        background.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:background z:0];
        
        // set up player total hp and name and tell peer its ready to receive
        NSString * playerName = [[NSUserDefaults standardUserDefaults] stringForKey:@"profile_robotName"];
        int playerTotalHp = [[NSUserDefaults standardUserDefaults] integerForKey:@"profile_hp"];
        int playerPower = [[NSUserDefaults standardUserDefaults] integerForKey:@"profile_power"];
        
        // initial player
        _player = [MyPlayer playerWithName:playerName totalHp:playerTotalHp andPower:playerPower];
        _player.position = ccp(winSize.width/2, -(_player.contentSize.height/4));
        [self addChild:_player z:3];
        _punching = NO;
        
        // set up player name
        CCLabelTTF * playerNameLbl = [CCLabelTTF labelWithString:_player.name fontName:@"Alexis Grunge" fontSize:20];
        playerNameLbl.position = ccp(15 + playerNameLbl.contentSize.width/2, winSize.height - playerNameLbl.contentSize.height/2 -5);
        [self addChild:playerNameLbl z:4];
        
        // set up player hp
        _playerHpBorder = [CCSprite spriteWithFile:@"hp_border.png"];
        _playerHpBorder.position = ccp(3 + _playerHpBorder.contentSize.width/2, playerNameLbl.position.y - _playerHpBorder.contentSize.height/2 + 5);
        
        _playerHpBar = [CCProgressTimer progressWithFile:@"hp.png"];
        _playerHpBar.type = kCCProgressTimerTypeHorizontalBarLR;
        [_playerHpBorder addChild:_playerHpBar];
        [_playerHpBar setAnchorPoint:ccp(0, 0)];
        
        [self addChild:_playerHpBorder z:4];
        CCAction * runHp = [CCProgressFromTo actionWithDuration:1 from:0 to:100];
        [_playerHpBar runAction:runHp];
        
        // initial opponent
        _opponentPunching = NO;
        NSString * opponentName = @"ROBOT";
        int opponentTotalHp = playerTotalHp;
        int opponentPower = playerPower;
        
        _opponent = [Opponent playerWithName:opponentName totalHp:opponentTotalHp andPower:opponentPower];
        _opponent.position = ccp(winSize.width/2, 400);
        [self addChild:_opponent z:1];
        id opponentPopUp = [CCMoveTo actionWithDuration:0.2 position:ccp(winSize.width/2, 50-(_opponent.contentSize.height/4))];
        [_opponent runAction:[CCSequence actions:opponentPopUp, [CCCallFunc actionWithTarget:self selector:@selector(shakeTheBackground)], nil]];
        [[SimpleAudioEngine sharedEngine] playEffect:@"hit.m4a"];
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        
        // set up opponent name
        CCLabelTTF * opponentNameLbl = [CCLabelTTF labelWithString:_opponent.name fontName:@"Alexis Grunge" fontSize:20];
        opponentNameLbl.position = ccp(winSize.width - opponentNameLbl.contentSize.width/2 - 15, winSize.height - opponentNameLbl.contentSize.height/2 -5);
        [self addChild:opponentNameLbl z:4];
        
        // set up opponent hp
        _opponentHpBorder = [CCSprite spriteWithFile:@"hp_border.png"];
        _opponentHpBorder.position = ccp(winSize.width - _opponentHpBorder.contentSize.width/2 - 3, opponentNameLbl.position.y - _opponentHpBorder.contentSize.height/2 + 5);
        
        _opponentHpBar = [CCProgressTimer progressWithFile:@"hp.png"];
        _opponentHpBar.type = kCCProgressTimerTypeHorizontalBarRL;
        [_opponentHpBorder addChild:_opponentHpBar];
        [_opponentHpBar setAnchorPoint:ccp(0, 0)];
        
        [self addChild:_opponentHpBorder z:4];
        CCAction * runOpponentHp = [CCProgressFromTo actionWithDuration:1 from:0 to:100];
        [_opponentHpBar runAction:runOpponentHp];
        
        [self schedule:@selector(detectDie:)];
        
        
        // detect opponent punch
        [self schedule:@selector(detectOpponentPunch:)];
        // detect player puch
        [self schedule:@selector(detectPlayerPunch:)];
        
        // set the punching interval
        int playerSpeed = [[NSUserDefaults standardUserDefaults]integerForKey:@"profile_speed"];
        float realSpeed = 1 - (log2f((float)playerSpeed) * 0.2);
        if (realSpeed < 0.1) {
            realSpeed = 0.1;
        }
        NSLog(@"real speed is %f", realSpeed);
        [self schedule:@selector(turnPunchingToNo) interval:realSpeed];
        
        // start countdown timer
        _gameStarted = NO;
        _timeLeft = 3;
        _timer = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", _timeLeft] fontName:@"Alexis Grunge" fontSize:80];
        [_timer setScale:5];
        [_timer runAction:[CCSpawn actionOne:[CCScaleTo actionWithDuration:0.5 scale:1] 
                                         two:[CCFadeIn actionWithDuration:0.5]
                           ]
         ];
        [_timer setColor:ccc3(255, 0, 0)];
        _timer.position = ccp(240, 160);
        [self addChild:_timer z:5];
        [self schedule:@selector(countDown) interval:1];
        
        [self schedule:@selector(opponentAutoDefense) interval:1];
        [self schedule:@selector(opponentAutoRotate) interval:1];
    }
	
    return self;
}

- (void)dealloc {
    [_opponentAttacks release];
    _opponentAttacks = nil;
    [_playerAttacks release];
    _playerAttacks = nil;
    
    [super dealloc];
}

- (void)opponentAutoDefense
{
    if (!_opponent.hitten && !_opponentPunching) {
        int randomDefense = arc4random() % 100;
        if (randomDefense > 50) {
            if (_opponent.defense == NO) {
                [_opponent setTexture:[[CCTextureCache sharedTextureCache] addImage:@"opponent_defense.png"]];
                _opponent.defense = YES;
            }
            else if (_opponent.defense == YES)
            {
                [_opponent setTexture:[[CCTextureCache sharedTextureCache] addImage:@"opponent.png"]];
                _opponent.defense = NO;
            }

        }
    }
}


-(void)opponentAutoRotate
{
    int randomRotate = (arc4random() % 100) - 50;
    [_opponent runAction:[CCRotateTo actionWithDuration:0.5 angle:randomRotate]];
}

- (void)opponentAutoAttack
{
    if (!_opponent.defense && !_opponent.hitten && !_opponentPunching) {
        int randomAttack = arc4random() % 100;
        
        if (randomAttack < 15) {
            
            _opponentPunching = YES;
            [[SimpleAudioEngine sharedEngine] playEffect:@"swing.mp3"];
            
            // add attack
            CCSprite * attack = [CCSprite spriteWithFile:@"fist.png"];
            
            int randomPosition = arc4random() % 2;
            
            int x = 60;
            
            float opponentRotation = _opponent.rotation;
            if (opponentRotation < -35) {
                [_opponent setTexture:[[CCTextureCache sharedTextureCache] addImage:@"opponent_leftFist.png"]];
                x = 60;
            }
            else if (-35 < opponentRotation && opponentRotation < -15) {
                if (randomPosition == 1) {
                    [_opponent setTexture:[[CCTextureCache sharedTextureCache] addImage:@"opponent_rightFist.png"]];
                    x = 60;
                } else {
                    [_opponent setTexture:[[CCTextureCache sharedTextureCache] addImage:@"opponent_leftFist.png"]];
                    x = 180;
                }
            }
            else if (-15 < opponentRotation && opponentRotation < 15) {
                if (randomPosition == 1) {
                    [_opponent setTexture:[[CCTextureCache sharedTextureCache] addImage:@"opponent_rightFist.png"]];
                    x = 180;
                } else {
                    [_opponent setTexture:[[CCTextureCache sharedTextureCache] addImage:@"opponent_leftFist.png"]];
                    x = 300;
                }
            }
            else if (15 < opponentRotation && opponentRotation < 35) {
                if (randomPosition == 1) {
                    [_opponent setTexture:[[CCTextureCache sharedTextureCache] addImage:@"opponent_rightFist.png"]];
                    x = 300;
                } else {
                    [_opponent setTexture:[[CCTextureCache sharedTextureCache] addImage:@"opponent_leftFist.png"]];
                    x = 420;
                }
            }
            else if (35 < opponentRotation) {
                [_opponent setTexture:[[CCTextureCache sharedTextureCache] addImage:@"opponent_rightFist.png"]];
                x = 420;
            }
            
            
            attack.position = ccp(x, 100);
            
            [self addChild:attack z:2];
            
            // attack action
            id actionPunch = [CCScaleTo actionWithDuration:0.2 scale:5.0f];
            id actionFade = [CCFadeIn actionWithDuration:0.2];
            id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(opponentFinishAttack:)];
            [attack runAction:[CCSequence actions:[CCSpawn actionOne:actionPunch two:actionFade], actionMoveDone,nil]];
            
            // track each attack
            [_opponentAttacks addObject:attack];
        }
        
    }
}



- (void)turnPunchingToNo
{
    _punching = NO;
    _opponentPunching = NO;
}

- (void)countDown
{
    
    if (_gameStarted) {
        // allow user touch
        [self setIsTouchEnabled:YES];
        [self schedule:@selector(opponentAutoAttack)];
        _timeLeft--;
        
        if (_timeLeft < 10) {
            [_timer setColor:ccc3(255, 0, 0)];
            [_timer setString:[NSString stringWithFormat:@"0:0%d", _timeLeft]];
            [_timer setScale:1];
            [_timer runAction:[CCSpawn actionOne:[CCScaleTo actionWithDuration:0.5 scale:0.5] 
                                             two:[CCFadeIn actionWithDuration:0.5]
                               ]
             ];
        }
        else
            [_timer setString:[NSString stringWithFormat:@"0:%d", _timeLeft]];
        
        // game over condition
        if (_timeLeft == 0) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"bell.mp3"];
            [self unscheduleAllSelectors];
            _accelerometer.delegate = nil;
            [[GameSession sharedGameSession] setDelegate:nil];
            
            if (_playerHpBar.percentage > _opponentHpBar.percentage) {
                [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"fighter_victory.png"]];
                
                _knockOut = 0;
                WinnerScene * winnerScene = [WinnerScene node];
                winnerScene.layer.maxCombo = _maxCombo;
                winnerScene.layer.knockOut = _knockOut;
                winnerScene.layer.timeBonus = _timeLeft;
                
                id replaceSceneAction = [CCCallFuncO actionWithTarget:[CCDirector sharedDirector] selector:@selector(replaceScene:) object:winnerScene];
                
                [_player runAction:[CCSequence actionOne:[CCJumpTo actionWithDuration:5 position:_player.position height:50 jumps:5] two:replaceSceneAction]];
            } else if (_playerHpBar.percentage == _opponentHpBar.percentage) {
                CCLabelTTF * drawLabel = [CCLabelTTF labelWithString:@"draw!" fontName:@"Alexis Grunge" fontSize:60];
                drawLabel.position = ccp(240, 160);
                [self addChild:drawLabel z:10];
                id rematch = [CCCallFuncO actionWithTarget:[CCDirector sharedDirector] selector:@selector(replaceScene:) object:[PracticeScene node]];
                [drawLabel setScale:5];
                [drawLabel runAction:[CCSequence actionOne:
                                      [CCSpawn actionOne:[CCScaleTo actionWithDuration:0.5 scale:1] 
                                                     two:[CCFadeIn actionWithDuration:1]
                                       ]
                                                       two:
                                      rematch]];
            } else {
                [self removeChild:_opponent cleanup:YES];
                CCSprite * celebratingOpponent = [CCSprite spriteWithFile:@"opponent_victory.png"];
                celebratingOpponent.position = ccp(240, -150);
                [self addChild:celebratingOpponent z:2];
                
                GameOverScene * gameOverScene = [GameOverScene node];
                id replaceSceneAction = [CCCallFuncO actionWithTarget:[CCDirector sharedDirector] selector:@selector(replaceScene:) object:gameOverScene];
                
                [celebratingOpponent runAction:[CCSequence actionOne:[CCJumpTo actionWithDuration:5 position:celebratingOpponent.position height:50 jumps:5] two:replaceSceneAction]];
            }
            
        }
    } else {
        _timeLeft--;
        if (_timeLeft == 0) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"bell.mp3"];
            [_timer setString:@"Fight!!"];
            [_timer setScale:5];
            [_timer runAction:[CCSequence actionOne:[CCSpawn actionOne:[CCScaleTo actionWithDuration:0.5 scale:1] 
                                                                   two:[CCFadeIn actionWithDuration:0.5]
                                                     ]
                                                two:[CCSpawn actionOne:[CCScaleTo actionWithDuration:1 scale:0.5] 
                                                                   two:[CCMoveTo actionWithDuration:1 position:ccp(240, 295)]
                                                     ]]
             ];
            _timeLeft = 60;
            _gameStarted = YES;
            [_timer setColor:ccc3(255, 255, 255)];
            
        } else {
            [_timer setString:[NSString stringWithFormat:@"%d", _timeLeft]];
            [_timer setScale:5];
            [_timer runAction:[CCSpawn actionOne:[CCScaleTo actionWithDuration:0.5 scale:1] 
                                             two:[CCFadeIn actionWithDuration:0.5]
                               ]
             ];
        }
        
    }
    
}

- (void)opponentFinishAttack:(id)sender
{
    CCSprite * attack = (CCSprite *)sender;
    [self removeChild:attack cleanup:YES];
    [_opponentAttacks removeObject:attack];
    if (_player.hp > 0) {
        if (_opponent.defense) {
            [_opponent setTexture:[[CCTextureCache sharedTextureCache] addImage:@"opponent_defense.png"]];
        } else {
            [_opponent setTexture:[[CCTextureCache sharedTextureCache] addImage:@"opponent.png"]];
        }
    }
    
}

- (void)detectPlayerPunch:(ccTime)dt
{
    // collect the seccess attacks to delete
    NSMutableArray * attackToDelete = [[NSMutableArray alloc] init];
    
    for (CCSprite * attack in _playerAttacks)
    {
        // get the attack position
        int attackPosition = attack.position.x;
        // get player position
        float opponentRotation = _opponent.rotation;
        
        // randomize sound effect that use for player being hitten
        int randomEffect = (arc4random() % 2);
        
        switch (attackPosition) {
            case 60:
                if (opponentRotation < -5) {
                    // add explosion
                    CCParticleExplosion * explosion = [[CCParticleExplosion alloc] init];
                    explosion.texture = [[CCTextureCache sharedTextureCache] addImage:@"fire.png"];
                    [explosion setStartColor:ccc4FFromccc3B(ccc3(255, 255, 0))];
                    [explosion setSpeed:300];
                    [explosion setEmissionRate:150];
                    [explosion setPosition:ccp(attackPosition, 100)];
                    [self addChild:explosion z:2];
                    [explosion release];
                    
                    // attack is at player position
                    [[SimpleAudioEngine sharedEngine] playEffect:@"hit.m4a"];
                    if (_opponent.defense) {
                        // attack blocked
                        _combo = 0;
                        [attackToDelete addObject:attack];
                        //NSLog(@"blocked");
                    } else {
                        // attack seccess!
                        _combo++;
                        CCLabelTTF * comboLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d combo!", _combo] fontName:@"Alexis Grunge" fontSize:30];
                        [comboLabel setColor:ccc3(255, 255, 0)];
                        comboLabel.position = ccp(attackPosition, 100);
                        [self addChild:comboLabel z:2];
                        [comboLabel runAction:[CCSpawn actions:
                                               [CCFadeOut actionWithDuration:1.5],
                                               [CCMoveBy actionWithDuration:1 position:ccp(0, 100)],
                                               [CCScaleTo actionWithDuration:1 scale:2],
                                               nil]];
                        if (_combo > _maxCombo) {
                            _maxCombo = _combo;
                        }
                        [_opponent setTexture:[[CCTextureCache sharedTextureCache] addImage:@"opponent_hitten.png"]];
                        _opponent.hitten = YES;
                        _opponent.hp = _opponent.hp - _player.power;
                        
                        float newHpPercentage = (float)_opponent.hp / (float)_opponent.totalHp * 100;
                        CCAction * runHp = [CCProgressFromTo actionWithDuration:0.5 from:_opponentHpBar.percentage to:newHpPercentage];
                        [_opponentHpBar runAction:runHp];
                        NSLog(@"_opponent.hp:%d _player.power:%d _opponent.totalHp:%d newHpPercentage:%f", _opponent.hp, _player.power, _opponent.totalHp, newHpPercentage);
                        
                        
                        [attackToDelete addObject:attack];
                        //NSLog(@"opponent hitted");
                        [self performSelector:@selector(opponentBackToFightPositionAfterHitten) withObject:nil afterDelay:0.5];
                    }
                }
                else
                    _combo = 0;
                break;
            case 180:
                if (-35 < opponentRotation && opponentRotation < 15) {
                    // add explosion
                    CCParticleExplosion * explosion = [[CCParticleExplosion alloc] init];
                    explosion.texture = [[CCTextureCache sharedTextureCache] addImage:@"fire.png"];
                    [explosion setStartColor:ccc4FFromccc3B(ccc3(255, 255, 0))];
                    [explosion setSpeed:300];
                    [explosion setEmissionRate:150];
                    [explosion setPosition:ccp(attackPosition, 100)];
                    [self addChild:explosion z:2];
                    [explosion release];
                    
                    // attack is at player position
                    [[SimpleAudioEngine sharedEngine] playEffect:@"hit.m4a"];
                    if (_opponent.defense) {
                        // attack blocked
                        _combo = 0;
                        [attackToDelete addObject:attack];
                        //NSLog(@"blocked");
                    } else {
                        // attack seccess!
                        _combo++;
                        CCLabelTTF * comboLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d combo!", _combo] fontName:@"Alexis Grunge" fontSize:30];
                        [comboLabel setColor:ccc3(255, 255, 0)];
                        comboLabel.position = ccp(attackPosition, 100);
                        [self addChild:comboLabel z:2];
                        [comboLabel runAction:[CCSpawn actions:
                                               [CCFadeOut actionWithDuration:1.5],
                                               [CCMoveBy actionWithDuration:1 position:ccp(0, 100)],
                                               [CCScaleTo actionWithDuration:1 scale:2],
                                               nil]];
                        if (_combo > _maxCombo) {
                            _maxCombo = _combo;
                        }
                        [_opponent setTexture:[[CCTextureCache sharedTextureCache] addImage:@"opponent_hitten.png"]];
                        _opponent.hitten = YES;
                        _opponent.hp = _opponent.hp - _player.power;
                        
                        float newHpPercentage = (float)_opponent.hp / (float)_opponent.totalHp * 100;
                        CCAction * runHp = [CCProgressFromTo actionWithDuration:0.5 from:_opponentHpBar.percentage to:newHpPercentage];
                        [_opponentHpBar runAction:runHp];
                        NSLog(@"_opponent.hp:%d _player.power:%d _opponent.totalHp:%d newHpPercentage:%f", _opponent.hp, _player.power, _opponent.totalHp, newHpPercentage);
                        
                        
                        [attackToDelete addObject:attack];
                        //NSLog(@"opponent hitted");
                        [self performSelector:@selector(opponentBackToFightPositionAfterHitten) withObject:nil afterDelay:0.5];
                    }
                }
                else
                    _combo = 0;
                break;
            case 300:
                if (-15 < opponentRotation && opponentRotation < 35) {
                    // add explosion
                    CCParticleExplosion * explosion = [[CCParticleExplosion alloc] init];
                    explosion.texture = [[CCTextureCache sharedTextureCache] addImage:@"fire.png"];
                    [explosion setStartColor:ccc4FFromccc3B(ccc3(255, 255, 0))];
                    [explosion setSpeed:300];
                    [explosion setEmissionRate:150];
                    [explosion setPosition:ccp(attackPosition, 100)];
                    [self addChild:explosion z:2];
                    [explosion release];
                    
                    // attack is at player position
                    [[SimpleAudioEngine sharedEngine] playEffect:@"hit.m4a"];
                    if (_opponent.defense) {
                        // attack blocked
                        _combo = 0;
                        [attackToDelete addObject:attack];
                        //NSLog(@"blocked");
                    } else {
                        // attack seccess!
                        _combo++;
                        CCLabelTTF * comboLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d combo!", _combo] fontName:@"Alexis Grunge" fontSize:30];
                        [comboLabel setColor:ccc3(255, 255, 0)];
                        comboLabel.position = ccp(attackPosition, 100);
                        [self addChild:comboLabel z:2];
                        [comboLabel runAction:[CCSpawn actions:
                                               [CCFadeOut actionWithDuration:1.5],
                                               [CCMoveBy actionWithDuration:1 position:ccp(0, 100)],
                                               [CCScaleTo actionWithDuration:1 scale:2],
                                               nil]];
                        if (_combo > _maxCombo) {
                            _maxCombo = _combo;
                        }
                        [_opponent setTexture:[[CCTextureCache sharedTextureCache] addImage:@"opponent_hitten.png"]];
                        _opponent.hitten = YES;
                        _opponent.hp = _opponent.hp - _player.power;
                        
                        float newHpPercentage = (float)_opponent.hp / (float)_opponent.totalHp * 100;
                        CCAction * runHp = [CCProgressFromTo actionWithDuration:0.5 from:_opponentHpBar.percentage to:newHpPercentage];
                        [_opponentHpBar runAction:runHp];
                        NSLog(@"_opponent.hp:%d _player.power:%d _opponent.totalHp:%d newHpPercentage:%f", _opponent.hp, _player.power, _opponent.totalHp, newHpPercentage);
                        
                        
                        [attackToDelete addObject:attack];
                        //NSLog(@"opponent hitted");
                        [self performSelector:@selector(opponentBackToFightPositionAfterHitten) withObject:nil afterDelay:0.5];
                    }
                }
                else
                    _combo = 0;
                break;
            case 420:
                if (5 < opponentRotation) {
                    // add explosion
                    CCParticleExplosion * explosion = [[CCParticleExplosion alloc] init];
                    explosion.texture = [[CCTextureCache sharedTextureCache] addImage:@"fire.png"];
                    [explosion setStartColor:ccc4FFromccc3B(ccc3(255, 255, 0))];
                    [explosion setSpeed:300];
                    [explosion setEmissionRate:150];
                    [explosion setPosition:ccp(attackPosition, 100)];
                    [self addChild:explosion z:2];
                    [explosion release];
                    
                    // attack is at player position
                    [[SimpleAudioEngine sharedEngine] playEffect:@"hit.m4a"];
                    if (_opponent.defense) {
                        // attack blocked
                        _combo = 0;
                        [attackToDelete addObject:attack];
                        //NSLog(@"blocked");
                    } else {
                        // attack seccess!
                        _combo++;
                        CCLabelTTF * comboLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d combo!", _combo] fontName:@"Alexis Grunge" fontSize:30];
                        [comboLabel setColor:ccc3(255, 255, 0)];
                        comboLabel.position = ccp(attackPosition, 100);
                        [self addChild:comboLabel z:2];
                        [comboLabel runAction:[CCSpawn actions:
                                               [CCFadeOut actionWithDuration:1.5],
                                               [CCMoveBy actionWithDuration:1 position:ccp(0, 100)],
                                               [CCScaleTo actionWithDuration:1 scale:2],
                                               nil]];
                        if (_combo > _maxCombo) {
                            _maxCombo = _combo;
                        }
                        [_opponent setTexture:[[CCTextureCache sharedTextureCache] addImage:@"opponent_hitten.png"]];
                        _opponent.hitten = YES;
                        _opponent.hp = _opponent.hp - _player.power;
                        
                        float newHpPercentage = (float)_opponent.hp / (float)_opponent.totalHp * 100;
                        CCAction * runHp = [CCProgressFromTo actionWithDuration:0.5 from:_opponentHpBar.percentage to:newHpPercentage];
                        [_opponentHpBar runAction:runHp];
                        NSLog(@"_opponent.hp:%d _player.power:%d _opponent.totalHp:%d newHpPercentage:%f", _opponent.hp, _player.power, _opponent.totalHp, newHpPercentage);
                        
                        [attackToDelete addObject:attack];
                        //NSLog(@"opponent hitted");
                        [self performSelector:@selector(opponentBackToFightPositionAfterHitten) withObject:nil afterDelay:0.5];
                    }
                }
                else
                    _combo = 0;
                break;
                
            default:
                break;
        }
        break;
    }
    
    for (CCSprite * attack in attackToDelete)
    {
        [_playerAttacks removeObject:attack];
    }
    [attackToDelete release];
}

- (void)detectOpponentPunch:(ccTime)dt
{
    // collect the seccess attacks to delete
    NSMutableArray * attackToDelete = [[NSMutableArray alloc] init];
    
    for (CCSprite * attack in _opponentAttacks)
    {
        // get the attack position
        int attackPosition = attack.position.x;
        // get player position
        float playerRotation = _player.rotation;
        
        // randomize sound effect that use for player being hitten
        int randomEffect = (arc4random() % 2);
        
        switch (attackPosition) {
            case 60:
                if (playerRotation < -5) {
                    // add explosion
                    CCParticleExplosion * explosion = [[CCParticleExplosion alloc] init];
                    explosion.texture = [[CCTextureCache sharedTextureCache] addImage:@"fire.png"];
                    [explosion setStartColor:ccc4FFromccc3B(ccc3(255, 255, 0))];
                    [explosion setSpeed:300];
                    [explosion setEmissionRate:150];
                    [explosion setPosition:ccp(attackPosition, 100)];
                    [self addChild:explosion z:2];
                    [explosion release];
                    
                    // attack is at player position
                    [[SimpleAudioEngine sharedEngine] playEffect:@"hit.m4a"];
                    if (_player.defense) {
                        // attack blocked
                        [attackToDelete addObject:attack];
                        //NSLog(@"blocked");
                    } else {
                        // attack seccess!
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                        // let the background sparkle red
                        [self redTheBackgroundWithTimes:@"1"];
                        
                        [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"fighter_hitten.png"]];
                        _player.hitten = YES;
                        _player.hp = _player.hp - _opponent.power;
                        
                        float newHpPercentage = (float)_player.hp / (float)_player.totalHp * 100;
                        CCAction * runHp = [CCProgressFromTo actionWithDuration:0.5 from:_playerHpBar.percentage to:newHpPercentage];
                        [_playerHpBar runAction:runHp];
                        
                        
                        [attackToDelete addObject:attack];
                        //NSLog(@"hit");
                        [self performSelector:@selector(playerBackToFightPositionAfterHitten) withObject:nil afterDelay:0.5];
                    }
                }
                break;
            case 180:
                if (-35 < playerRotation && playerRotation < 15) {
                    // add explosion
                    CCParticleExplosion * explosion = [[CCParticleExplosion alloc] init];
                    explosion.texture = [[CCTextureCache sharedTextureCache] addImage:@"fire.png"];
                    [explosion setStartColor:ccc4FFromccc3B(ccc3(255, 255, 0))];
                    [explosion setSpeed:300];
                    [explosion setEmissionRate:150];
                    [explosion setPosition:ccp(attackPosition, 100)];
                    [self addChild:explosion z:2];
                    [explosion release];
                    
                    // attack is at player position
                    [[SimpleAudioEngine sharedEngine] playEffect:@"hit.m4a"];
                    if (_player.defense) {
                        // attack blocked
                        [attackToDelete addObject:attack];
                        //NSLog(@"blocked");
                    } else {
                        // attack seccess!
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                        // let the background sparkle red
                        [self redTheBackgroundWithTimes:@"1"];
                        
                        [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"fighter_hitten.png"]];
                        _player.hitten = YES;
                        _player.hp = _player.hp - _opponent.power;
                        
                        float newHpPercentage = (float)_player.hp / (float)_player.totalHp * 100;
                        CCAction * runHp = [CCProgressFromTo actionWithDuration:0.5 from:_playerHpBar.percentage to:newHpPercentage];
                        [_playerHpBar runAction:runHp];
                        
                        [attackToDelete addObject:attack];
                        //NSLog(@"hit");
                        [self performSelector:@selector(playerBackToFightPositionAfterHitten) withObject:nil afterDelay:0.5];
                    }
                }
                break;
            case 300:
                if (-15 < playerRotation && playerRotation < 35) {
                    
                    // add explosion
                    CCParticleExplosion * explosion = [[CCParticleExplosion alloc] init];
                    explosion.texture = [[CCTextureCache sharedTextureCache] addImage:@"fire.png"];
                    [explosion setStartColor:ccc4FFromccc3B(ccc3(255, 255, 0))];
                    [explosion setSpeed:300];
                    [explosion setEmissionRate:150];
                    [explosion setPosition:ccp(attackPosition, 100)];
                    [self addChild:explosion z:2];
                    [explosion release];
                    
                    // attack is at player position
                    [[SimpleAudioEngine sharedEngine] playEffect:@"hit.m4a"];
                    if (_player.defense) {
                        // attack blocked
                        [attackToDelete addObject:attack];
                        //NSLog(@"blocked");
                    } else {
                        // attack seccess!
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                        // let the background sparkle red
                        [self redTheBackgroundWithTimes:@"1"];
                        
                        [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"fighter_hitten.png"]];
                        _player.hitten = YES;
                        _player.hp = _player.hp - _opponent.power;
                        
                        float newHpPercentage = (float)_player.hp / (float)_player.totalHp * 100;
                        CCAction * runHp = [CCProgressFromTo actionWithDuration:0.5 from:_playerHpBar.percentage to:newHpPercentage];
                        [_playerHpBar runAction:runHp];
                        
                        
                        [attackToDelete addObject:attack];
                        //NSLog(@"hit");
                        [self performSelector:@selector(playerBackToFightPositionAfterHitten) withObject:nil afterDelay:0.5];
                    }
                }
                break;
            case 420:
                if (5 < playerRotation) {
                    // add explosion
                    CCParticleExplosion * explosion = [[CCParticleExplosion alloc] init];
                    explosion.texture = [[CCTextureCache sharedTextureCache] addImage:@"fire.png"];
                    [explosion setStartColor:ccc4FFromccc3B(ccc3(255, 255, 0))];
                    [explosion setSpeed:300];
                    [explosion setEmissionRate:150];
                    [explosion setPosition:ccp(attackPosition, 100)];
                    [self addChild:explosion z:2];
                    [explosion release];
                    
                    // attack is at player position
                    [[SimpleAudioEngine sharedEngine] playEffect:@"hit.m4a"];
                    if (_player.defense) {
                        // attack blocked
                        [attackToDelete addObject:attack];
                        //NSLog(@"blocked");
                    } else {
                        // attack seccess!
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                        // let the background sparkle red
                        [self redTheBackgroundWithTimes:@"1"];
                        
                        [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"fighter_hitten.png"]];
                        _player.hitten = YES;
                        _player.hp = _player.hp - _opponent.power;
                        
                        float newHpPercentage = (float)_player.hp / (float)_player.totalHp * 100;
                        CCAction * runHp = [CCProgressFromTo actionWithDuration:0.5 from:_playerHpBar.percentage to:newHpPercentage];
                        [_playerHpBar runAction:runHp];
                        
                        
                        [attackToDelete addObject:attack];
                        //NSLog(@"hit");
                        [self performSelector:@selector(playerBackToFightPositionAfterHitten) withObject:nil afterDelay:0.5];
                    }
                }
                break;
                
            default:
                break;
        }
        break;
    }
    
    for (CCSprite * attack in attackToDelete)
    {
        [_opponentAttacks removeObject:attack];
    }
    [attackToDelete release];
    
}

- (void)detectDie:(ccTime)dt
{
    if (_player.hp <= 0) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"bell.mp3"];
        [self unscheduleAllSelectors];
        [self setIsTouchEnabled:NO];
        _accelerometer.delegate = nil;
        [[GameSession sharedGameSession] setDelegate:nil];
        
        [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"fighter_hitten.png"]];
        
        // game over player been knock out condition
        [_player runAction:[CCSpawn actionOne:
                            [CCSequence actions:
                             [CCSpawn actions:
                              [CCMoveBy actionWithDuration:2 position:ccp(0, 200)],
                              [CCRotateBy actionWithDuration:2 angle:50],
                              [CCCallFunc actionWithTarget:self selector:@selector(opponentLastShot)],
                              nil],
                             [CCMoveBy actionWithDuration:0.2 position:ccp(0, -300)],
                             [CCSpawn actionOne:
                              [CCCallFuncO actionWithTarget:[SimpleAudioEngine sharedEngine] selector:@selector(playEffect:) object:@"hit.m4a"]
                                            two:
                              [CCCallFuncN actionWithTarget:self selector:@selector(shakeTheBackground)]],
                             [CCCallFunc actionWithTarget:self selector:@selector(opponentCelebrate)],
                             nil]
                                          two:
                            [CCCallFuncO actionWithTarget:self selector:@selector(redTheBackgroundWithTimes:) object:@"5"]]];
    }
    if (_opponent.hp <= 0) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"bell.mp3"];
        [self unscheduleAllSelectors];
        [self setIsTouchEnabled:NO];
        _accelerometer.delegate = nil;
        [[GameSession sharedGameSession] setDelegate:nil];
        
        [_opponent setTexture:[[CCTextureCache sharedTextureCache] addImage:@"opponent_hitten.png"]];
        
        // game over player win condition
        _knockOut = 5;
        [_opponent runAction:[CCSequence actions:
                              [CCSpawn actions:
                               [CCMoveBy actionWithDuration:2 position:ccp(0, 200)],
                               [CCRotateBy actionWithDuration:2 angle:-50],
                               [CCCallFunc actionWithTarget:self selector:@selector(playerLastShot)],
                               nil],
                              [CCMoveBy actionWithDuration:0.2 position:ccp(0, -300)],
                              [CCSpawn actionOne:
                               [CCCallFuncO actionWithTarget:[SimpleAudioEngine sharedEngine] selector:@selector(playEffect:) object:@"hit.m4a"]
                                             two:
                               [CCCallFuncN actionWithTarget:self selector:@selector(shakeTheBackground)]],
                              [CCCallFunc actionWithTarget:self selector:@selector(playerCelebrate)],
                              nil]];
    }
    
}

- (void)playerLastShot
{
    [_player runAction:[CCMoveBy actionWithDuration:2 position:ccp(-50, 50)]];
}

- (void)playerCelebrate
{
    [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"fighter_victory.png"]];
    
    WinnerScene * winnerScene = [WinnerScene node];
    winnerScene.layer.maxCombo = _maxCombo;
    winnerScene.layer.knockOut = _knockOut;
    winnerScene.layer.timeBonus = _timeLeft;
    
    
    id replaceSceneAction = [CCCallFuncO actionWithTarget:[CCDirector sharedDirector] selector:@selector(replaceScene:) object:winnerScene];
    
    [_player runAction:[CCSequence actionOne:[CCJumpTo actionWithDuration:5 position:_player.position height:50 jumps:5] two:replaceSceneAction]];
}

- (void)opponentLastShot
{
    [_opponent runAction:[CCMoveBy actionWithDuration:2 position:ccp(50, 50)]];
}

- (void)opponentCelebrate
{
    [self removeChild:_opponent cleanup:YES];
    CCSprite * celebratingOpponent = [CCSprite spriteWithFile:@"opponent_victory.png"];
    celebratingOpponent.position = ccp(240, -150);
    [self addChild:celebratingOpponent z:2];
    
    GameOverScene * gameOverScene = [GameOverScene node];
    
    id replaceSceneAction = [CCCallFuncO actionWithTarget:[CCDirector sharedDirector] selector:@selector(replaceScene:) object:gameOverScene];
    
    [celebratingOpponent runAction:[CCSequence actionOne:[CCJumpTo actionWithDuration:5 position:celebratingOpponent.position height:50 jumps:5] two:replaceSceneAction]];
}

- (void)shakeTheBackground
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [background runAction:[CCRepeat actionWithAction:[CCSequence actions:[CCRotateTo actionWithDuration:0.05 angle:2], [CCRotateTo actionWithDuration:0.05 angle:-2], nil] times:3]];
}

- (void)redTheBackgroundWithTimes:(NSString *)times
{
    id tintToRed = [CCTintTo actionWithDuration:0.25 red:255 green:0 blue:0];
    id tintBack = [CCTintTo actionWithDuration:0.25 red:255 green:255 blue:255];
    [background runAction:[CCRepeat actionWithAction:[CCSequence actionOne:tintToRed two:tintBack] times:[times intValue]]];
}

- (void)playerBackToFightPositionAfterHitten
{
    _player.hitten = NO;
    if (_player.hp > 0) {
        if (_player.defense) {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"fighter_defense.png"]];
        } else {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"fighter.png"]];
        }
    }
    
}

- (void)opponentBackToFightPositionAfterHitten
{
    _opponent.hitten = NO;
    if (_opponent.hp > 0) {
        if (_opponent.defense) {
            [_opponent setTexture:[[CCTextureCache sharedTextureCache] addImage:@"opponent_defense.png"]];
        } else {
            [_opponent setTexture:[[CCTextureCache sharedTextureCache] addImage:@"opponent.png"]];
        }
    }
    
}



- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_player.defense&&!_player.hitten&&!_punching) {
        _punching = YES;
        
        // get winSize first
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        // get touch position in GL
        UITouch * touch = [touches anyObject];
        CGPoint touchLocation = [touch locationInView:[touch view]];
        touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
        
        [[SimpleAudioEngine sharedEngine] playEffect:@"swing.mp3"];
        
        // add attack
        CCSprite * attack = [CCSprite spriteWithFile:@"fist.png"];
        
        //  get initial attack position
        int minX = 60;
        int distanceX = 120;
        
        // get attack position according to opponent's position
        int attackPosition = 0;
        
        // detect which fist to hit
        if (touchLocation.x < winSize.width/2) {
            // left fist
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"fighter_leftFist.png"]];
            // get player position first
            float playerRotation = _player.rotation;
            if (playerRotation < -35) {
                attackPosition = 0;
            }
            else if (-35 < playerRotation && playerRotation < -15) {
                attackPosition = 0;
            }
            else if (-15 < playerRotation && playerRotation < 15) {
                attackPosition = 1;
            }
            else if (15 < playerRotation && playerRotation < 35) {
                attackPosition = 2;
            }
            else if (35 < playerRotation) {
                attackPosition = 3;
            }
        } else {
            // right fist
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"fighter_rightFist.png"]];
            // get player position first
            float playerRotation = _player.rotation;
            if (playerRotation < -35) {
                attackPosition = 0;
            }
            else if (-35 < playerRotation && playerRotation < -15) {
                attackPosition = 1;
            }
            else if (-15 < playerRotation && playerRotation < 15) {
                attackPosition = 2;
            }
            else if (15 < playerRotation && playerRotation < 35) {
                attackPosition = 3;
            }
            else if (35 < playerRotation) {
                attackPosition = 3;
            }
        }
        
        int actualX = minX + (distanceX * attackPosition);
        //NSLog(@"actual x %d", actualX);
        attack.position = ccp(actualX, 100);
        
        [self addChild:attack z:2];
        
        // attack action
        id actionPunch = [CCScaleTo actionWithDuration:0.2 scale:5.0f];
        id actionFade = [CCFadeIn actionWithDuration:0.2];
        id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(playerFinishAttack:)];
        [attack runAction:[CCSequence actions:[CCSpawn actionOne:actionPunch two:actionFade], actionMoveDone,nil]];
        
        // track each attack
        [_playerAttacks addObject:attack];
        
    }
}

- (void)playerFinishAttack:(id)sender
{
    CCSprite * attack = (CCSprite *)sender;
    [self removeChild:attack cleanup:YES];
    [_playerAttacks removeObject:attack];
    if (_opponent.hp > 0) {
        if (_player.defense) {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"fighter_defense.png"]];
        } else {
            [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"fighter.png"]];
        }
    }
    
}

#pragma mark UIAccelerometerDelegate
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    _player.rotation = -(acceleration.y * 50);
    
    if (!_player.hitten) {
        if (-0.5 < acceleration.y && acceleration.y < 0.5) {
            if (acceleration.z > -0.7 && _player.defense == NO) {
                [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"fighter_defense.png"]];
                _player.defense = YES;
            }
            else if (acceleration.z <= -0.7 && _player.defense == YES)
            {
                [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"fighter.png"]];
                _player.defense = NO;
            }
            
        }
        else {
            if (acceleration.z > -0.55 && _player.defense == NO) {
                [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"fighter_defense.png"]];
                _player.defense = YES;
            }
            else if (acceleration.z <= -0.55 && _player.defense == YES)
            {
                [_player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"fighter.png"]];
                _player.defense = NO;
            }
        }
    }
    
}


@end