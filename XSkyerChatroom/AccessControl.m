//
//  AccessControl.m
//  XSkyerChatroom
//
//  Created by Yin Bo on 14/10/29.
//  Copyright (c) 2014年 <Pantasia Indie>. All rights reserved.
//

#import "AccessControl.h"

@implementation AccessControl


-(instancetype) initWithUser: (NSString*) user password:(NSString *) password{
    self = [super init];
    
    self.userName = user;
    self.password = password;
    
    return self;
}


@end
