//
//  HelloWorldLayer.mm
//  SplashWars
//
//  Created by sbhasin on 3/28/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

// Import the interfaces
#import "HelloWorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
#import "PhysicsSprite.h"
#import "GB2ShapeCache.h"
#import "CCLine.h"
#import "SimpleAudioEngine.h"

enum {
	kTagParentNode = 1,
};


#pragma mark - HelloWorldLayer

@interface HelloWorldLayer()
-(void) initPhysicsWithWorldSize:(CGSize)worldSize;
-(BalloonSprite*) addNewSpriteAtPosition:(CGPoint)p  applyImpulse:(b2Vec2)impulse size:(float)bSize;
-(void) createMenu;
@end

@implementation HelloWorldLayer

static HelloWorldLayer* _hWorldLayer = nil;

+(CCScene *) scene
{
    if(!_hWorldLayer)
    {
        // 'scene' is an autorelease object.
        CCScene *scene = [CCScene node];
        
        // 'layer' is an autorelease object.
        HelloWorldLayer *layer = [HelloWorldLayer node];
        layer.parentScene = scene;
        
        // add layer as a child to scene
        [scene addChild: layer];
        _hWorldLayer = layer;
        
        // return the scene
        return scene;
    }
    else
    {
       return _hWorldLayer.parentScene;
    }
}

+(HelloWorldLayer*) getInstance
{
    return _hWorldLayer;
}

-(id) init
{
	if( (self=[super init])) {
		
		// enable events
		
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;
        
        physicsBodiesToBeDeleted = [[NSMutableArray alloc] init];
        p1Balloons = [[NSMutableArray alloc] init];
        p2Balloons = [[NSMutableArray alloc] init];
        
		// create reset button
		//[self createMenu];
        
        if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
            background = [CCSprite spriteWithFile:@"bkg_game_02.png"];
            //background.rotation = 90;
        }
        
        //CGSize size = background.contentSize;//[[CCDirector sharedDirector] winSize];
        background.anchorPoint = ccp(0,0);
        background.position = ccp(0,0);
        
        // add the label as a child to this Layer
        [self addChild: background];
        
        // init physics
		[self initPhysicsWithWorldSize:background.contentSize];
		
//#if 1
//		// Use batch node. Faster
//		CCSpriteBatchNode *parent = [CCSpriteBatchNode batchNodeWithFile:@"blocks.png" capacity:100];
//		spriteTexture_ = [parent texture];
//#else
//		// doesn't use batch node. Slower
//		spriteTexture_ = [[CCTextureCache sharedTextureCache] addImage:@"blocks.png"];
//		CCNode *parent = [CCNode node];
//#endif
//		[self addChild:parent z:0 tag:kTagParentNode];
		

		[self setPlayer1At:ccp(25,125) player2At:ccp(1000,125)];
        [self setShootingPointForPlayer1At:ccp(100,100) player2At:ccp(925,100)];
        
        
        whichPlayersTurn = kPlayer2;
        numBaloonsLeftInCurrentTurn = -1;
        [self checkAndSwitchPlayersTurn];
        
        isInScrollingMode = NO;
        shootingAreaHitRadius = 50;
        maximumShootingStretch = 50;
        
        CGSize s = [CCDirector sharedDirector].winSize;
        hud = [CCLayer node];
        hud.position = ccp(0,0);
        
        names = [CCSprite spriteWithFile:@"players.png"];
        names.anchorPoint = ccp(0,0);
        names.position = ccp(5,5);
        
        windMarker = [CCSprite spriteWithFile:@"windsock.png"];
        windMarker.anchorPoint = ccp(0,0);
        windMarker.position = ccpSub(ccp(s.width/2,10),ccp(windMarker.contentSize.width,0));
       
        [hud addChild:names];
        [hud addChild:windMarker];
        [self addChild:hud];
        
        
		[self scheduleUpdate];
        [self loadSounds];
	}
	return self;
}

