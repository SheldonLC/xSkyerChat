//
//  TableViewController.h
//  XSkyerChatroom
//
//  Created by Yin Bo on 14/10/29.
//  Copyright (c) 2014年 SheldonLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullTableView.h"


@interface TableViewController : UIViewController <UITableViewDataSource,NSURLSessionDelegate,UITextViewDelegate, PullTableViewDelegate>{
    PullTableView *pullTableView;
}


@property (strong, nonatomic) IBOutlet PullTableView *pullTableView;

@end
