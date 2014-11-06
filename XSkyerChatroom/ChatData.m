//
//  ChatData.m
//  XSkyerChatroom
//
//  Created by Yin Bo on 14/10/29.
//  Copyright (c) 2014年 SheldonLC. All rights reserved.
//

#import "ChatData.h"
@interface ChatData ()

//Define the VO

@end

@implementation ChatData


- (BOOL) ownedByUser : (NSString *) user{
    
    return [[user uppercaseString] isEqualToString:[self.speaker uppercaseString]];
}



-(void)setContent:(NSString *)content
{
    _content = content;
}

- (BOOL)determineIfFromMeBy : (NSString *) currentUser{
    if ([currentUser isEqualToString:self.speaker]) {
        return YES;
    }
    return NO;
}

- (BOOL)matchedWith:(ChatData *)anotherChat{
    return [self.chatId isEqualToString:anotherChat.chatId];

}
- (BOOL) newerThan: (ChatData *) anotherChat{

    NSInteger currentID = [self.chatId integerValue];
    NSInteger otherID = [anotherChat.chatId integerValue];

    return currentID>otherID;
}

- (BOOL) olderThan: (ChatData *) anotherChat{
    
    NSInteger currentID = [self.chatId integerValue];
    NSInteger otherID = [anotherChat.chatId integerValue];
    
    return currentID<otherID;
}

@end
