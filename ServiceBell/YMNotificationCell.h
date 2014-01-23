//
//  YMNotificationCell.h
//  ServiceBell
//
//  Created by chenwang on 14-1-23.
//  Copyright (c) 2014年 yomi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YMNotificationCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *badgeImageView;

- (void)showMessage:(NSString *)title content:(NSString *)content isRead:(BOOL)isRead;

@end
