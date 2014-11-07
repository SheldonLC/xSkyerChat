//
//  XSkyerChatroomTests.m
//  XSkyerChatroomTests
//
//  Created by Yin Bo on 14/10/29.
//  Copyright (c) 2014年 <Pantasia Indie>. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ParseChat.h"
#import "PostParameter.h"

@interface XSkyerChatroomTests : XCTestCase

@end

@implementation XSkyerChatroomTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}
/*
- (void) testA{
    NSURL *url2 = [NSURL URLWithString:@"http://www.xbox-skyer.com/mgc_cb_evo_ajax.php"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url2 cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    [request setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
    
    NSString *str = @"securitytoken=1414885914-45462ba936d9b1fbe44d0fdbe2aa26715039e7d4&do=ajax_chat&channel_id=0&chat_name=<Pantasia Indie>&b=0&i=0&u=0&font=Arial&color=#000000&size=3&chat=测试：狗康的每日生活，游戏，发帖，骂老刘";//设置参数
    
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPBody:data];
    
    //第三步，连接服务器
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *strResult = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    NSLog(@"%@",strResult);
   // NSArray *chats = [[[ParseChat alloc]init] parseXMLDataForCurrentChat:received];
    XCTAssert(@"Yes",@"123");
}
*/
- (void)testB{
    NSURL *url1 = [NSURL URLWithString:@"http://www.xbox-skyer.com/login.php"];
    NSMutableURLRequest *requestLogin = [[NSMutableURLRequest alloc]initWithURL:url1 cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    [requestLogin setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
    NSString *str1 = @"do=login&vb_login_username=sheldonlc&vb_login_password=yb830922&cookieuser=1";//设置参数
    NSData *data1 = [str1 dataUsingEncoding:NSUTF8StringEncoding];
    [requestLogin setHTTPBody:data1];
    NSData *received1 = [NSURLConnection sendSynchronousRequest:requestLogin returningResponse:nil error:nil];
    NSString *strResult1 = [[NSString alloc]initWithData:received1 encoding:NSUTF8StringEncoding];
    NSString  *stoken = [[[ParseChat alloc]init] parseHTMLDataForAccess:received1];
    NSLog(@"%@",@"******************* Test Log Begin *****************");

    NSLog(@"%@",stoken);
    //Get the ignore list
    
    NSURL *url2 = [NSURL URLWithString:@"http://www.xbox-skyer.com/profile.php"];
    NSMutableURLRequest *requestLogin2 = [[NSMutableURLRequest alloc]initWithURL:url2 cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    [requestLogin2 setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
    NSString *str2 = [NSString stringWithFormat: @"do=ignorelist&styleid=47&securitytoken=%@",stoken];//设置参数
    NSData *data2 = [str2 dataUsingEncoding:NSUTF8StringEncoding];
    [requestLogin2 setHTTPBody:data2];
    NSData *received2 = [NSURLConnection sendSynchronousRequest:requestLogin2 returningResponse:nil error:nil];
    NSString *strResult2 = [[NSString alloc]initWithData:received2 encoding:NSUTF8StringEncoding];
    
    [[[ParseChat alloc]init] parseHTMLDataForBlockedUsers:received2];

   
}
- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
