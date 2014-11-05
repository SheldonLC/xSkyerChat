//
//  ParseChat.m
//  XSkyerChatroom
//
//  Created by Yin Bo on 14/10/29.
//  Copyright (c) 2014年 SheldonLC. All rights reserved.
//

#import "ParseChat.h"

@interface ParseChat ()

@property (strong,nonatomic) NSArray *chats;//chats extracted
//@property (strong,nonatomic) NSURLConnection *theConnection;
@property (strong,nonatomic) NSData *data;
@end

@implementation ParseChat


- (NSArray *) parseXMLDataForCurrentChat:(NSData *) data
{
    NSArray *chats = nil;
    NSString *str1 = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",str1);
    
    //int index = 0;

    if (data) {
        TFHpple *xpathParser = [[TFHpple alloc] initWithXMLData: data];
        
        NSArray *elements = [xpathParser searchWithXPathQuery:@"//chat"];
        if([elements count]!=0){
            TFHppleElement *chatidsNode = (TFHppleElement *)[elements firstObject];
            NSMutableArray *mElements = [[NSMutableArray alloc]initWithArray:elements];
            [mElements removeObject:chatidsNode];
            
            NSMutableArray *mChats = [[NSMutableArray alloc] initWithCapacity:[elements count]];
            
            NSMutableString *speaker = nil;
            NSMutableString *time = nil;

            NSMutableString *text = nil;
            NSMutableString *imgSrc = nil;

            for (TFHppleElement *chatElement in mElements) {
                //TFHppleElement *chatElement = [mElements objectAtIndex:36];
                TFHppleElement *colChat = [chatElement firstChildWithTagName:@"col_chat"];
                //NSLog(@"%d",index++);
                text = [[NSMutableString alloc]initWithString:[self getChatBy:colChat]];
                {
                    NSRange substr1 = [text rangeOfString:@"\n\t"]; // 字符串查找,可以判断字符串中是否有
                    if (substr1.location != NSNotFound) {
                        [text deleteCharactersInRange: substr1] ;// 字符串删除
                    }
                    NSRange substr2 = [text rangeOfString:@"\n"]; // 字符串查找,可以判断字符串中是否有
                    if (substr2.location != NSNotFound) {
                        [text deleteCharactersInRange: substr2] ;// 字符串删除
                    }
                }
                //NSLog(@"%@",text);
                
                TFHppleElement *colDateElement = [chatElement firstChildWithTagName:@"col_date"];

                time = [[NSMutableString alloc]initWithString:[self getTimeBy:colDateElement]];
                
                {
                    NSRange substr1 = [time rangeOfString:@"\n\t\t   "]; // 字符串查找,可以判断字符串中是否有
                    if (substr1.location != NSNotFound) {
                        [time deleteCharactersInRange: substr1] ;// 字符串删除
                    }
                    NSRange substr2 = [time rangeOfString:@"  \n\t"]; // 字符串查找,可以判断字符串中是否有
                    if (substr2.location != NSNotFound) {
                        [time deleteCharactersInRange: substr2] ;// 字符串删除
                    }
                }
                //NSLog(@"%@",time);
                
                TFHppleElement *colUNameElement = [chatElement firstChildWithTagName:@"col_uname"];
                speaker = [[NSMutableString alloc]initWithString:[self getSpeakerBy:colUNameElement]];
                
                {
                    NSRange substr1 = [speaker rangeOfString:@"&nbsp"]; // 字符串查找,可以判断字符串中是否有
                    if (substr1.location != NSNotFound) {
                        [speaker deleteCharactersInRange: substr1] ;// 字符串删除
                    }
                }
                //NSLog(@"%@",speaker);
                imgSrc = [[NSMutableString alloc] initWithString:@"http://www.xbox-skyer.com/"];
                [imgSrc appendString:[self getImgSrcBy:colUNameElement]];
                
                //find chai_id
                TFHppleElement *colChatId = [chatElement firstChildWithTagName:@"chatid"];
                NSString *chatId = [colChatId text];
                //NSLog(@"%@",chatId);

                
                //setup ChatData
                ChatData *chat = [[ChatData alloc]init];
                
                //Set value here
                chat.chatId = chatId;
                chat.speaker = speaker;
                chat.dateString = time;
                chat.content = text;
                chat.icon = imgSrc;
                
                [mChats addObject:chat];
            }
            chats = mChats;
        }

    }
    
    if(!chats){
        chats = [[NSArray alloc]init];
    }
    return chats;

}

