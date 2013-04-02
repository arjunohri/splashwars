//
//  PhysicsSprite.h
//  cocos2d-ios
//
//  Created by Ricardo Quesada on 1/4/12.
//  Copyright (c) 2012 Zynga. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"

#define MAX_BALLOON_SIZE 30.0f

@interface PhysicsSprite : CCSprite
{
	b2Body *body_;	// strong ref
}
-(void) setPhysicsBody:(b2Body*)body;
-(b2Body*)physicsBody;
@end

@interface BalloonSprite : PhysicsSprite
{
}

@property(nonatomic,assign) float balloonSize;
-(void)createSplash;

@end


typedef enum{
    kAnimationNone,
    kAnimationIdle,
    kAnimationHit,
    kAnimationWon,
    kAnimationLost
}PlayerAnimationType;

@interface PlayerSprite : PhysicsSprite
{
    float drenchLevel;
    CCLabelTTF* drenchLevelLabel;
    
    CCAnimation* idleAnim[9];
    CCAnimation* hitAnim;
    
}
-(void)setupAnimationsForPlayer:(int)playerNum;
-(void)setupWithDrenchLevel:(float)level;
-(void)playIdleAnimation;
-(void)playAnimation:(PlayerAnimationType)animType;
-(void)hitByBalloon:(float)balloonSize;
-(void)increaseDrenchLevelBy:(float)drenchValue;
@end