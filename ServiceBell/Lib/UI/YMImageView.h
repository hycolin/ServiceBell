//
//  YMImageView.h
//  YM
//
//  Created by chen wang on 12-2-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "YMMemCache.h"

@class YMImageView;
@protocol YMImageViewDelegate <NSObject>

@optional
- (UIImage *)noImage;
- (UIImage *)loadingImage;
- (void)didFinishLoadImage:(YMImageView *)imageView;
- (void)didFailedLoadImage:(YMImageView *)imageView;

@end
@interface YMImageView : UIImageView <ASIHTTPRequestDelegate> {
    ASIHTTPRequest *photoRequest;
}
@property (nonatomic, assign) id<YMImageViewDelegate> delegate;

- (void)setImageUrl:(NSString *)url;

+ (YMMemCache *)memCache;

@end
