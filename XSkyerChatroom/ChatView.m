//
//  ChatView.m
//  XSkyerChatroom
//
//  Created by Yin Bo on 14/11/6.
//  Copyright (c) 2014年 SheldonLC. All rights reserved.
//

#import "ChatView.h"

@implementation ChatView

// Set the value for display


- (void)setHighlighted:(BOOL)lit {
    // If highlighted state changes, need to redisplay.
    if (_highlighted != lit) {
        _highlighted = lit;
        [self setNeedsDisplay];
    }
}


-(void) setChatViewWraper:(ChatData *) chat WithAccess : (AccessControl *) access forTheme: (Theme *) theme{
    self.theme = theme;
    self.access = access;
    self.chat = chat;
    
    [self setNeedsDisplay];


}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
//    // Drawing code
//    
//#define LEFT_COLUMN_OFFSET 0
//#define MIDDLE_COLUMN_OFFSET 170
//#define RIGHT_COLUMN_OFFSET 270
//    
//#define UPPER_ROW_TOP 0
//#define LOWER_ROW_TOP 44
//    
//    
//    UIColor *backgroundColor;
//    UIColor *speakerColor;
//    UIColor *chatColor;
//    
//
//    if (self.highlighted) {
//        speakerColor = [UIColor brownColor];
//        chatColor = [UIColor brownColor];
//    }
//    else {
//        speakerColor =[UIColor blueColor];
//        chatColor =  [UIColor blackColor];
//    }
//    
//    //Prepare for Speaker&Chat font
//    UIFont *speakerFont;
//    speakerFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
//    NSDictionary *speakerTextAttributes = @{ NSFontAttributeName : speakerFont, NSForegroundColorAttributeName : speakerColor };
//    
//    // Font attributes for chat content
//    UIFont *chatFont;
//    
//    chatFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
//    NSDictionary *chatTextAttributes = @{ NSFontAttributeName : chatFont, NSForegroundColorAttributeName : chatColor };
//    
//    
//    CGPoint point;
//    
//    /*
//     Draw the speaker name top left.
//     */
//    NSString *speaker = [NSString stringWithFormat:@"%@ %@",self.chat.dateString,self.chat.speaker];
//
//    NSAttributedString *speakerAttributedString = [[NSAttributedString alloc] initWithString:speaker attributes:speakerTextAttributes];
//    point = CGPointMake(LEFT_COLUMN_OFFSET, UPPER_ROW_TOP);
//    [speakerAttributedString drawAtPoint:point];
//    
//    /*
//     Draw the current time in the middle column.
//     */
//    NSString *timeString = [self.dateFormatter stringFromDate:[NSDate date]];
//    NSAttributedString *timeAttributedString = [[NSAttributedString alloc] initWithString:timeString attributes:mainTextAttributes];
//    point = CGPointMake(MIDDLE_COLUMN_OFFSET, UPPER_ROW_TOP);
//    [timeAttributedString drawAtPoint:point];
//    
    /*
     Draw the abbreviation botton left.
     */
//    NSAttributedString *abbreviationAttributedString = [[NSAttributedString alloc] initWithString:self.abbreviation attributes:secondaryTextAttributes];
//    point = CGPointMake(LEFT_COLUMN_OFFSET, LOWER_ROW_TOP);
//    [abbreviationAttributedString drawAtPoint:point];
    
//    /*
//     Draw the whichDay string.
//     */
//    APLTimeZoneWrapper *timeZoneWrapper = self.timeZoneWrapper;
//    
//    NSAttributedString *whichDayAttributedString = [[NSAttributedString alloc] initWithString:timeZoneWrapper.whichDay attributes:secondaryTextAttributes];
//    point = CGPointMake(MIDDLE_COLUMN_OFFSET, LOWER_ROW_TOP);
//    [whichDayAttributedString drawAtPoint:point];
//    
//    
//    // Draw the quarter image.
//    CGFloat imageY = (self.bounds.size.height - self.timeZoneWrapper.image.size.height) / 2;
//    
//    point = CGPointMake(RIGHT_COLUMN_OFFSET, imageY);
//    [timeZoneWrapper.image drawAtPoint:point];
//    


    
//}



@end
