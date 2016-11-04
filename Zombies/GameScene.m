//
//  GameScene.m
//  Zombies
//
//  Created by Pomme on 11/2/16.
//  Copyright © 2016 Yuanjie Xie. All rights reserved.
//

#import "GameScene.h"

static const uint32_t bulletCategory =  0x1 << 0;
static const uint32_t enemyCategory  =  0x1 << 1;


static const int MAX_ENEMIES = 15;

// Shooting Projectiles math equations
static inline CGPoint rwAdd(CGPoint a, CGPoint b) {
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint rwSub(CGPoint a, CGPoint b) {
    return CGPointMake(a.x - b.x, a.y - b.y);
}

static inline CGPoint rwMult(CGPoint a, float b) {
    return CGPointMake(a.x * b, a.y * b);
}

static inline float rwLength(CGPoint a) {
    return sqrtf(a.x * a.x + a.y * a.y);
}

// Makes a vector have a length of 1
static inline CGPoint rwNormalize(CGPoint a) {
    float length = rwLength(a);
    return CGPointMake(a.x / length, a.y / length);
}


@implementation GameScene {
    SKLabelNode *myLabel;
}




-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
      
        
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1 blue:0.9 alpha:0.9];
        //self.backgroundColor = [SKColor blackColor];

    }
    return self;
}


- (void)didMoveToView:(SKView *)view {
    // init
    self.enemyNumber = 0;
    self.score = 0;
    
    myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    
    // text label welcome setup
    myLabel.text = @"Your score: 0";
    myLabel.fontSize = 20;
    myLabel.fontColor = [UIColor redColor];
    myLabel.position = CGPointMake(self.size.width - 100.0, self.frame.size.height - 50.0);
    [self addChild:myLabel];
    
    
    self.home = [SKSpriteNode spriteNodeWithImageNamed:@"Home"];
    self.home.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    [self addChild:self.home];
    
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    self.physicsWorld.contactDelegate = self;
}


- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody, *secondBody;
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if ((firstBody.categoryBitMask & bulletCategory) != 0 &&
        (secondBody.categoryBitMask & enemyCategory) != 0)
    {
        [self bullet:(SKSpriteNode *) firstBody.node didCollideWithEnemy:(SKSpriteNode *) secondBody.node];
    }
}





- (void)addEnemy {
    
    // Create sprite
    SKSpriteNode * enemyNode = [SKSpriteNode spriteNodeWithImageNamed:@"enemy"];
    enemyNode.size = CGSizeMake(enemyNode.size.width / 2.0, enemyNode.size.height / 2.0);
    enemyNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:enemyNode.size center:CGPointMake(0.0, 0.0)];
    enemyNode.physicsBody.dynamic = YES;
    enemyNode.physicsBody.categoryBitMask = enemyCategory;
    enemyNode.physicsBody.contactTestBitMask = bulletCategory;
    enemyNode.physicsBody.usesPreciseCollisionDetection = NO;
    enemyNode.physicsBody.collisionBitMask = 0; // no rebound
    
    // Determine where enemy can show around home
    int homeHeightHalf = self.home.size.height / 2;
    int homeWidthHalf = self.home.size.width / 2;
    int enemyHeightHalf = enemyNode.size.height / 2;
    int enemyWidthHalf = enemyNode.size.width / 2;
    
    int minDis2 = (homeHeightHalf + enemyHeightHalf) * (homeHeightHalf + enemyHeightHalf) + (homeWidthHalf + enemyWidthHalf) * (homeWidthHalf + enemyWidthHalf);
    
    int centerX = self.frame.size.width / 2;
    int centerY = self.frame.size.height / 2;
    
    // Determine and check enemy location not overlap with home
    int actualX = 0;
    int actualY = 0;
    int dis2 = 0; // distanceBetweenHomeAndEnemy
    do {
        int minX = enemyNode.size.width / 2;
        int maxX = self.frame.size.width - enemyNode.size.width / 2;
        int rangeX = maxX - minX;
        
        int minY = enemyNode.size.height / 2;
        int maxY = self.frame.size.height - enemyNode.size.height / 2;
        int rangeY = maxY - minY;
        
        actualX = (arc4random() % rangeX) + minX;
        actualY = (arc4random() % rangeY) + minY;
        NSLog(@"%d",actualX);
        NSLog(@"%d",actualX);
        dis2 = (actualX - centerX) * (actualX - centerX) + (actualY - centerY) * (actualY - centerY);
        
    } while (dis2 < minDis2);
   
    enemyNode.position = CGPointMake(actualX, actualY);
    self.enemyNumber++;
    [self addChild:enemyNode];
    
}


