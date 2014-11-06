//
//  ChatTableViewCell.h
//  XSkyerChatroom
//
//  Created by Yin Bo on 14/10/31.
//  Copyright (c) 2014年 SheldonLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatView.h"

@interface ChatTableViewCell : UITableViewCell

-(void)setChatViewWarper: (ChatData *) chat withAccess: (AccessControl *) access forTheme : (Theme *) theme;
@end
