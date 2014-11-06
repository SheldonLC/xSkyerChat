//
//  Constants.h
//  XSkyerChatroom
//
//  Created by Yin Bo on 14/10/29.
//  Copyright (c) 2014年 SheldonLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

extern NSString * const HTML_REQUEST_TARGET_CURRENT;
extern NSString * const HTML_REQUEST_TARGET_HISTORY;
extern NSString * const HTML_REQUEST_TARGET_LOGIN;


extern NSString * const HTML_REQUEST_TYPE_LOGIN;
extern NSString * const HTML_REQUEST_TYPE_LOGOUT;
extern NSString * const HTML_REQUEST_TYPE_CHAT;
extern NSString * const HTML_REQUEST_TYPE_EDIT;
extern NSString * const HTML_REQUEST_TYPE_DELETE;
extern NSString * const HTML_REQUEST_TYPE_REFRESH;

extern NSString * const ACCSEE_LOGIN_FAILED;
extern NSString * const ACCSEE_LOGIN_CORRUPT;
extern NSString * const ACCSEE_LOGIN_RETRY_TOO_MANY;
extern NSString * const ACCSEE_LOGIN_AUTH_FAILED;
@end
