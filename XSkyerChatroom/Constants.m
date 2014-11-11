//
//  Constants.m
//  XSkyerChatroom
//
//  Created by Yin Bo on 14/10/29.
//  Copyright (c) 2014年 SheldonLC. All rights reserved.
//

#import "Constants.h"

@implementation Constants

NSString * const HTML_REQUEST_TARGET_CURRENT = @"CURRENT";
NSString * const HTML_REQUEST_TARGET_HISTORY = @"HISTORY";
NSString * const HTML_REQUEST_TARGET_LOGIN = @"LOGIN";
NSString * const HTML_REQUEST_TARGET_PROFILE = @"PROFILE";
NSString * const HTML_REQUEST_TARGET_PRIVATE = @"PRIVATE";



NSString * const HTML_REQUEST_TYPE_LOGIN = @"LOGIN";
NSString * const HTML_REQUEST_TYPE_LOGOUT = @"LOGOUT";

NSString * const HTML_REQUEST_TYPE_CHAT = @"CHAT";
NSString * const HTML_REQUEST_TYPE_EDIT = @"EDIT";
NSString * const HTML_REQUEST_TYPE_DELETE = @"DELETE";

NSString * const HTML_REQUEST_TYPE_REFRESH = @"REFRESH";
NSString * const HTML_REQUEST_TYPE_BLOCKED_GET = @"GET_BLOCKED";
NSString * const HTML_REQUEST_TYPE_BLOCKED_DELETE = @"DELETE_BLOCKED";
NSString * const HTML_REQUEST_TYPE_BLOCKED_ADD = @"ADD_BLOCKED";
NSString * const HTML_REQUEST_TYPE_GET_PM_LIST = @"GET_PM_LIST";


NSString * const HTML_REQUEST_TYPE_REPORT = @"REPORT";




NSString * const ACCSEE_LOGIN_FAILED = @"FAILD";
NSString * const ACCSEE_LOGIN_CORRUPT = @"CORRUPT";
NSString * const ACCSEE_LOGIN_RETRY_TOO_MANY = @"RETRY_MANY";
NSString * const ACCSEE_LOGIN_AUTH_FAILED = @"AUTH_FAILED";


//Theme mode
NSString * const THEME_NIGHT_MODE = @"NIGHT";
NSString * const THEME_DAFAULT_MODE = @"DEFAULT_MODE";


NSString * const USER_DEFAULTS_ACCOUNT = @"SKYER_ACCOUNT_DEFAULT";
NSString * const USER_DEFAULTS_USER_M = @"SKYER_DEFAULT_USER_M";
NSString * const USER_DEFAULTS_PASSWORD = @"SKYER_DEFAULT_PWD";

NSString * const PM_STATUS_NEW = @"pm_new";
NSString * const PM_STATUS_OLD = @"pm_new";
NSString * const PM_STATUS_REPLIED = @"pm_replied";



@end
