//
//  SettingViewController.m
//  XSkyerChatroom
//
//  Created by Yin Bo on 14/11/6.
//  Copyright (c) 2014年 SheldonLC. All rights reserved.
//

#import "SettingViewController.h"
#import "LoginViewController.h"
#import "BlackListViewControllerTableViewController.h"

@interface SettingViewController ()
@property (strong, nonatomic) IBOutlet UILabel *currentUser;
@property (strong, nonatomic) IBOutlet UIButton *enterBlackList;

@end

@implementation SettingViewController

-(instancetype)init{
    //Set title
    self = [super init];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //Get the sourceview controller, set the current user to login user
    self.currentUser.text= self.access.userName;
    

    
}

-(void)viewWillAppear:(BOOL)animated{
    NSInteger blockedCount = self.blockedUsers?[self.blockedUsers count] :0;
    [self.enterBlackList setTitle:[NSString stringWithFormat:@"(%lu 人)",blockedCount]
                         forState:UIControlStateNormal];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    if(![self.view window]){
        self.view = nil;
    }
}
- (IBAction)blackListMaint:(id)sender {
    [self performSegueWithIdentifier:@"GoBlackList" sender:self];
}


- (IBAction)logout:(UIButton *)sender {
    
    [self performSegueWithIdentifier:@"LogoutSegue" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if( [[segue identifier] isEqualToString:@"LogoutSegue"] ) {
        TableViewController *mainVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
        mainVC.access = self.access;
        [mainVC logout];
    }else if( [[segue identifier] isEqualToString:@"GoBlackList"] ) {

        BlackListViewControllerTableViewController * blackVC = [segue destinationViewController];
        
        blackVC.access = self.access;
        blackVC.blockedUsers = self.blockedUsers;
    }


    
}


@end