-(void)loadSounds
{
    [SimpleAudioEngine sharedEngine].effectsVolume =1.0;
    [SimpleAudioEngine sharedEngine].backgroundMusicVolume = 1.0;
    [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"loading_music.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"hit-response-1.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"hit-response-2.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"hit-response-3.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"hit-response-4.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"hit-response-5.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"hit-response-6.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"launch-1.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"launch-2.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"launch-3.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"launch-big.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"splash-1.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"splash-hit-1.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"splash-hit-2.mp3"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"turn-change.mp3"];
}

-(void)balloonDidBurst:(BalloonSprite*)bal
{
    [self addPhysicsBodyToBeDeleted:bal.physicsBody];
    [bal createSplash];
    [bal removeFromParentAndCleanup:YES];
    
    [self performSelector:@selector(checkAndSwitchPlayersTurn) withObject:nil afterDelay:0.2];
    
    NSString *sound = [NSString stringWithFormat:@"splash-1.mp3"];
    [[SimpleAudioEngine sharedEngine] playEffect:sound];
}

-(void)addPhysicsBodyToBeDeleted:(b2Body*)b
{
    [physicsBodiesToBeDeleted addObject:[NSValue valueWithPointer:b]];
}

-(void)setPlayer1At:(CGPoint)player1Pos player2At:(CGPoint)player2Pos
{
    p1Pos = player1Pos;
    p2Pos = player2Pos;
    
    p1Sprite = [PlayerSprite spriteWithFile:@"char_03.png"];
    [p1Sprite setupAnimationsForPlayer:1];
    //p1Sprite.anchorPoint = ccp(0, 0);
    p1Sprite.position= p1Pos;
    [background addChild: p1Sprite];
    
    // Define the dynamic body.
	//Set up a 1m squared box in the physics world
	b2BodyDef bodyDef;
	bodyDef.type = b2_staticBody;
	bodyDef.position.Set(p1Pos.x/PTM_RATIO, p1Pos.y/PTM_RATIO);
	b2Body *body = world->CreateBody(&bodyDef);
	
	// Define another box shape for our dynamic body.
	b2PolygonShape dynamicBox;
	dynamicBox.SetAsBox(p1Sprite.contentSize.width/(PTM_RATIO*2), p1Sprite.contentSize.height*2/(PTM_RATIO*2));//These are mid points for our 1m box
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.3f;
	body->CreateFixture(&fixtureDef);
    body->SetUserData(p1Sprite);
	[p1Sprite setPhysicsBody:body];

    //__________
    
    p2Sprite = [PlayerSprite spriteWithFile:@"char_07.png"];
    [p2Sprite setupAnimationsForPlayer:2];
    p2Sprite.position= p2Pos;
    [background addChild: p2Sprite];
    
    // Define the dynamic body.
	//Set up a 1m squared box in the physics world
	b2BodyDef bodyDef2;
	bodyDef2.type = b2_staticBody;
	bodyDef2.position.Set(p2Pos.x/PTM_RATIO, p2Pos.y/PTM_RATIO);
	b2Body *body2 = world->CreateBody(&bodyDef2);
	
	// Define another box shape for our dynamic body.
	b2PolygonShape dynamicBox2;
	dynamicBox2.SetAsBox(p2Sprite.contentSize.width/(PTM_RATIO*2), p2Sprite.contentSize.height*2/(PTM_RATIO*2));
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef2;
	fixtureDef2.shape = &dynamicBox2;
	fixtureDef2.density = 1.0f;
	fixtureDef2.friction = 0.3f;
	body2->CreateFixture(&fixtureDef2);
    body2->SetUserData(p2Sprite);
	[p2Sprite setPhysicsBody:body2];
    
    
    [p1Sprite setupWithDrenchLevel:0];
    [p2Sprite setupWithDrenchLevel:0];
    
    [p1Sprite playAnimation:kAnimationIdle];
    [p2Sprite playAnimation:kAnimationIdle];
    
}

-(void)setShootingPointForPlayer1At:(CGPoint)player1ShootingPos player2At:(CGPoint)player2ShootingPos
{
    p1ShootingPos = player1ShootingPos;
    p2ShootingPos = player2ShootingPos;
    
    
    p1ShootAreaA = [CCSprite spriteWithFile:@"stick_left_a.png"];
    p1ShootAreaA.position= p1ShootingPos;
    [background addChild: p1ShootAreaA z:100];
    
    p1ShootAreaB = [CCSprite spriteWithFile:@"stick_left_b.png"];
    p1ShootAreaB.position= p1ShootingPos;
    [background addChild: p1ShootAreaB];
    
    p2ShootAreaA = [CCSprite spriteWithFile:@"stick_right_a.png"];
    p2ShootAreaA.position= p2ShootingPos;
    [background addChild: p2ShootAreaA z:100];
    
    p2ShootAreaB = [CCSprite spriteWithFile:@"stick_right_b.png"];
    p2ShootAreaB.position= p2ShootingPos;
    [background addChild: p2ShootAreaB];
}


-(void) dealloc
{
	delete world;
	world = NULL;
    
    delete contactListener;
    contactListener = NULL;
	
	delete m_debugDraw;
	m_debugDraw = NULL;
    
    [physicsBodiesToBeDeleted release];
    [p1Balloons removeAllObjects];
    [p2Balloons removeAllObjects];
    [p1Balloons release];
    [p2Balloons release];
	
	[super dealloc];
}	

-(void) createMenu
{
    CGSize s = [CCDirector sharedDirector].winSize;
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"Tap screen" fontName:@"Marker Felt" fontSize:32];
    //self addChild:label z:0];
    [label setColor:ccc3(0,0,255)];
    label.position = ccp( s.width/2, s.height-50);
    
	// Default font size will be 22 points.
	[CCMenuItemFont setFontSize:22];
	
	// Reset Button
	CCMenuItemLabel *reset = [CCMenuItemFont itemWithString:@"Reset" block:^(id sender){
		[[CCDirector sharedDirector] replaceScene: [HelloWorldLayer scene]];
	}];
	
	// Achievement Menu Item using blocks
	CCMenuItem *itemAchievement = [CCMenuItemFont itemWithString:@"Achievements" block:^(id sender) {
		
		
		GKAchievementViewController *achivementViewController = [[GKAchievementViewController alloc] init];
		achivementViewController.achievementDelegate = self;
		
		AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
		
		[[app navController] presentModalViewController:achivementViewController animated:YES];
		
		[achivementViewController release];
	}];
	
	// Leaderboard Menu Item using blocks
	CCMenuItem *itemLeaderboard = [CCMenuItemFont itemWithString:@"Leaderboard" block:^(id sender) {
		
		
		GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
		leaderboardViewController.leaderboardDelegate = self;
		
		AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
		
		[[app navController] presentModalViewController:leaderboardViewController animated:YES];
		
		[leaderboardViewController release];
	}];
	
	CCMenu *menu = [CCMenu menuWithItems:itemAchievement, itemLeaderboard, reset, nil];
	
	[menu alignItemsVertically];
	
	CGSize size = [[CCDirector sharedDirector] winSize];
	[menu setPosition:ccp( size.width/2, size.height/2)];
	
	
	//[self addChild: menu z:-1];
}

