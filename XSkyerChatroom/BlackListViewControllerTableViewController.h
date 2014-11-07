//
//  BlackListViewControllerTableViewController.h
//  XSkyerChatroom
//
//  Created by Yin Bo on 14/11/7.
//  Copyright (c) 2014年 SheldonLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AccessControl.h"
#import "Theme.h"
#import "BlockedUser.h"

@interface BlackListViewControllerTableViewController : UITableViewController
@property (strong,nonatomic) AccessControl *access;
@property (strong,nonatomic) NSMutableArray *blockedUsers;

@end
