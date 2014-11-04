//
//  ChatView.m
//  XSkyerChatroom
//
//  Created by Yin Bo on 14/11/1.
//  Copyright (c) 2014年 SheldonLC. All rights reserved.
//

#import "ChatView.h"

@implementation ChatView

-(void)setChatWraper:(ChatData *)chatWraper{
    
    _chatWraper = chatWraper;
    [self setNeedsDisplay];
    
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
//Define the offset
#define LEFT_COLUMN_OFFSET 10
#define MIDDLE_COLUMN_OFFSET 170
#define RIGHT_COLUMN_OFFSET 270
    
#define UPPER_ROW_TOP 12
#define LOWER_ROW_TOP 44
    
    
    //1. draw the area with user name
    
    
    //2.draw the bubble
    
    //3 write the text
    
    
}

//Method to response for long press
//Once clicked, will promote following menu
//1) Copy speaker & chat to textbox
//2) Copy chat only to textbox
//3) @to speaker



@end
