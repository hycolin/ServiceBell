//
//  YMMailComposeViewController.h
//  FortuneMobile
//
//  Created by chen wang on 12-7-15.
//  Copyright (c) 2012年 yomi.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface YMMailComposeViewController : MFMailComposeViewController

+ (BOOL)canSendMail;

@end