- (void)update:(NSTimeInterval)currentTime {
    // determine how many enemies show up
    while (self.enemyNumber < MAX_ENEMIES) {
        [self addEnemy];
    }
    // update score
    NSString *scoreLabel = [NSString stringWithFormat:@"Your score: %d", self.score];
    myLabel.text = scoreLabel;
    
    // bullet speed increase vs time
    self.velocity += 10;
}




// touch end to fire bullet
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // shoot a bullet sprite on click in direction of click
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    // Set up initial location of bullet
    SKSpriteNode * bulletNode = nil;
    
    if (!bulletNode) {
        bulletNode = [SKSpriteNode spriteNodeWithImageNamed:@"bullet"];
        bulletNode.size = CGSizeMake(bulletNode.size.width / 4.0, bulletNode.size.height / 4.0);
        bulletNode.position = self.home.position;
        bulletNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:bulletNode.size.width / 2.0];
        bulletNode.physicsBody.dynamic = YES;
        bulletNode.physicsBody.categoryBitMask = bulletCategory;
        bulletNode.physicsBody.contactTestBitMask = enemyCategory;
        bulletNode.physicsBody.usesPreciseCollisionDetection = YES;
        bulletNode.physicsBody.collisionBitMask = 0;
        
        // Determine offset of location to projectile
        CGPoint offset = rwSub(location, bulletNode.position);
        [self addChild:bulletNode];
    
        // Get the direction of where to shoot
        CGPoint direction = rwNormalize(offset);
    
        // shoot far enough to be guaranteed off screen
        CGPoint shootAmount = rwMult(direction, 1000);
    
        // Add the shoot amount to the current position
        CGPoint realDest = rwAdd(shootAmount, bulletNode.position);
    
        // Create the actions
        self.velocity = 400.0/1.0;
        float realMoveDuration = self.size.width / self.velocity;
        SKAction * actionMove = [SKAction moveTo:realDest duration:realMoveDuration];
        SKAction * actionMoveDone = [SKAction removeFromParent];
        [bulletNode runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    }
}

// when bullet hit enemy, both of them remove from scene and number of enemy - 1;
- (void)bullet:(SKSpriteNode *)bullet didCollideWithEnemy: (SKSpriteNode *)enemy {
    
    // add effect to the bullet hitting enemy
    NSString *shotPath = [[NSBundle mainBundle] pathForResource:@"MyParticle" ofType:@"sks"];
    SKEmitterNode *shotEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:shotPath];
    shotEmitter.position = CGPointMake(0, 0);
    shotEmitter.zPosition = 2;
    shotEmitter.targetNode = self;
    SKAction *actionShotEffect = [SKAction runBlock:^{
        [enemy addChild:shotEmitter];
    }];
    
    // enemy got shot and bleed for 1s and dispear
    [enemy runAction:[SKAction sequence:@[actionShotEffect, [SKAction waitForDuration:0.5],[SKAction removeFromParent]]]];
    // bullet shot inside enemy and dispear
    [bullet removeFromParent];
    
    // total number of enemy minus one
    self.enemyNumber--;
    
    // user get one point for shot a zombie
    self.score++;
}

@end
