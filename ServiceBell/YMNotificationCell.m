//
//  YMNotificationCell.m
//  ServiceBell
//
//  Created by chenwang on 14-1-23.
//  Copyright (c) 2014年 yomi. All rights reserved.
//

#import "YMNotificationCell.h"

@implementation YMNotificationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)showMessage:(NSString *)title content:(NSString *)content isRead:(BOOL)isRead
{
    self.titleLabel.text = title;
    self.contentLabel.text = content;
    self.badgeImageView.hidden = isRead;
}

@end