- (NSString *) getImgSrcBy:(TFHppleElement *)colElement
{
    NSArray *colChild =colElement.children;
    NSString *content = [[colChild objectAtIndex:0] content];
    NSData* htmlData = [content dataUsingEncoding:NSUTF8StringEncoding];
    
    TFHpple *xpathParserSub = [[TFHpple alloc] initWithHTMLData:htmlData];
    NSArray *elements = [xpathParserSub searchWithXPathQuery:@"//span//img"];
    NSString *childContent = [[elements objectAtIndex:0] objectForKey:@"src"];
    if (!childContent) {
        childContent = @"***";
    }

    return childContent;
}

- (NSString *) getSpeakerBy:(TFHppleElement *)colElement
{
    NSArray *colChild =colElement.children;
    NSString *content = [[colChild objectAtIndex:0] content];
    NSData* htmlData = [content dataUsingEncoding:NSUTF8StringEncoding];
    
    TFHpple *xpathParserSub = [[TFHpple alloc] initWithHTMLData:htmlData];
    NSArray *elements = [xpathParserSub searchWithXPathQuery:@"//span//a"];
    NSString *childContent = [[elements objectAtIndex:0] text];
    if (!childContent) {
        childContent = @"***";
    }

    return childContent;
}


- (NSString *) getTimeBy:(TFHppleElement *)colElement
{
    NSArray *colChild =colElement.children;
    NSString *content = [[colChild objectAtIndex:0] content];
    NSData* htmlData = [content dataUsingEncoding:NSUTF8StringEncoding];
    
    TFHpple *xpathParserSub = [[TFHpple alloc] initWithHTMLData:htmlData];
    NSArray *elements = [xpathParserSub searchWithXPathQuery:@"//span//span"];
    NSString *childContent = [[elements objectAtIndex:0] text];
    if (!childContent) {
        childContent = @"***";
    }

    return childContent;
}


