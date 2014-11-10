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
- (NSArray *) parseHTMLDataForBlockedUsers:(NSData *) data;
- (NSArray *) parseXMLDataForCurrentChat:(NSData *) data;
- (NSString *) parseHTMLDataForAccess:(NSData *) data;
- (NSArray *) parseHTMLDataForPMList:(NSData *) data;


@end