-(void) initPhysicsWithWorldSize:(CGSize)worldSize
{
	
	CGSize s = worldSize;//[[CCDirector sharedDirector] winSize];
	
	b2Vec2 gravity;
	gravity.Set(0.0f, -10.0f);
	world = new b2World(gravity);
	
	
	// Do we want to let bodies sleep?
	world->SetAllowSleeping(true);
	
	world->SetContinuousPhysics(true);
	
	m_debugDraw = new GLESDebugDraw( PTM_RATIO );
	world->SetDebugDraw(m_debugDraw);
	
	uint32 flags = 0;
	flags += b2Draw::e_shapeBit;
	//		flags += b2Draw::e_jointBit;
	//		flags += b2Draw::e_aabbBit;
	//		flags += b2Draw::e_pairBit;
	//		flags += b2Draw::e_centerOfMassBit;
	m_debugDraw->SetFlags(flags);		
	
	
	// Define the ground body.
	b2BodyDef groundBodyDef;
	groundBodyDef.position.Set(0, 0); // bottom-left corner
	
	// Call the body factory which allocates memory for the ground body
	// from a pool and creates the ground box shape (also from a pool).
	// The body is also added to the world.
	b2Body* groundBody = world->CreateBody(&groundBodyDef);
	
	// Define the ground box shape.
	b2EdgeShape groundBox;		
	
	// bottom
	
	groundBox.Set(b2Vec2(0,0), b2Vec2(s.width/PTM_RATIO,0));
	groundBody->CreateFixture(&groundBox,0);
	
	// top
	//groundBox.Set(b2Vec2(0,s.height/PTM_RATIO), b2Vec2(s.width/PTM_RATIO,s.height/PTM_RATIO));
	//groundBody->CreateFixture(&groundBox,0);
	
	// left
	groundBox.Set(b2Vec2(0,s.height*100/PTM_RATIO), b2Vec2(0,0));
	groundBody->CreateFixture(&groundBox,0);
	
	// right
	groundBox.Set(b2Vec2(s.width/PTM_RATIO,s.height*100/PTM_RATIO), b2Vec2(s.width/PTM_RATIO,0));
	groundBody->CreateFixture(&groundBox,0);
    
    
    
    //-------------- add physics body to background --------------
    
    [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"bkg_physics_bodies_all.plist"];
    
    
    
    // Define the dynamic body.
	//Set up a 1m squared box in the physics world
	b2BodyDef bodyDef1;
	bodyDef1.type = b2_staticBody;
	bodyDef1.position.Set(0, 0);
	leftMound = world->CreateBody(&bodyDef1);
    [[GB2ShapeCache sharedShapeCache] addFixturesToBody:leftMound forShapeName:@"bkg_game_01"];
    
    b2BodyDef bodyDef2;
	bodyDef2.type = b2_staticBody;
	bodyDef2.position.Set(0, 0);
	middleMound = world->CreateBody(&bodyDef2);
    [[GB2ShapeCache sharedShapeCache] addFixturesToBody:middleMound forShapeName:@"bkg_game_02"];
    
    b2BodyDef bodyDef3;
	bodyDef3.type = b2_staticBody;
	bodyDef3.position.Set(0, 0);
	rightMound = world->CreateBody(&bodyDef3);
    [[GB2ShapeCache sharedShapeCache] addFixturesToBody:rightMound forShapeName:@"bkg_game_03"];
    
    
    
    //-------------- add contact listener --------------
    contactListener = new SWContactListener();
    world->SetContactListener(contactListener);
}

