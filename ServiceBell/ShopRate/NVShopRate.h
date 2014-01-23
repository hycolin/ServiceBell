//
//  NVShopRate.h
//  NVScope
//
//  Created by Hui Zhou on 10-8-17.
//  Copyright 2010 dianping.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kShopRateWidth	210
#define kShopRateHeight	42


@protocol NVShopRateTouchEndDelegate <NSObject>
// 用户操作完星星之后AddReviewController会回调该方法
- (void)shopRateTouchEndFinished;
@end
@interface NVShopRate : UIView {
	UIImageView	*star1;
	UIImageView	*star2;
	UIImageView	*star3;
	UIImageView	*star4;
	UIImageView	*star5;
	
	NSUInteger	_rate;
	NSUInteger  _touchRate;
    
}



@property (nonatomic, assign) NSUInteger rate;

@property (nonatomic, assign) NSUInteger lessRate;

@property (nonatomic, assign, readonly) id <NVShopRateTouchEndDelegate> onToucheEndDelegate;

- (void)setTouchEndDelegate:(id <NVShopRateTouchEndDelegate>) delegate;

- (void)setStarRate:(NSInteger) starRate;

- (void)setRateStarSize:(CGSize) size;

@end

