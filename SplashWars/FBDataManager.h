//
//  FBDataManager.h
//  SplashWars
//
//  Created by Arjun Ohri on 3/29/13.
//
//

#import <Foundation/Foundation.h>
#import "Facebook.h"

@interface FBDataManager : NSObject  <FBDialogDelegate>

+ (id) sharedManager;


@end
