//
//  AppDelegate.mm
//  SplashWars
//
//  Created by sbhasin on 3/28/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

#import "cocos2d.h"

#import "AppDelegate.h"
#import "IntroLayer.h"
#import <Parse/Parse.h>
#import "MainViewController.h"
#import "LoginViewController.h"
#import "GamesListViewController.h"
#import "DataManager.h"

@implementation AppController

@synthesize window=window_,
            navController=navController_,
            director=director_;

// Method added to AppDelegate to support Single Signon for Facebook SDK
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [PFFacebookUtils handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [PFFacebookUtils handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    [self setupParse:launchOptions];
    
	// Create the main window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.mainViewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    self.gamesListViewController = [[GamesListViewController alloc] initWithNibName:@"GamesListViewController" bundle:nil];
    
    // Create a Navigation Controller with the Director
	//navController_ = [[UINavigationController alloc] initWithRootViewController:director_];
	
    navController_ = [[UINavigationController alloc] init];
    navController_.navigationBarHidden = YES;
	
	// set the Navigation Controller as the root view controller
    //	[window_ addSubview:navController_.view];	// Generates flicker.
	[window_ setRootViewController:navController_];

    //[self checkFacebookLogin];
    
    [navController_ pushViewController:self.gamesListViewController animated:NO];
    
	// make main window visible
	[window_ makeKeyAndVisible];
	
	return YES;
}

- (void)setupParse:(NSDictionary *)launchOptions
{
    //  Parse setup code
    [Parse setApplicationId:@"XJ26jAFZAhaVjU9NV3mBG1jiumaH4GuLpQW2txoW"
                  clientKey:@"pMjakDixzfqSL8OX8KlfwnzwxU1x8XCAisASlAlb"];
    
    //  Parse: track statistics around application open
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    //  Initialize Facebook within Parse
    [PFFacebookUtils initializeFacebook];
}

- (void)checkFacebookLogin
{
    
    // Facebook login flow
    // check if user is already logged in
    if ([PFUser currentUser] && // Check if a user is cached
        [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) // Check if user is linked to Facebook
    {
        // Do not show login flow
        [navController_ pushViewController:self.gamesListViewController animated:NO];
        
    } else {
        // Show login flow
        self.loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [navController_ pushViewController:self.loginViewController animated:NO];
    }
}

- (void)fbLoginSuccessful
{
    [navController_ popViewControllerAnimated:NO];
    [self.loginViewController removeFromParentViewController];
    
    [dataManager fetchUserData];
    
    [navController_ pushViewController:self.gamesListViewController animated:YES];
}

// Supported orientations: Landscape. Customize it for your own needs
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ resume];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ startAnimation];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{
	CC_DIRECTOR_END();
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void) dealloc
{
	[window_ release];
	[navController_ release];
	
	[super dealloc];
}
@end

