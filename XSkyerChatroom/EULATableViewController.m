//
//  EULATableViewController.m
//  xSkyerChat
//
//  Created by Yin Bo on 14/11/11.
//  Copyright (c) 2014年 SheldonLC. All rights reserved.
//

#import "EULATableViewController.h"

@interface EULATableViewController ()
@property (strong, nonatomic) IBOutlet UITableViewCell *release1;
@property (strong, nonatomic) IBOutlet UITableViewCell *release2;
@property (strong, nonatomic) IBOutlet UITableViewCell *release3;
@property (strong, nonatomic) IBOutlet UITableViewCell *release4;
@property (strong, nonatomic) IBOutlet UITableViewCell *release5;
@property (strong, nonatomic) IBOutlet UITableView *accept;

@end

@implementation EULATableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    UIColor *bgColor = [UIColor blackColor];
    self.tableView.backgroundColor = bgColor;
    self.release1.backgroundColor = bgColor;
    self.release2.backgroundColor = bgColor;
    self.release3.backgroundColor = bgColor;
    self.release4.backgroundColor = bgColor;
    self.release5.backgroundColor = bgColor;
    
    NSUserDefaults  *eulaDefault = [NSUserDefaults standardUserDefaults];
    
    if ([eulaDefault boolForKey:@"AGREED_EULA"]) {
        self.release1.textLabel.textColor = bgColor;
        self.release2.textLabel.textColor = bgColor;
        self.release3.textLabel.textColor = bgColor;
        self.release4.textLabel.textColor = bgColor;
        self.release5.textLabel.textColor = bgColor;
        
        self.accept.tintColor = bgColor;
    }


}

-(void)viewDidAppear:(BOOL)animated{
    NSUserDefaults  *eulaDefault = [NSUserDefaults standardUserDefaults];
    
    if ([eulaDefault boolForKey:@"AGREED_EULA"]) {
        [self performSegueWithIdentifier:@"Accept" sender:self];
    }else{
        //Go ahead
    }
}
- (IBAction)submit:(id)sender {
    
    NSUserDefaults  *eulaDefault = [NSUserDefaults standardUserDefaults];
    [eulaDefault setBool:YES  forKey:@"AGREED_EULA"];

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
    return 5;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
