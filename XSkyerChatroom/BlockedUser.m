//
//  BlockedUser.m
//  XSkyerChatroom
//
//  Created by Yin Bo on 14/11/7.
//  Copyright (c) 2014年 SheldonLC. All rights reserved.
//

#import "BlockedUser.h"

@implementation BlockedUser

- (BOOL) isEqual:(BlockedUser *) another{
    BOOL idEqual = [another.userID isEqualToString:self.userID];
    BOOL nameEqual = [[another.userM uppercaseString] isEqualToString:[self.userM uppercaseString]];
    return idEqual && nameEqual;
}
@end
