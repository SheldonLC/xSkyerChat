//
//  TableViewController.h
//  XSkyerChatroom
//
//  Created by Yin Bo on 14/10/29.
//  Copyright (c) 2014年 <Pantasia Indie>. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullTableView.h"
#import "ChatData.h"
#import "Constants.h"
#import "ParseChat.h"
#import "PostParameter.h"
#import "ChatboxPopOverController.h"
#import <QuartzCore/QuartzCore.h>
#import "AccessControl.h"

@interface TableViewController : UIViewController <UITableViewDataSource,NSURLSessionDelegate,UITextViewDelegate, PullTableViewDelegate>{
    PullTableView *pullTableView;
}
//Session
@property (strong,nonatomic) NSURLSession *thisSession;
@property (strong,nonatomic) NSURL *thisUrl;
@property (strong,nonatomic) NSData *data;
@property (strong,nonatomic) NSString *target;
@property (strong,nonatomic) NSURLSessionDataTask *dataTask;
@property (nonatomic) BOOL isCompleted;
@property (strong,nonatomic) NSMutableData *tempData;
@property (strong,nonatomic) ParseChat *parse;
@property (strong,nonatomic) PostParameter* param;
@property (nonatomic,strong) NSDate *toDate;

@property (nonatomic,strong) AccessControl *access;

@property (strong, nonatomic) IBOutlet PullTableView *pullTableView;

-(void) loginForUser: (NSString *) userName withPassword :(NSString *) password;
-(void) logout;

@end
