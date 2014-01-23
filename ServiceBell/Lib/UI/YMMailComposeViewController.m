//
//  YMMailComposeViewController.m
//  FortuneMobile
//
//  Created by chen wang on 12-7-15.
//  Copyright (c) 2012年 yomi.com. All rights reserved.
//

#import "YMMailComposeViewController.h"

@interface YMMailComposeViewController ()

@end

@implementation YMMailComposeViewController

+ (BOOL)canSendMail 
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass && [mailClass canSendMail]) {
        return YES;
    }
    return NO;
}

@end
