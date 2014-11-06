//
//  ChatTableViewCell.m
//  XSkyerChatroom
//
//  Created by Yin Bo on 14/10/31.
//  Copyright (c) 2014年 SheldonLC. All rights reserved.
//

#import "ChatTableViewCell.h"

@interface ChatTableViewCell ()

@property (weak, nonatomic) IBOutlet ChatView *chatView;


@end
@implementation ChatTableViewCell


-(void)setChatViewWarper: (ChatData *) chat withAccess: (AccessControl *) access forTheme : (Theme *) theme{
    [self.chatView setChatViewWraper:chat WithAccess:access forTheme:theme];
}
@end
