//
//  DataManager.m
//  SplashWars
//
//  Created by Arjun Ohri on 4/1/13.
//
//

#import "DataManager.h"
#import <Parse/Parse.h>

@implementation DataManager

+ (DataManager *)sharedManager
{
    static DataManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[DataManager alloc] init];
    });
    
    return sharedManager;
}

- (NSDictionary *)fetchUserData
{
    // Create request for user's Facebook data
    FBRequest *request = [FBRequest requestForMe];
    
    // Send request to Facebook
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result is a dictionary
            NSDictionary *userData = (NSDictionary *)result;
            
            NSString *facebookID = userData[@"id"];
            
            NSDictionary *userProfile = @{
                                          @"facebookId": facebookID,
                                          @"name": userData[@"name"],
                                          @"location": userData[@"location"][@"name"],
                                          @"gender": userData[@"gender"],
                                          @"birthday": userData[@"birthday"],
                                          @"relationship": userData[@"relationship_status"]
                                          //@"pictureURL": [pictureURL absoluteString]
                                          };
            
            NSLog(@"User profile is %@",userProfile);
        }
    }];
}


@end
