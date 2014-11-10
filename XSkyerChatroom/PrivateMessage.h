//
//  PrivateMessage.h
//  XSkyerChatroom
//
//  Created by Yin Bo on 14/11/9.
//  Copyright (c) 2014年 SheldonLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrivateMessageDetail.h"
@interface PrivateMessage : NSObject

@property (nonatomic,strong) NSString *pmId; //Used to reply, delete or report to admin, window_bf id

@property (nonatomic,strong) NSString* fromUser;
@property (nonatomic,strong) NSString* title;
@property (nonatomic,strong) NSString* sendDate;
@property (nonatomic,strong) NSString* messageStatus;//Unread,pm_old, read- pm_new, replied-pm_replied

@property (nonatomic,strong) PrivateMessageDetail *detail;
@end
