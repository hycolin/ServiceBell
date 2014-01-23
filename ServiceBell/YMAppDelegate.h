//
//  YMAppDelegate.h
//  ServiceBell
//
//  Created by chenwang on 14-1-19.
//  Copyright (c) 2014年 yomi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMDrawerController.h"

@interface YMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (YMAppDelegate *)instance;

@property (nonatomic, strong) MMDrawerController *drawerController;

@property (nonatomic) NSString *mainDomain;
@end
