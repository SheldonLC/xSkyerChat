//
//  SettingViewController.m
//  XSkyerChatroom
//
//  Created by Yin Bo on 14/11/6.
//  Copyright (c) 2014年 SheldonLC. All rights reserved.
//

#import "SettingViewController.h"
#import "LoginViewController.h"

@interface SettingViewController ()
@property (strong, nonatomic) IBOutlet UILabel *currentUser;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //Get the sourceview controller, set the current user to login user
    self.currentUser.text= self.access.userName;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    if(![self.view window]){
        self.view = nil;
    }
}


- (IBAction)logout:(UIButton *)sender {
    
    [self performSegueWithIdentifier:@"LogoutSegue" sender:self];
    self.view = nil;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if( [[segue identifier] isEqualToString:@"LogoutSegue"] ) {
        TableViewController *mainVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
        mainVC.access = self.access;
        [mainVC logout];
    }

    
}


@end