-(void) draw
{
	//
	// IMPORTANT:
	// This is only for debug purposes
	// It is recommend to disable it
	//
	[super draw];
	
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
	
	kmGLPushMatrix();
	
	world->DrawDebugData();	
	
	kmGLPopMatrix();
}

-(BalloonSprite*) addNewSpriteAtPosition:(CGPoint)p applyImpulse:(b2Vec2)impulse size:(float)bSize
{
	CCLOG(@"Add sprite %0.2f x %02.f",p.x,p.y);
	BalloonSprite *sprite = [BalloonSprite spriteWithTexture:flingSprite.texture];
    
    sprite.scale = bSize/MAX_BALLOON_SIZE;
    sprite.balloonSize = bSize;
	[background addChild:sprite];
	sprite.position = ccp( p.x, p.y);
	
	// Define the dynamic body.
	//Set up a 1m squared box in the physics world
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	b2Body *body = world->CreateBody(&bodyDef);
	
	// Define another box shape for our dynamic body.
    b2CircleShape circle;
    circle.m_radius = 16.0/PTM_RATIO;
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &circle;
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.3f;
	body->CreateFixture(&fixtureDef);
    
	[sprite setPhysicsBody:body];
    
    body->SetUserData(sprite);
    
    //body->ApplyForceToCenter(b2Vec2(10, 0));
    body->ApplyLinearImpulse(impulse, body->GetPosition());
    
    
    //Make the screen follow the baloon
    [background stopActionByTag:kTag_CCFollowAction];
    
    CCAction* follow = [CCFollow actionWithTarget:sprite worldBoundary:CGRectMake(0, 0, background.contentSize.width, background.contentSize.height)];
    follow.tag = kTag_CCFollowAction;
    [background runAction:follow];
    
    
    int soundnum = arc4random()%3 +1;
    NSString *sound = [NSString stringWithFormat:@"launch-%d.mp3",soundnum];
    [[SimpleAudioEngine sharedEngine] playEffect:sound];
    
    return sprite;
}

