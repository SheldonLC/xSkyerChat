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
extern NSString * const HTML_REQUEST_TARGET_CURRENT_CHAT;
extern NSString * const HTML_REQUEST_TARGET_HISTORY;
extern NSString * const HTML_REQUEST_TARGET_LOGIN;
extern NSString * const HTML_REQUEST_TARGET_PROFILE;
extern NSString * const HTML_REQUEST_TARGET_PRIVATE;



extern NSString * const HTML_REQUEST_TYPE_LOGIN;
extern NSString * const HTML_REQUEST_TYPE_LOGOUT;
extern NSString * const HTML_REQUEST_TYPE_CHAT;
extern NSString * const HTML_REQUEST_TYPE_EDIT;
extern NSString * const HTML_REQUEST_TYPE_DELETE;
extern NSString * const HTML_REQUEST_TYPE_REFRESH;
extern NSString * const HTML_REQUEST_TYPE_BLOCKED_GET;
extern NSString * const HTML_REQUEST_TYPE_BLOCKED_DELETE;
extern NSString * const HTML_REQUEST_TYPE_BLOCKED_ADD;
extern NSString * const HTML_REQUEST_TYPE_REPORT;
extern NSString * const HTML_REQUEST_TYPE_GET_PM_LIST;


extern NSString * const ACCSEE_LOGIN_FAILED;
extern NSString * const ACCSEE_LOGIN_CORRUPT;
extern NSString * const ACCSEE_LOGIN_RETRY_TOO_MANY;
extern NSString * const ACCSEE_LOGIN_AUTH_FAILED;


extern NSString * const THEME_NIGHT_MODE;
extern NSString * const THEME_DAFAULT_MODE;

extern NSString * const USER_DEFAULTS_ACCOUNT;
extern NSString * const USER_DEFAULTS_USER_M;
extern NSString * const USER_DEFAULTS_PASSWORD;

extern NSString * const PM_STATUS_NEW;
extern NSString * const PM_STATUS_OLD;
extern NSString * const PM_STATUS_REPLIED;

@end
