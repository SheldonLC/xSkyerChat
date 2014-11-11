//
//  ChatboxViewController.h
//  xSkyerChat
//
//  Created by Yin Bo on 14/11/11.
//  Copyright (c) 2014年 SheldonLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AccessControl.h"
#import "TableViewController.h"

@interface ChatboxViewController : UIViewController <UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UITextView *chatbox;
@property (strong,nonatomic) AccessControl *access;
@property (weak,nonatomic) TableViewController *mainVC;

@end
