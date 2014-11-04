//
//  PostParameter.m
//  XSkyerChatroom
//
//  Created by Yin Bo on 14/11/2.
//  Copyright (c) 2014年 SheldonLC. All rights reserved.
//

#import "PostParameter.h"

@implementation PostParameter


-(NSString *)generateChatWithToken:(NSString *)sToken withChat:(NSString *)chat{
    
    return [NSString stringWithFormat:@"securitytoken=%@&do=ajax_chat&channel_id=0&color=#000000&chat=%@",sToken,chat];
}


-(NSString *)generateLoginWithUser:(NSString *)user withPassword:(NSString *)password{
    return [NSString stringWithFormat:@"do=login&vb_login_username=%@&vb_login_password=%@&cookieuser=1",user,password];
}


-(NSString *)generateRefreshWithToken:(NSString *)sToken{
    return [NSString stringWithFormat:@"securitytoken=%@&do=ajax_refresh_chat&chatids=100",sToken];
}

@end
