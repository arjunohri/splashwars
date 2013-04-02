//
//  GamesListViewController.h
//  SplashWars
//
//  Created by Arjun Ohri on 3/29/13.
//
//

#import <UIKit/UIKit.h>

@interface GamesListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

+(id) sharedInstance;

@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonatomic, readwrite,strong) NSMutableArray* games;

-(IBAction)createGameButtonHandler:(id)sender;

@end
