//
//  CCLine.m
//  SplashWars
//
//  Created by sbhasin on 4/1/13.
//
//

#import "CCLine.h"
#import "cocos2d.h"

@implementation CCLine

-(void)draw{
    //glColor4f(0.8, 1.0, 0.76, 1.0);
	glLineWidth(self.thickness);
	ccDrawLine(self.from, self.to);
}
@end
