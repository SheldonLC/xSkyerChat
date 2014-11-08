//
//  BlockedUser.h
//  XSkyerChatroom
//
//  Created by Yin Bo on 14/11/7.
//  Copyright (c) 2014年 SheldonLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BlockedUser : NSObject

@property (strong,nonatomic) NSString *userM;
@property (strong,nonatomic) NSString *userID;


- (BOOL) isEqual:(BlockedUser *) another;

-(instancetype)initWithUserId: (NSString *) userId withUserName: (NSString *) userM;
@end
