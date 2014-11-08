//
//  LoginViewController.m
//  XSkyerChatroom
//
//  Created by çΩΩ on 14/11/4.
//  Copyright (c) 2014年 SheldonLC. All rights reserved.
//

#import "LoginViewController.h"
#import "TableViewController.h"

@interface LoginViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *icon;
@property (strong, nonatomic) IBOutlet UITextField *userTxt;
@property (strong, nonatomic) IBOutlet UITextField *passwordTxt;
@property (strong,nonatomic) NSUserDefaults *accountDefaults;
@property (nonatomic,strong) TableViewController *mainVC;
@end

@implementation LoginViewController
@synthesize accountDefaults;

#pragma mark init
- (void)viewDidLoad {
    
    //try to login, verify if user/password is ok
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //Get the mainview
    
    
    self.mainVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
    self.userTxt.delegate = self;
    self.passwordTxt.delegate = self;

    //Get the stored password(if any)
    accountDefaults = [NSUserDefaults standardUserDefaults];
}

-(void)viewDidAppear:(BOOL)animated{
    //Auto redirect to main view if successfully logged in
    
    //Animate to show the Power Icon
    __weak LoginViewController *weakSelf  = self;
    [UIView animateWithDuration:2 animations:^{
        [self.icon setAlpha:1.0];
    } completion:^(BOOL finished) {
        
        
        NSString *userM = nil;
        NSString *password = nil;
        if ([accountDefaults boolForKey:USER_DEFAULTS_ACCOUNT] == YES)
        {
            
            userM = [accountDefaults objectForKey:USER_DEFAULTS_USER_M];
            password = [accountDefaults objectForKey:USER_DEFAULTS_PASSWORD];
            
            //call mainVC's delegate to perform login
            [weakSelf.mainVC loginForUser:userM withPassword:password];
        }
        if (weakSelf.mainVC.access.hasLogin) {
              [weakSelf performSegueWithIdentifier:@"LoginSegue" sender:weakSelf];
               //NSLog(@"End");
            
        }else{
            //NSLog(@"Require Login!");

            [UIView animateWithDuration:0 animations:^{
                [weakSelf.userTxt setAlpha:1.0];
            } completion:^(BOOL finished) {
            }];
            [UIView animateWithDuration:0 animations:^{
                [weakSelf.passwordTxt setAlpha:1.0];
            } completion:^(BOOL finished) {
                
            }];
        }
        
     
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UINavigationController  *nav = segue.destinationViewController;
    NSArray *vcArr = nav.viewControllers;
    TableViewController *main = [vcArr objectAtIndex:0];
    main.access = self.mainVC.access;
    
}

#pragma mark  interactive
- (IBAction)tagBlank:(UITapGestureRecognizer *)sender {
    //Dismiss the keyboard
    [self.userTxt resignFirstResponder];
    [self.passwordTxt resignFirstResponder];
    
}


#pragma mark text delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([self.userTxt isFirstResponder]) {
        [self.passwordTxt becomeFirstResponder];
    }else if([self.passwordTxt isFirstResponder]){
        //Process the login
        //
        [self.passwordTxt resignFirstResponder];
        return [self processLogin];
    }
    
    return YES;
}

- (BOOL) isEmpty: (UITextField *) text{
    
    return (!text
    ||!text.text
    || [[text.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString: @""]);
}
- (BOOL) processLogin{
    BOOL hasLogin = YES;
    //1. Validate mandatory
    if ([self isEmpty:self.userTxt]) {
        self.userTxt .placeholder =@"用户名不能为空";
        [self.userTxt setValue:[UIColor redColor] forKeyPath:@"_placeholderLabel.textColor"];
        hasLogin = NO;
    }
    if ([self isEmpty:self.passwordTxt]) {
        self.passwordTxt.placeholder =@"密码不能为空";
        [self.passwordTxt setValue:[UIColor redColor] forKeyPath:@"_placeholderLabel.textColor"];
        hasLogin = NO;
    }
    
    if(hasLogin){
        hasLogin = [self login];
    }
    
    if(!hasLogin){
        //Show red ring
        __weak LoginViewController *weakSelf = self;
        [UIView animateWithDuration:0.8 animations:^{
            [self.icon setAlpha:0.0];
        } completion:^(BOOL finished) {
            weakSelf.icon.image = [UIImage imageNamed:@"redRing"];
            [UIView animateWithDuration:0.8 animations:^{
                [weakSelf.icon setAlpha:1.0];
            } completion:^(BOOL finished) {
                if(self.mainVC.access.token && ![self.mainVC.access.token isEqualToString:@""]){
                
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:self.mainVC.access.token delegate:weakSelf cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    // optional - add more buttons:
                    //[alert addButtonWithTitle:@"Yes"];
                    [alert show];
                }

                
            }];
        }];
    }

    return hasLogin;
}

- (BOOL) login{
    
    [self.mainVC loginForUser:self.userTxt.text withPassword:self.passwordTxt.text];
    
    if (self.mainVC.access && self.mainVC.access.hasLogin) {
        __weak LoginViewController *weakSelf = self;
        
        [UIView animateWithDuration:0.0 animations:^{
            [self.userTxt setAlpha:0.0];
        } completion:^(BOOL finished) {
            
        }];
        [UIView animateWithDuration:0.0 animations:^{
            [self.passwordTxt setAlpha:0.0];
        } completion:^(BOOL finished) {
            
        }];
        [self.passwordTxt resignFirstResponder];
        
        [UIView animateWithDuration:0.8 animations:^{
            [self.icon setAlpha:0.0];
        } completion:^(BOOL finished) {
            weakSelf.icon.image = [UIImage imageNamed:@"powerIcon"];
            [UIView animateWithDuration:1.0 animations:^{
                [self.icon setAlpha:1.0];
            } completion:^(BOOL finished) {
                
                if ([accountDefaults boolForKey:USER_DEFAULTS_ACCOUNT] == YES)
                {
                    [accountDefaults setObject:self.userTxt.text forKey:USER_DEFAULTS_USER_M];
                    [accountDefaults setObject:self.passwordTxt.text forKey:USER_DEFAULTS_PASSWORD];
                    
                }else{
                    [accountDefaults setBool:YES forKey:USER_DEFAULTS_ACCOUNT];
                    [accountDefaults setObject:self.userTxt.text forKey:USER_DEFAULTS_USER_M];
                    [accountDefaults setObject:self.passwordTxt.text forKey:USER_DEFAULTS_PASSWORD];
                }
                [weakSelf performSegueWithIdentifier:@"LoginSegue" sender:weakSelf];
                //NSLog(@"Login successfully!");
            }];
        }];
        
        return YES;
    }else{
        
        //NSLog(@"Login Failed!");
        return NO;
    }
    
}
@end
