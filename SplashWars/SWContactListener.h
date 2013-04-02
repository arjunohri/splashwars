//
//  SWContactListener.h
//  SplashWars
//
//  Created by sbhasin on 3/29/13.
//
//

#ifndef __SplashWars__SWContactListener__
#define __SplashWars__SWContactListener__

#include <iostream>
#import "Box2D.h"

class SWContactListener : public b2ContactListener
{
public:
    void EndContact(b2Contact* contact);
    void BeginContact(b2Contact* contact);
};

#endif /* defined(__SplashWars__SWContactListener__) */
