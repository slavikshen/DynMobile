//
//  DXServoListViewController.m
//  DynMobile
//
//  Created by Slavik on 1/12/14.
//  Copyright (c) 2014 Slavik. All rights reserved.
//

#import "DXServoListViewController.h"
#import "DXServoViewController.h"

@interface DXServoListViewController ()

@end

@implementation DXServoListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    [self _setup];
    return self;
}

- (void)_setup {
    DXAppDelegate* app = APP_DELEGATE;
    [app addObserver:self constantKeys:@[kAppDelegateProperty_Servos]];
}

- (void)dealloc {
    DXAppDelegate* app = APP_DELEGATE;
    [app removeObserver:self constantKeys:@[kAppDelegateProperty_Servos]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if( context == (__bridge void*) kAppDelegateProperty_Servos ) {
        [self _handleServoListChange:change];
    }

}

- (void)_handleServoListChange:(NSDictionary*)change {
 
    if( [self isViewLoaded] ) {
        NSKeyValueChange changeType = [[change objectForKey:NSKeyValueChangeKindKey] unsignedIntegerValue];
        NSIndexSet* indexes = [change objectForKey:NSKeyValueChangeIndexesKey];
        
        NSInteger section = 0;
        NSArray* indexPath = [indexes indexPathes:section];
        UITableView* tableView = self.tableView;


        
        switch( changeType ) {
                
            case NSKeyValueChangeInsertion:
            {
                [tableView beginUpdates];
                [tableView insertRowsAtIndexPaths:indexPath withRowAnimation:UITableViewRowAnimationAutomatic];
                [tableView endUpdates];
            }
                break;
                
            case NSKeyValueChangeRemoval:
            {
                [tableView beginUpdates];
                [tableView deleteRowsAtIndexPaths:indexPath withRowAnimation:UITableViewRowAnimationAutomatic];
                [tableView endUpdates];
            }
                break;
                
            case NSKeyValueChangeReplacement:
            {
                [tableView beginUpdates];
                [tableView reloadRowsAtIndexPaths:indexPath withRowAnimation:UITableViewRowAnimationAutomatic];
                [tableView endUpdates];
            }
                break;
            
            case NSKeyValueChangeSetting:
            {
                [tableView reloadData];
            }
                break;
        }
        
    }
    
}

#pragma mark - Table view data source

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if( 0 == section ) {
        return @"Dynamixel Servos";
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSArray* servos = APP_DELEGATE.servos;
    return servos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if( nil == cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSArray* servos = APP_DELEGATE.servos;
    NSUInteger row = [indexPath row];
    ServoInfo* srv = servos[row];
    NSInteger sid = srv.sid;
    NSInteger pos = srv.position;
    NSString* title = _F(@"Servo %ld",sid);
    NSString* sub = _F(@"POS: %ld", pos);
    
    cell.textLabel.text = title;
    cell.detailTextLabel.text = sub;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 
    DXAppDelegate* app = APP_DELEGATE;
    if( [app.bluetooth isConnected] ) {
        // show the view of the servo
        NSArray* servos = app.servos;
        ServoInfo* s = servos[indexPath.row];
        [self _showServoView:s];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

#pragma mark - servo view

-(void)_showServoView:(ServoInfo*)s {
    
    UISplitViewController* splitViewController = (UISplitViewController*)APP_DELEGATE.window.rootViewController;
    UINavigationController* navController = [splitViewController.viewControllers lastObject];
    
    DXServoViewController* servoViewController = nil;
    id top = navController.topViewController;
    if( [top isKindOfClass:[DXServoViewController class]] ) {
        servoViewController = top;
    } else {
        servoViewController = [[DXServoViewController alloc] init];
        dispatch_async(dispatch_get_main_queue(), ^{
            [navController pushViewController:servoViewController animated:YES];
        });
    }
    
    servoViewController.servo = s;
    
}

@end
