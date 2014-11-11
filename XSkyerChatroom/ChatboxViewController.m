//
//  ChatboxViewController.m
//  xSkyerChat
//
//  Created by Yin Bo on 14/11/11.
//  Copyright (c) 2014年 SheldonLC. All rights reserved.
//

#import "ChatboxViewController.h"

@interface ChatboxViewController ()

@end

@implementation ChatboxViewController


@synthesize chatbox;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
    self.chatbox.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
    
    chatbox.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





- (void)viewWillAppear:(BOOL)animated{
    [chatbox becomeFirstResponder];
    chatbox.text = self.mainVC.chatContents;
}

-(void)viewDidDisappear:(BOOL)animated{
    chatbox.text = @"";
}
/**
 * Hidden keyboard
 */
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];

        
        return NO;
    }
    return YES;
}

#pragma action


- (IBAction)send:(id)sender {
   //Call send message here
    if(!chatbox.text || [[chatbox.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]){
        return;
    }
    self.mainVC.chatContents = chatbox.text;
    [self.mainVC sendMessage];
    [self performSegueWithIdentifier:@"GoChat" sender:self];


}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    TableViewController *main = [segue destinationViewController];
    main.access = self.access ;
    
}


@end
