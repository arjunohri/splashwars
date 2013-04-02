//
//  PhysicsSprite.mm
//  SplashWars
//
//  Created by sbhasin on 3/28/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


#import "PhysicsSprite.h"

// Needed PTM_RATIO
#import "HelloWorldLayer.h"
#import "SimpleAudioEngine.h"

#pragma mark - PhysicsSprite
@implementation PhysicsSprite

-(void) setPhysicsBody:(b2Body *)body
{
	body_ = body;
}

-(b2Body*)physicsBody
{
    return  body_;
}

// this method will only get called if the sprite is batched.
// return YES if the physics values (angles, position ) changed
// If you return NO, then nodeToParentTransform won't be called.
-(BOOL) dirty
{
	return YES;
}

// returns the transform matrix according the Chipmunk Body values
-(CGAffineTransform) nodeToParentTransform
{	
	b2Vec2 pos  = body_->GetPosition();
	
	float x = pos.x * PTM_RATIO;
	float y = pos.y * PTM_RATIO;
	
	if ( ignoreAnchorPointForPosition_ ) {
		x += anchorPointInPoints_.x;
		y += anchorPointInPoints_.y;
	}
	
	// Make matrix
	float radians = body_->GetAngle();
	float c = cosf(radians);
	float s = sinf(radians);
	
	if( ! CGPointEqualToPoint(anchorPointInPoints_, CGPointZero) ){
		x += c*-anchorPointInPoints_.x + -s*-anchorPointInPoints_.y;
		y += s*-anchorPointInPoints_.x + c*-anchorPointInPoints_.y;
	}
	
	// Rot, Translate Matrix
	transform_ = CGAffineTransformMake( c,  s,
									   -s,	c,
									   x,	y );	
	
	return transform_;
}

-(CGPoint)position
{
    b2Vec2 pos  = body_->GetPosition();
	
	float x = pos.x * PTM_RATIO;
	float y = pos.y * PTM_RATIO;
	
	if ( ignoreAnchorPointForPosition_ ) {
		x += anchorPointInPoints_.x;
		y += anchorPointInPoints_.y;
	}

    return ccp(x,y);
}

-(void) dealloc
{
	// 
	[super dealloc];
}

@end

@implementation BalloonSprite

-(void)createSplash
{
    CCParticleSystem* emitter = [CCParticleSystemQuad particleWithFile:@"BurstPipe.plist"];
    emitter.position = self.position;
	[self.parent addChild:emitter];
}

-(CGAffineTransform) nodeToParentTransform
{
    b2Vec2 pos  = body_->GetPosition();
	
	float x = pos.x * PTM_RATIO;
	float y = pos.y * PTM_RATIO;
	
	if ( ignoreAnchorPointForPosition_ ) {
		x += anchorPointInPoints_.x;
		y += anchorPointInPoints_.y;
	}
	
	// Make matrix
	//float radians = body_->GetAngle();
	//float c = cosf(radians);
	//float s = sinf(radians);
    float c= body_->GetLinearVelocity().x;
    float s = body_->GetLinearVelocity().y;
    
    float n = sqrtf(c*c + s*s);
    c/=n;
    s/=n;
	
	if( ! CGPointEqualToPoint(anchorPointInPoints_, CGPointZero) ){
		x += c*-anchorPointInPoints_.x + -s*-anchorPointInPoints_.y;
		y += s*-anchorPointInPoints_.x + c*-anchorPointInPoints_.y;
	}
	
    CGAffineTransform ts = CGAffineTransformMakeScale(self.scaleX, self.scaleY);
	// Rot, Translate Matrix
	transform_ = CGAffineTransformMake( c,  s,
									   -s,	c,
									   x,	y );
    
    transform_ = CGAffineTransformConcat(ts, transform_);
	
	return transform_;

    
    
    /*     transform_ = [super nodeToParentTransform];
     float c= body_->GetLinearVelocity().x;
    float s = body_->GetLinearVelocity().y;
    
    float n = sqrtf(c*c + s*s);
    c/=n;
    s/=n;
    
    // Rot, Translate Matrix
	transform_ = CGAffineTransformMake( c,  s,
									   -s,	c,
									   transform_.tx,	transform_.ty);
    return transform_;*/
}
@end

@implementation PlayerSprite

