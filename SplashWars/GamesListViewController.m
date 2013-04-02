//
//  GamesListViewController.m
//  SplashWars
//
//  Created by Arjun Ohri on 3/29/13.
//
//

#import "GamesListViewController.h"

@interface GamesListViewController ()

@end

@implementation GamesListViewController

@synthesize games;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.games = [[NSMutableArray alloc] initWithObjects:@"Arjun", nil];
    }
    return self;
}

- (void)viewDidLoad
{
    // Do any additional setup after loading the view from its nib.
    NSLog(@"GamesListView did load");
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [super viewDidLoad];
    
}

#pragma mark -
#pragma mark tableViewDelegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [games count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"SWGamesListCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"SWGamesListCell"];
        UIImage *pic = [UIImage imageNamed:@"face_1.png"];
        cell.textLabel.text = [games objectAtIndex:[indexPath row]];
        if ([indexPath row]%2) {
            pic = [UIImage imageNamed:@"face_2.png"];
            cell.textLabel.text = @"Whitney";
        }
        cell.imageView.image = pic;
        cell.detailTextLabel.text = @"Play now!";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        //UIColor *bgColor = [UIColor colorWithRed:30/255.0f green:152/255.0f blue:255/255.0f alpha:0.5f];
        //cell.backgroundColor = bgColor;
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Default is 1 if not implemented
    // Can add "Completed Games" or other ones
    return 1;
}

-(IBAction)createGameButtonHandler:(id)sender
{
    // Add a new item to the games array
    
    [games addObject:@"Whitney"];
    
    // Make a new index path for the 0th section, last row
    int lastRow = [games count] - 1;
    
    NSIndexPath *ip = [NSIndexPath indexPathForRow:lastRow inSection:0];
    
    // Insert this new row into the table.
    [[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:ip]  withRowAnimation:UITableViewRowAnimationTop];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{

}


@end
