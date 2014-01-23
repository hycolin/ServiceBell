//
//  EDViewController.h
//  EDrivel
//
//  Created by chen wang on 11-11-19.
//  Copyright (c) 2011年 bonet365.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface YMViewController : UIViewController {
    NSString *_string;   
    
    MBProgressHUD *hud;
}


- (void)showWaiting:(NSString *)text;
- (void)showWaiting:(NSString *)text withView:(UIView *)view;
- (void)hideWaiting;

- (void)showSplash:(NSString *)text;
- (void)showSplash:(NSString *)text detailText:(NSString *)detailText;
- (void)showSplash:(NSString *)text delegate:(id<MBProgressHUDDelegate>)delegate tag:(NSInteger)tag;
- (void)showSplash:(NSString *)text detailText:(NSString *)detailText delegate:(id<MBProgressHUDDelegate>)delegate tag:(NSInteger)tag;

- (void)showAlert:(NSString *)text;

@end
