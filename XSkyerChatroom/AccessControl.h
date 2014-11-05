//
//  AccessControl.h
//  XSkyerChatroom
//
//  Created by Yin Bo on 14/10/29.
//  Copyright (c) 2014年 SheldonLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccessControl : NSObject

@property (strong,nonatomic) NSString* userName;
@property (strong,nonatomic) NSString* password;
@property (nonatomic) BOOL hasLogin;
@property  (strong,nonatomic) NSString *token;
@property (nonatomic) BOOL isSessionTimeout;

-(instancetype) initWithUser: (NSString*) user password:(NSString *) password;

@end
