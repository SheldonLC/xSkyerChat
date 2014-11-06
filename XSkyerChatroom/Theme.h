//
//  Theme.h
//  XSkyerChatroom
//
//  Created by Yin Bo on 14/11/6.
//  Copyright (c) 2014年 SheldonLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Theme : NSObject

@property (strong,nonatomic) NSString *currentMode;

@property (strong,nonatomic) UIColor *speakerColor;
@property (strong,nonatomic) UIColor *chatColor;
@property (strong,nonatomic) UIColor *chatHighlightedColor;
@property (strong,nonatomic) UIColor *speakerHighlightedColor;
@property (strong,nonatomic) UIColor *chatbackgroundColor;
@property (strong,nonatomic) UIColor *chatbackgroundHighlightedColor;
@property (strong,nonatomic) UIImage *setImage;
@property (strong,nonatomic) UIImage *chatImage;
@property (strong,nonatomic) UIColor *navbarColor;
@property (strong,nonatomic) UIColor *toolbarColor;
@property (strong,nonatomic) UIColor *setViewBackgroundColor;
@property (strong,nonatomic) UIColor *SetViewContentColor;


- (BOOL) isNightMode;
- (BOOL) isDefaultMode;

@end