-(void)setupAnimationsForPlayer:(int)playerNum
{
    
    float w=50,h=75;
    
    for(int i=0;i<18;i++)
    {
        CGRect r = CGRectMake(i*w, (playerNum-1)*h, 50, 75);
        NSString *n = [NSString stringWithFormat:@"player%d_%d_%d",playerNum,i/2,i%2];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFrame:
         [CCSpriteFrame frameWithTextureFilename:@"char_faces_sprite_01.png" rect:r] name:n];
    }
    
    for(int i=0;i<9;i++)
    {
        NSString *n1 = [NSString stringWithFormat:@"player%d_%d_%d",playerNum,i,1];
        NSString *n2 = [NSString stringWithFormat:@"player%d_%d_%d",playerNum,i,0];
        idleAnim[i] = [[CCAnimation animationWithSpriteFrames:[NSArray arrayWithObjects:
                                                              [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:n1],
                                                              [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:n2],
                                                              nil] delay:0.2] retain];
    }
    
    
    w=75; h=75;
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:12];
    for(int i=0;i<12;i++)
    {
        CGRect r = CGRectMake(i*w, (playerNum-1)*h, 75, 75);
        NSString *n = [NSString stringWithFormat:@"player%d_hit_%d",playerNum,i];
        CCSpriteFrame* sf = [CCSpriteFrame frameWithTextureFilename:@"char_hit_sprite_01.png" rect:r];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFrame:sf name:n];
        
        [arr insertObject:sf atIndex:i];
    }
    
    hitAnim = [[CCAnimation animationWithSpriteFrames:arr delay:0.1] retain];
    
}

-(void)setupWithDrenchLevel:(float)level
{
    if(drenchLevelLabel)
    {
        if(drenchLevelLabel.parent)
            [drenchLevelLabel removeFromParentAndCleanup:YES];
        drenchLevelLabel = nil;
    }
    drenchLevelLabel = [CCLabelTTF labelWithString:@"0" dimensions:CGSizeMake(50,50) hAlignment:kCCTextAlignmentCenter fontName:@"Arial" fontSize:15];
    
    drenchLevelLabel.position = ccpAdd(self.position,ccp(0,self.contentSize.height/2));
    [self.parent addChild:drenchLevelLabel];
    
}

-(void)playIdleAnimation
{
    [self playAnimation:kAnimationIdle];
}

-(void)playAnimation:(PlayerAnimationType)animType
{
    switch(animType)
    {
        case kAnimationIdle:
        {
            int animNum = drenchLevel/10;
            if(animNum>8)
                animNum = 8;
            
            [self stopAllActions];
            [self runAction:[CCRepeatForever actionWithAction:
                                 [CCSequence actions:
                                    [CCAnimate actionWithAnimation:idleAnim[animNum]],
                                    [CCDelayTime actionWithDuration:3.0],
                                    nil]]];
            
        }
            break;
        case kAnimationHit:
        {
            [self stopAllActions];
            [self runAction:[CCSequence actions:
                              [CCAnimate actionWithAnimation:hitAnim],
                             [[CCAnimate actionWithAnimation:hitAnim]reverse],
                             [CCCallFuncN actionWithTarget:self selector:@selector(playIdleAnimation)],
                             nil]];
            
            CCLabelTTF * label = [CCLabelTTF labelWithString:@"+10" dimensions:CGSizeMake(50,50) hAlignment:kCCTextAlignmentCenter fontName:@"Arial" fontSize:12];
            
            label.position = drenchLevelLabel.position;
            [self.parent addChild:label];
            
            [label runAction:[CCSequence actions:
                              [CCSpawn actions:
                                  [CCMoveBy actionWithDuration:1.0 position:ccp(0,100)],
                                  [CCFadeOut actionWithDuration:1.0],nil],
                              [CCCallFuncND actionWithTarget:label selector:@selector(removeFromParentAndCleanup:)data:(void*)YES],
                              nil]];
        }
            break;
            
        default: {}break;
    }
}

-(void)hitByBalloon:(float)balloonSize
{
    //reduce health
    [self increaseDrenchLevelBy:balloonSize];
    
    //play hit animation
    [self playAnimation:kAnimationHit];
    
    int soundnum = arc4random()%2+1;
    NSString *sound = [NSString stringWithFormat:@"splash-hit-%d.mp3",soundnum];
    [[SimpleAudioEngine sharedEngine] playEffect:sound];
    
    soundnum = arc4random()%6+1;
    sound = [NSString stringWithFormat:@"hit-response-%d.mp3",soundnum];
    [[SimpleAudioEngine sharedEngine]  performSelector:@selector(playEffect:) withObject:sound afterDelay:0.5];
}

-(void)increaseDrenchLevelBy:(float)drenchValue
{
    drenchLevel += drenchValue;
    
    drenchLevel = min(drenchLevel, 100);
    [drenchLevelLabel setString:[NSString stringWithFormat:@"%d",(int)drenchLevel]];
    
    if(drenchLevel>=100)
    {
        //game Over
        [[HelloWorldLayer getInstance] playerLost:self];
        
        //play animation
        //[self playAnimation:kAnimationLost];
    }
}

@end
