//
//  DataManager.h
//  SplashWars
//
//  Created by Arjun Ohri on 4/1/13.
//
//

#import <Foundation/Foundation.h>

#define dataManager [DataManager sharedManager]

@interface DataManager : NSObject

+ (DataManager *) sharedManager;
- (NSDictionary *)fetchUserData;

@end
