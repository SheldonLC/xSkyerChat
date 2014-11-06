//
//  Theme.m
//  XSkyerChatroom
//
//  Created by Yin Bo on 14/11/6.
//  Copyright (c) 2014年 SheldonLC. All rights reserved.
//

#import "Theme.h"
#import "Constants.h"
@implementation Theme



-(BOOL)isDefaultMode{
    
    return [self.currentMode isEqualToString: THEME_DAFAULT_MODE];
}


-(BOOL)isNightMode{
    
    return [self.currentMode isEqualToString:THEME_NIGHT_MODE];
}

- (instancetype)init{
    self = [super init];
    
    
    self.currentMode = THEME_DAFAULT_MODE;
    
    self.speakerColor = [UIColor blueColor];
    self.chatColor = [UIColor blackColor];
    self.chatHighlightedColor = [UIColor brownColor];
    self.speakerHighlightedColor = [UIColor brownColor];

    self.chatbackgroundColor = [UIColor grayColor];

    self.chatbackgroundHighlightedColor = [UIColor grayColor];;
    self.setImage = nil;
    self.chatImage = nil;
    self.navbarColor = nil;
    self.toolbarColor = nil;
    self.setViewBackgroundColor= nil;
    self.SetViewContentColor = nil;

    
    return self;
}
@end
