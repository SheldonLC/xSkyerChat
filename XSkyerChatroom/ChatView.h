//
//  ChatView.h
//  XSkyerChatroom
//
//  Created by Yin Bo on 14/11/6.
//  Copyright (c) 2014年 SheldonLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatData.h"
#import "AccessControl.h"
#import "Theme.h"

@interface ChatView : UIView

@property (nonatomic) ChatData *chat;
@property (nonatomic) AccessControl *access;
@property (nonatomic) Theme *theme;

@property (nonatomic, getter=isHighlighted) BOOL highlighted;


-(void) setChatViewWraper:(ChatData *) chat WithAccess : (AccessControl *) access forTheme: (Theme *) theme;
@end
