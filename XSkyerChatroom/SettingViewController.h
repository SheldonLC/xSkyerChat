//
//  SettingViewController.h
//  XSkyerChatroom
//
//  Created by Yin Bo on 14/11/6.
//  Copyright (c) 2014年 SheldonLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import "AccessControl.h"
#import "TableViewController.h"

@interface SettingViewController : UITableViewController <MFMailComposeViewControllerDelegate>
@property (strong,nonatomic) AccessControl *access;
@property (strong,nonatomic) TableViewController   *mainVC;
@property   (nonatomic,strong) NSMutableArray *blockedUsers;



@end
