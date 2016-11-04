//
//  GameScene.h
//  Zombies
//
//  Created by Pomme on 11/2/16.
//  Copyright © 2016 Yuanjie Xie. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameScene : SKScene <SKPhysicsContactDelegate>

@property (nonatomic) SKSpriteNode *home;

@property (nonatomic) int enemyNumber;

@property (nonatomic) float velocity;

@property (nonatomic) int score;

@end
