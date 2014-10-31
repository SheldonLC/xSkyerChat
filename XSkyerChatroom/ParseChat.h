//
//  ParseChat.h
//  XSkyerChatroom
//
//  Created by Yin Bo on 14/10/29.
//  Copyright (c) 2014年 SheldonLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatData.h"
#import "Constants.h"
#import "TFHpple.h"

@interface ParseChat : NSObject

- (NSArray *) parseHTMLDataForHistory:(NSData *) data;
- (NSArray *) parseXMLDataForCurrentChat:(NSData *) data;


@end
