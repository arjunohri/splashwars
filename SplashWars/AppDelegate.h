//
//  AppDelegate.h
//  SplashWars
//
//  Created by sbhasin on 3/28/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"


#define appDelegate (AppController *)[[UIApplication sharedApplication] delegate]

@class MainViewController;
@class LoginViewController;
@class GamesListViewController;

@interface AppController : NSObject <UIApplicationDelegate, CCDirectorDelegate>
{
	UIWindow *window_;
	UINavigationController *navController_;
	
	CCDirectorIOS	*director_;							// weak ref
}

@property (nonatomic, retain) UIWindow *window;
@property (readonly) UINavigationController *navController;
@property (strong, nonatomic) MainViewController *mainViewController;
@property (strong, nonatomic) LoginViewController *loginViewController;
@property (strong, nonatomic) GamesListViewController *gamesListViewController;
@property (readonly) CCDirectorIOS *director;

- (void)setupParse:(NSDictionary *)launchOptions;
- (void)fbLoginSuccessful;

@end
