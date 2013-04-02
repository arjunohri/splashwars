//
//  HelloWorldLayer.h
//  SplashWars
//
//  Created by sbhasin on 3/28/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "SWContactListener.h"

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32
#define kTag_CCFollowAction 768

@class PhysicsSprite;
@class PlayerSprite;
@class BalloonSprite;
@class CCLine;

typedef enum{
    kPlayer1=0,
    kPlayer2=1
}PlayersTurn;


// HelloWorldLayer
@interface HelloWorldLayer : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>
{
    CCSprite *background;
	CCTexture2D *spriteTexture_;	// weak ref
	b2World* world;					// strong ref
	GLESDebugDraw *m_debugDraw;		// strong ref
    SWContactListener* contactListener;
    
    CCLayer* hud;
    CCSprite* names, *windMarker;
    
    CGPoint flingStartPosition;
    CCSprite* flingLineSprite;
    CCSprite* flingSprite;
    
    CGPoint p1Pos, p2Pos;
    PlayerSprite *p1Sprite, *p2Sprite;
    
    CGPoint p1ShootingPos, p2ShootingPos;
    CCSprite *p1ShootAreaA,*p1ShootAreaB, *p2ShootAreaA,*p2ShootAreaB;
    float shootingAreaHitRadius,maximumShootingStretch;

    NSMutableArray* physicsBodiesToBeDeleted;
    PlayersTurn whichPlayersTurn;
    int numBaloonsLeftInCurrentTurn;
    
    b2Body *leftMound,*middleMound,*rightMound;
    
    CCLine* line1,*line2;
    
    //these 2 should contradict each other
    BOOL isInScrollingMode;
    BOOL isGoingToShoot;
    
}

@property(nonatomic,retain) CCScene* parentScene;
@property(readonly) b2World* physicsWorld;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
+(HelloWorldLayer*) getInstance;

-(void)loadSounds;
-(void)balloonDidBurst:(BalloonSprite*)bal;
-(void)addPhysicsBodyToBeDeleted:(b2Body*)b;
-(void)checkAndSwitchPlayersTurn;

-(void)setPlayer1At:(CGPoint)player1Pos player2At:(CGPoint)player2Pos;
-(void)setShootingPointForPlayer1At:(CGPoint)player1ShootingPos player2At:(CGPoint)player2ShootingPos;

-(void)playerLost:(PlayerSprite*)p;



@end