- (NSString *) getChatBy:(TFHppleElement *)chatColElement
{
    NSArray *colChatChild =chatColElement.children;
    NSString    *colChatContent = [[colChatChild objectAtIndex:0] content];
    NSData* htmlData = [colChatContent dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableString *chatContent = [[NSMutableString alloc] init];
    BOOL isURL = NO;
    
    TFHpple *xpathParserSub = [[TFHpple alloc] initWithHTMLData:htmlData];
    NSArray *elements = [xpathParserSub searchWithXPathQuery:@"//font//font"];
    if([elements count] == 0 ){
        //Get single font
        elements = [xpathParserSub searchWithXPathQuery:@"//font"];
        if ([elements count] == 0 ) {
            elements = [xpathParserSub searchWithXPathQuery:@"//font//a"];
            if([elements count] == 0 ){
                //Get span
                elements = [xpathParserSub searchWithXPathQuery:@"//span"];
                
                if ([elements count] == 0) {
                    elements = [xpathParserSub searchWithXPathQuery:@"//a"];
                }else{
                    NSArray *temArr =[xpathParserSub searchWithXPathQuery:@"//span//a"];
                    if([temArr count]>0){
                        //Check if url
                        TFHppleElement *temp = [temArr objectAtIndex:0];
                        NSString *href = [temp objectForKey:@"href"];
                        if(href){
                            [chatContent appendString:href];
                            isURL = YES;
                        }
                    }
                    //elements = [(TFHppleElement *)[elements objectAtIndex:0] children];
                    [chatContent appendString:[self resultString:elements isURL:isURL]];

                }
            }else{
                [chatContent appendString:[self resultString:elements isURL:isURL]];
            }

        }else{
            [chatContent appendString:[self resultString:elements isURL:isURL]];
            //Check if have a-href
            elements = [xpathParserSub searchWithXPathQuery:@"//font//a"];
            if([elements count]>0){
                //Check if url
                TFHppleElement *temp = [elements objectAtIndex:0];
                NSString *href = [temp objectForKey:@"href"];
                if(href){
                    [chatContent appendString:href];
                }
            }

        }
    }else{
        
        
        [chatContent appendString:[self resultString:elements isURL:isURL]];
    }
    
    if (!chatContent || [chatContent isEqualToString:@""]) {
        //Check the /span/a/img - text combine

        [chatContent appendString: @"***"];
    }
    NSLog(@"%@",chatContent);
    return chatContent;
}

- (NSString *) resultString:(NSArray *)elements isURL: (BOOL) isURL{
    NSMutableString *tempStr = [[NSMutableString alloc] init];
    if(elements){
        if(isURL){
            for (TFHppleElement *element in [[elements objectAtIndex:0] children]) {
                NSString *str = [element content];
                if(str){
                    [tempStr appendString:str];
                }
            }

        }else{
            for (TFHppleElement *element in elements) {
                NSString *str = [element text];
                if(str){
                    [tempStr appendString:str];
                }
            }
        }
        
    }
    return tempStr;
    
}
- (NSString *) parseHTMLDataForAccess:(NSData *) data
{
    
    //NSLog(@"%s", data.bytes);
    
    NSString *sToken = @"";
    if (data) {
        TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];

        //Check if login failed
        //blockrow restore
        NSArray *elements = [xpathParser searchWithXPathQuery:@"//div[@class='blockrow restore']"];

        BOOL loginSuccess = NO;
        if(!elements || [elements count] ==0){
            loginSuccess = YES;
        }
        
        if(loginSuccess){//login success, get the security token
            NSArray *elements = [xpathParser searchWithXPathQuery:@"//head//script"];
            
            TFHppleElement *js = [elements objectAtIndex:1];
            TFHppleElement *jsChild = [js.children objectAtIndex:0];
            NSString *content = jsChild.content;
            //NSLog(@"content [%@]",content);

            NSArray *comp = [content componentsSeparatedByString:@"SECURITYTOKEN"];
            if(!comp || [comp count] <2){
                return nil;
            }
            NSString *securtityStr = [comp objectAtIndex:1];
            //Extract the SECURITYTOKEN out
            sToken = [securtityStr substringWithRange:NSMakeRange(4, 51)];
            
            NSRange range = [ sToken rangeOfString:@"IMG"];
            if (range.location != NSNotFound) {

                sToken = ACCSEE_LOGIN_CORRUPT;
            }
            NSLog(@"Token [%@]",sToken);
        }else{
            sToken = ACCSEE_LOGIN_FAILED;
        }
    }
    return sToken;
}
- (NSArray *) parseHTMLDataForHistory:(NSData *) data
{

    NSString *str1 = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",str1);

    NSArray *chats = nil;
    if (data) {
        //Will not check if it is UTF-8, as Xbox Skyer is;
        //Tranform from NSData to THPPLE
        TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
        
        NSArray *elements = [xpathParser searchWithXPathQuery:@"//body//table[@class='block mgc_cb_evo_block_chatbit']//tbody//td//span"];
        
        NSArray *idElements = [xpathParser searchWithXPathQuery:@"//body//table[@class='block mgc_cb_evo_block_chatbit']//tbody//td[@class='alt2']"];
        int index = 0;
        if([elements count]!=0){
            //Initialize the ChatData
            NSMutableArray *mChats = [[NSMutableArray alloc] initWithCapacity:[elements count]];

            NSMutableString *speakerAndTime = nil;
            NSMutableString *text = nil;
            NSMutableString *imgSrc = nil;
            for (TFHppleElement *span in elements) {
                //Get the nodes of history chats
                //TFHppleElement *span = [elements objectAtIndex:0];
                //index ++;
                //NSLog(@"********************* %d *****************",index);
                //Get <a> node to get speaker and time
                NSArray   *aNodeArr = [span searchWithXPathQuery:@"//a"];
                TFHppleElement *aNode = [aNodeArr objectAtIndex:0];//First and only one
                speakerAndTime = [[NSMutableString alloc]initWithString:[aNode text]];
                
                //get img node to get the img url
                NSArray   *imgNodeArr = [aNode searchWithXPathQuery:@"//img"];
                TFHppleElement *imgNode = [imgNodeArr objectAtIndex:0];
                imgSrc = [[NSMutableString alloc] initWithString:@"http://www.xbox-skyer.com/"];
                [imgSrc appendString:[imgNode objectForKey:@"src"]];//Get the img node value
                
                //get chat content
                NSArray *fontNodeArr = [span searchWithXPathQuery:@"//font//font"];
                text = [[NSMutableString alloc]init];
                if([fontNodeArr count]){
                    TFHppleElement *fontNode = [fontNodeArr objectAtIndex:0];
                    [text appendString:[fontNode text] == nil?@"":[fontNode text]];

                    NSArray *hrefNodeArr = [fontNode searchWithXPathQuery:@"//a"];
                    if([hrefNodeArr count] >0){
                        //Has sub element
                        TFHppleElement *hrefNode = [hrefNodeArr objectAtIndex:0];
                        [text appendString:[hrefNode text]];
                    }
                }else{
                    //loop children for text child
                    fontNodeArr = [span searchWithXPathQuery:@"//font"];

                    if([fontNodeArr count]){
                        TFHppleElement *fontNode = [fontNodeArr objectAtIndex:0];
                        [text appendString:[fontNode text] == nil?@"":[fontNode text]];
                        
                        NSArray *hrefNodeArr = [fontNode searchWithXPathQuery:@"//a"];
                        if([hrefNodeArr count] >0){
                            //Has sub element
                            TFHppleElement *hrefNode = [hrefNodeArr objectAtIndex:0];
                            [text appendString:[hrefNode text]];
                        }
                    }else{
                        TFHppleElement *node = [span.children objectAtIndex:4];
                        text = [[NSMutableString alloc]initWithString:node.content];
                    }
                }

                
                
                //Format string
                NSRange substr1 = [text rangeOfString:@"\r\n\t\t\t\t\r\n\t\t\t"]; // 字符串查找,可以判断字符串中是否有
                if (substr1.location != NSNotFound) {
                    [text deleteCharactersInRange: substr1] ;// 字符串删除
                }

                
                NSRange substr2 = [speakerAndTime rangeOfString:@"&nbsp"]; // 字符串查找,可以判断字符串中是否有
                if (substr2.location != NSNotFound) {
                    [speakerAndTime deleteCharactersInRange: substr2] ;// 字符串删除
                }
                
                //Split speaker & time
                NSArray *array = [speakerAndTime  componentsSeparatedByString:@" "];
                
                
                
                //Get chatid
                
                TFHppleElement *elementChatID = [idElements objectAtIndex:index];
                index++;
                NSString *chatS = [elementChatID objectForKey:@"id"];
                
                NSArray *chatArr = [chatS componentsSeparatedByString:@"_"];
                
                
                
                //setup ChatData
                ChatData *chat = [[ChatData alloc]init];
                
                //Set value here
                chat.chatId = chatArr[1];
                chat.speaker = [array objectAtIndex:0];
                chat.dateString = [NSString stringWithFormat:@"%@ %@",[array objectAtIndex:1],[array objectAtIndex:2]];
                chat.content = text;
                chat.icon = imgSrc;
                
                [mChats addObject:chat];
            }
            chats = mChats;
        }
    }
    if(!chats){
        chats = [[NSArray alloc]init];
    }
    return chats;
}


//Determine if the html encoded with UTF8
@end
