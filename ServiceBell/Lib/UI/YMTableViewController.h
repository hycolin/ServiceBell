//
//  EDTableViewController.h
//  EDrivel
//
//  Created by chen wang on 11-11-22.
//  Copyright (c) 2011年 bonet365.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMViewController.h"
#import "EGORefreshTableHeaderView.h"

@interface YMTableViewController : YMViewController <UIScrollViewDelegate, EGORefreshTableHeaderDelegate> {
    EGORefreshTableHeaderView *refreshHeaderView;
    BOOL _isLoading;
}

@property (nonatomic) BOOL shouldDragRefresh;
@property (retain, nonatomic) IBOutlet UITableView *tableView;

//刷新数据
- (void)refreshData;
- (void)refreshComplete;

//请求更多数据
- (void)requestMoreData;

- (UITableViewCell *)dequeueLoadingCell;

@end