-(void) update: (ccTime) dt
{
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(dt, velocityIterations, positionIterations);
    
    //delete physics bodies which need to be deleted
    for(id obj in physicsBodiesToBeDeleted)
    {
        b2Body* b = (b2Body*)[obj pointerValue];
        world->DestroyBody(b);
    }
    
    [physicsBodiesToBeDeleted removeAllObjects];
}


- (CGPoint)boundLayerPos:(CGPoint)newPos
{
    CGSize winSize = [CCDirector sharedDirector].winSize;
    CGPoint retval = newPos;
    retval.x = MIN(retval.x, 0);
    retval.x = MAX(retval.x, -background.contentSize.width+winSize.width);
    retval.y = background.position.y;
    return retval;
}

- (void)panForTranslation:(CGPoint)translation
{
    CGPoint newPos = ccpAdd(background.position, translation);
    background.position = [self boundLayerPos:newPos];
   // hud.position = ccpSub(ccp(0,0),background.position);
}

-(float)distanceBetween:(CGPoint)p1 : (CGPoint) p2
{
    float xdiff = p1.x - p2.x;
    float ydiff = p1.y - p2.y;
    return sqrtf(xdiff*xdiff + ydiff*ydiff);
}

-(void)tickBalloonSpriteSize:(ccTime)dt
{
    flingSpriteBalloonSize+= dt/0.5f;
    if(flingSpriteBalloonSize>MAX_BALLOON_SIZE)
    {
        flingSpriteBalloonSize = MAX_BALLOON_SIZE;
        [self unschedule:@selector(tickBalloonSpriteSize:)];
        BalloonSprite* bal = [self addNewSpriteAtPosition: flingSprite.position applyImpulse:b2Vec2(0,0) size:flingSpriteBalloonSize];
        //numBaloonsLeftInCurrentTurn--;
        [self cleanupFlingSpriteAndRubberbands];
        
        //burst the balloon and impact current player
        bal.physicsBody->SetActive(NO);
        [self balloonDidBurst:bal];
        if(whichPlayersTurn == kPlayer1)
            [p1Sprite hitByBalloon:flingSpriteBalloonSize];
        else
            [p2Sprite hitByBalloon:flingSpriteBalloonSize];
        
        isGoingToShoot = NO;
        isInScrollingMode = NO;
        return;
    }
    
    flingSprite.scale = flingSpriteBalloonSize/MAX_BALLOON_SIZE;
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL: location];
    location = [background convertToNodeSpace:location];
    
    isInScrollingMode = YES;
    //[background stopActionByTag:kTag_CCFollowAction];
    //find distance between touch location and shooting centre
    
    isGoingToShoot = NO;
    if([self distanceBetween:p1ShootingPos :location] < shootingAreaHitRadius && whichPlayersTurn==kPlayer1)
    {
        isGoingToShoot = YES;
        line1 = [CCLine node];
        line2 = [CCLine node];
        
        // do custom left side shooting stuff
        
        flingStartPosition = p1ShootingPos;
        line1.from = ccpAdd(p1ShootingPos, ccp(4,23));
        line2.from = ccpAdd(p1ShootingPos, ccp(-9,17));
        
    }
    else if([self distanceBetween:p2ShootingPos :location] < shootingAreaHitRadius  && whichPlayersTurn==kPlayer2)
    {
        isGoingToShoot = YES;
        line1 = [CCLine node];
        line2 = [CCLine node];
        
        // do custom right side shooting stuff
        
        flingStartPosition = p2ShootingPos;
        line1.from = ccpAdd(p2ShootingPos, ccp(4,24));
        line2.from = ccpAdd(p2ShootingPos, ccp(-8,18));
    }
    
    if(isGoingToShoot)
    {
        isInScrollingMode = NO;
        flingSprite = [self consumeBalloon];
        
        //flingSprite = [CCSprite spriteWithFile:@"balloon_blue.png"];
        float ang = -180*atan((flingStartPosition.y - location.y)/(flingStartPosition.x - location.x)) / 3.14 ;
        if(flingStartPosition.x < location.x)
            ang = ang +180;
        flingSprite.rotation = ang;
        flingSprite.position = flingStartPosition;
        flingSprite.scale = 0.5;
        flingSpriteBalloonSize = 15;
        [self schedule:@selector(tickBalloonSpriteSize:)];
        
        
       
        line1.to = location;
        line1.thickness = 6.0f;
        [background addChild:line1 z: 40];
        
        [background addChild:flingSprite z:50];
        
        
        
        line2.to = location;
        line2.thickness = 6.0f;
        [background addChild:line2 z: 60];
    }
    
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
	UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView: [touch view]];
	location = [[CCDirector sharedDirector] convertToGL: location];
    location = [background convertToNodeSpace:location];
    
    
    CGPoint touchLocation = [background convertTouchToNodeSpace:touch];
    
    if(isInScrollingMode)
    {
        CGPoint oldTouchLocation = [touch previousLocationInView:touch.view];
        oldTouchLocation = [[CCDirector sharedDirector] convertToGL:oldTouchLocation];
        oldTouchLocation = [background convertToNodeSpace:oldTouchLocation];
        
        CGPoint translation = ccpSub(touchLocation, oldTouchLocation);
        [self panForTranslation:translation];
    }
    else
    {
        if([self distanceBetween:p1ShootingPos :location]>maximumShootingStretch && whichPlayersTurn==kPlayer1)
        {
            return;
        }
        else if([self distanceBetween:p2ShootingPos :location]>maximumShootingStretch && whichPlayersTurn==kPlayer2)
        {
            return;
        }
        
        line1.to = location;
        line2.to = location;
        flingSprite.position = location;
        float ang = -180*atan((flingStartPosition.y - location.y)/(flingStartPosition.x - location.x)) / 3.14 ;
        if(flingStartPosition.x < location.x)
            ang = ang +180;
        flingSprite.rotation = ang;
    }
    
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//Add a new body/atlas sprite at the touched location
	UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL: location];
    location = [background convertToNodeSpace:location];
    
    if(isGoingToShoot)
    {
        [self unschedule:@selector(tickBalloonSpriteSize:)];
        
        float divFactor = 3.0;
        b2Vec2 impulse = b2Vec2((flingStartPosition.x - location.x)/divFactor, (flingStartPosition.y - location.y)/divFactor);

        [self addNewSpriteAtPosition: location applyImpulse:impulse size:flingSpriteBalloonSize];
        
        //numBaloonsLeftInCurrentTurn--;
        
        [self cleanupFlingSpriteAndRubberbands];
        
    }
    
    isGoingToShoot = NO;
    isInScrollingMode = NO;
}

