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
#import <QuartzCore/QuartzCore.h>

@interface SettingViewController ()
@property (strong, nonatomic) IBOutlet UILabel *currentUser;
@property (strong, nonatomic) IBOutlet UILabel *blackListLabel;
@property (strong,nonatomic) MFMailComposeViewController *mailPicker;
@property (strong,nonatomic) UIColor *bgColor;



@end

@implementation SettingViewController

@synthesize mailPicker;
@synthesize bgColor;
#pragma Init
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
    bgColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
    self.view.backgroundColor = bgColor;

    
    mailPicker = [[MFMailComposeViewController alloc] init];
    

    
}

-(void)viewWillAppear:(BOOL)animated{
    NSInteger blockedCount = self.blockedUsers?[self.blockedUsers count] :0;
    
    self.currentUser.text = self.access.userName;
    [self.blackListLabel setText:[NSString stringWithFormat:@"黑名单 (%lu 人)",(long)blockedCount]];

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
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if( [[segue identifier] isEqualToString:@"LogoutSegue"] ) {
        //
        NSUserDefaults *accountDefaults = [NSUserDefaults standardUserDefaults];
        [accountDefaults removeObjectForKey:USER_DEFAULTS_ACCOUNT];
        [accountDefaults setBool:NO  forKey:@"AGREED_EULA"];

    }else if( [[segue identifier] isEqualToString:@"GoBlackList"] ) {

        BlackListViewControllerTableViewController * blackVC = [segue destinationViewController];
        
        blackVC.access = self.access;
        blackVC.blockedUsers = self.blockedUsers;
    }else if( [[segue identifier] isEqualToString:@"About"] ) {
        
        UIViewController * vc = [segue destinationViewController];
        
        vc.view.backgroundColor = bgColor;
        for (UIView *view in vc.view.subviews) {
            view.backgroundColor = bgColor;
        }
    }else if( [[segue identifier] isEqualToString:@"Update"] ) {
        
        UIViewController * vc = [segue destinationViewController];
        
        vc.view.backgroundColor = bgColor;
        for (UIView *view in vc.view.subviews) {
            view.backgroundColor = bgColor;
        }
    }else if( [[segue identifier] isEqualToString:@"EULA"] ) {
        
        UITableViewController * vc = [segue destinationViewController];
        
        vc.view.backgroundColor = bgColor;
        for (UIView *view in vc.view.subviews) {
            view.backgroundColor = bgColor;
        }
    }





    
}

- (IBAction)contactMe:(UIButton *)sender {
    
    [self sendEMail];
}


#pragma Email

- (void) alertWithMessage: (NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}

-(void)sendEMail
{
    
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (!mailClass) {
        [self alertWithMessage:@"当前系统版本不支持应用内发送邮件功能，请手动使用邮件应用或网页邮箱代替"];
        return;
    }
    if (![mailClass canSendMail]) {
        [self alertWithMessage:@"您没有设置邮件账户，请使用其他方式，如网页邮箱手动发送"];
        return;
    }
    [self displayMailPicker];
}

#define BODY

- (void)displayMailPicker
{
    
    mailPicker.mailComposeDelegate = self;
    
    //设置主题
    [mailPicker setSubject: @"[XSkyerChat Issue]主题"];
    //添加收件人
    NSArray *toRecipients = [NSArray arrayWithObject: @"pantasiaindie@outlook.com"];
    [mailPicker setToRecipients: toRecipients];
    
    
    NSString *emailBody = @"请描述您遇到的问题，期望的改进或者仅仅是一些鼓励，但请不要在信中透露任何个人信息，包括但不限于真实姓名，性别，电话号码，身份证件，银行账户等。";
    [mailPicker setMessageBody:emailBody isHTML:YES];
    [self presentViewController:mailPicker animated:YES completion:nil];
}

#pragma mark - 实现 MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    //关闭邮件发送窗口
    [self dismissViewControllerAnimated:YES completion:nil];
    NSString *msg;
    switch (result) {
        case MFMailComposeResultCancelled:
            msg = @"已取消发送邮件";
            break;
        case MFMailComposeResultSaved:
            msg = @"用户成功保存邮件";
            break;
        case MFMailComposeResultSent:
            msg = @"邮件进入发送队列";
            break;
        case MFMailComposeResultFailed:
            msg = @"试图保存或者发送邮件失败";
            break;
        default:
            msg = @"";
            break;
    }
    [self alertWithMessage:msg];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if(section == 2){
        return 3;
    }
    return 1;
}


@end
