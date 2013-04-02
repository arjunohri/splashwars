//
//  SWContactListener.mm
//  SplashWars
//
//  Created by sbhasin on 3/29/13.
//
//

#include "SWContactListener.h"

#import "Box2D.h"
#import "cocos2d.h"
#import "PhysicsSprite.h"
#import "HelloWorldLayer.h"

void SWContactListener::EndContact(b2Contact* contact)
{
    
}

void SWContactListener::BeginContact(b2Contact* contact)
{
    
    b2Body *b1 = contact->GetFixtureA()->GetBody();
    b2Body *b2 = contact->GetFixtureB()->GetBody();
    
    id s1 = (id)b1->GetUserData();
    id s2 = (id)b2->GetUserData();

    
    if([s1 isKindOfClass:[BalloonSprite class]])
    {
        
        [[HelloWorldLayer getInstance] balloonDidBurst:s1];
        
        if([s2 isKindOfClass:[PlayerSprite class]])
        {
            [(PlayerSprite*)s2 hitByBalloon:((BalloonSprite*)s1).balloonSize];
        }
    }
    
    if([s2 isKindOfClass:[BalloonSprite class]])
    {
        [[HelloWorldLayer getInstance] balloonDidBurst:s2];
        
        if([s1 isKindOfClass:[PlayerSprite class]])
        {
            [(PlayerSprite*)s1 hitByBalloon:((BalloonSprite*)s2).balloonSize];
        }
    }
}
