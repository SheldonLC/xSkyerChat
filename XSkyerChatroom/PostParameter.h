//
//  PostParameter.h
//  XSkyerChatroom
//
//  Created by Yin Bo on 14/11/2.
//  Copyright (c) 2014年 SheldonLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PostParameter : NSObject


- (NSString *) generateChatWithToken:(NSString *) sToken withChat: (NSString *) chat;


- (NSString *) generateLoginWithUser:(NSString *) user withPassword: (NSString *) password;

- (NSString *) generateRefreshWithToken:(NSString *) sToken;


@end
