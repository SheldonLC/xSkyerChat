//
//  ChatData.h
//  XSkyerChatroom
//
//  Created by Yin Bo on 14/10/29.
//  Copyright (c) 2014年 SheldonLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatData : NSObject
@property (strong,nonatomic) NSString *speaker;
@property (strong,nonatomic) NSString *icon;
@property (strong,nonatomic) NSString *dateString;
@property (strong,nonatomic) NSString *chatId;
@property (strong,nonatomic) NSString *content;

- (BOOL) matchedWith : (ChatData *) anotherChat;

- (BOOL) newerThan: (ChatData *) anotherChat;

- (BOOL) olderThan: (ChatData *) anotherChat;


- (BOOL) ownedByUser : (NSString *) user;
@end
