//
//  ChatView.h
//  XSkyerChatroom
//
//  Created by Yin Bo on 14/11/1.
//  Copyright (c) 2014年 SheldonLC. All rights reserved.
//

//Represent single chat

#import <UIKit/UIKit.h>
#import "ChatData.h"
@interface ChatView : UITableViewCell

@property (strong,nonatomic) ChatData *chatWraper;

@end
