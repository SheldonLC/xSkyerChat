//
//  BlackListViewControllerTableViewController.m
//  XSkyerChatroom
//
//  Created by Yin Bo on 14/11/7.
//  Copyright (c) 2014年 SheldonLC. All rights reserved.
//

#import "BlackListViewControllerTableViewController.h"
#import "PostParameter.h"
#import "SettingViewController.h"

@interface BlackListViewControllerTableViewController ()

@property (strong,nonatomic) PostParameter *param;
@end

@implementation BlackListViewControllerTableViewController

- (PostParameter *)param{
    
    if(!_param){
        _param = [[PostParameter alloc] init];
    }
    return _param;
}
- (IBAction)navigationEditButtonClick:(UIButton *)sender {
    
    if (sender.selected == NO) {
        sender.selected = YES;
        [sender setTitle:@"完成" forState:UIControlStateNormal];
                self.editing = YES;
    }else{
        sender.selected = NO;
        [sender setTitle:@"编辑" forState:UIControlStateNormal];
        
        self.editing = NO;
    }
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    
    
    

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.blockedUsers count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"user" forIndexPath:indexPath];
    
    BlockedUser  *user = [self.blockedUsers objectAtIndex:indexPath.row];
    // Configure the cell...
    cell.textLabel.text = user.userM;
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
        return UITableViewCellEditingStyleDelete;
}

-(void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    [self.tableView setEditing:editing animated:animated];
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        //Call URLConnection to delete
        NSString *userID = [[self.blockedUsers objectAtIndex:row] userID];
        NSURL *url = [NSURL URLWithString:@"http://www.xbox-skyer.com/profile.php"];
        NSMutableURLRequest *delete= [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
        [delete setHTTPMethod:@"POST"];
        NSString *str = [self.param generateRemoveBlockedUserWithToken: self.access.token forUserId: userID];
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        [delete setHTTPBody:data];
        [NSURLConnection sendAsynchronousRequest:delete queue: [NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if(!connectionError){
                [self.blockedUsers removeObjectAtIndex:row];
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                 withRowAnimation:UITableViewRowAnimationAutomatic];

            }
        }];
        
    }
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    if (![parent isEqual:self.parentViewController]) {
        SettingViewController *set = (SettingViewController *)parent;
        set.blockedUsers = self.blockedUsers;
        
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation



@end
