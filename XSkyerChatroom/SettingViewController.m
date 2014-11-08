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
@property (strong,nonatomic) MFMailComposeViewController *mailPicker;

@end

@implementation SettingViewController

@synthesize mailPicker;
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
    
    
    mailPicker = [[MFMailComposeViewController alloc] init];


    
}

-(void)viewWillAppear:(BOOL)animated{
    NSInteger blockedCount = self.blockedUsers?[self.blockedUsers count] :0;
    [self.enterBlackList setTitle:[NSString stringWithFormat:@"(%lu 人) 更改",(long)blockedCount]
                         forState:UIControlStateNormal];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    if(![self.view window]){
        self.view = nil;
    }
}

#pragma action
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


@end