-(void)cleanupFlingSpriteAndRubberbands
{
    [flingSprite removeFromParentAndCleanup:YES];
    flingSprite = nil;
    
    [line1 removeFromParentAndCleanup:YES];
    line1 = nil;
    [line2 removeFromParentAndCleanup:YES];
    line2 = nil;
}

-(CCSprite*)consumeBalloon
{
    CCSprite* b;
    if(whichPlayersTurn == kPlayer1)
    {
        b = [[p1Balloons lastObject] retain];
        [b removeFromParentAndCleanup:YES];
        [p1Balloons removeObject:b];
    }
    else
    {
        b = [[p2Balloons lastObject] retain];
        [b removeFromParentAndCleanup:YES];
        [p2Balloons removeObject:b];
    }
    
    numBaloonsLeftInCurrentTurn--;
    return b;
}


-(void) checkAndSwitchPlayersTurn
{
    if(numBaloonsLeftInCurrentTurn<=0)
    {
        NSString *str;
        if(whichPlayersTurn ==kPlayer1)
        {
            whichPlayersTurn = kPlayer2;
            p1Sprite.physicsBody->SetActive(YES);
            p2Sprite.physicsBody->SetActive(NO);
            leftMound->SetActive(YES);
            rightMound->SetActive(NO);
            str=@"yourturn_arjun.png";
            
            for(int i=0;i<3;i++)
            {
                int num = arc4random()%4 + 1;
                CCSprite* b = [CCSprite spriteWithFile:[NSString stringWithFormat:@"balloon%d.png",num]];
                [p2Balloons addObject:b];
                b.scale = 0.5;
                b.rotation = arc4random()%180;
                b.position = ccpAdd(p2Sprite.position,ccp((i-1)*20,- p2Sprite.contentSize.height/2 -20));
                [p2Sprite.parent addChild:b];
            }
        }else{
            whichPlayersTurn = kPlayer1;
            p1Sprite.physicsBody->SetActive(NO);
            p2Sprite.physicsBody->SetActive(YES);
            leftMound->SetActive(NO);
            rightMound->SetActive(YES);
            str=@"yourturn_whitney.png";
            
            for(int i=0;i<3;i++)
            {
                int num = arc4random()%4 + 1;
                CCSprite* b = [CCSprite spriteWithFile:[NSString stringWithFormat:@"balloon%d.png",num]];
                [p1Balloons addObject:b];
                b.scale = 0.5;
                b.rotation = arc4random()%180;
                b.position = ccpAdd(p1Sprite.position,ccp((i-1)*20,-p1Sprite.contentSize.height/2 -20));
                [p1Sprite.parent addChild:b];
            }
        }
        numBaloonsLeftInCurrentTurn = 3;
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        //CCLabelTTF* label = [CCLabelTTF labelWithString:str dimensions:CGSizeMake(100, 100) hAlignment:kCCTextAlignmentCenter fontName:@"Arial" fontSize:30];
        
        CCSprite* turn = [CCSprite spriteWithFile:str];
        turn.scale = 0.1;
        turn.position = ccp(winSize.width/2,winSize.height/2);
        
        [turn runAction:[CCSequence actions:
                          [CCScaleTo actionWithDuration:0.2 scale:1.0],
                          [CCDelayTime actionWithDuration:1.0],
                          [CCFadeOut actionWithDuration:0.5],
                          [CCCallFuncND actionWithTarget:turn selector:@selector(removeFromParentAndCleanup:) data:(void*)YES],
                          nil]];
        
        [self addChild:turn z:200];
        
        NSString *sound = [NSString stringWithFormat:@"turn-change.mp3"];
        [[SimpleAudioEngine sharedEngine] playEffect:sound];
    }
}

-(void)playerLost:(PlayerSprite*)p
{
    CGSize s = [CCDirector sharedDirector].winSize;
    CCSprite* winScreen = [CCSprite spriteWithFile:@"winner.png"];
    winScreen.position = ccp(s.width/2,s.height/2);
    winScreen.scale = 0.1;
    [winScreen runAction:[CCScaleTo actionWithDuration:0.2 scale:1.0]];
    [self addChild:winScreen z:300];
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

@end
