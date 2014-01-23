//
//  EDRequest.h
//  EDrivel
//
//  Created by chen wang on 11-11-20.
//  Copyright (c) 2011年 bonet365.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YMDecodingFactory.h"
#import "ASIFormDataRequest.h"
#import "YMImageCache.h"

@class YMRequest;
@protocol YMRequestDelegate <NSObject>

- (void)requestFinished:(YMRequest *)request;
- (void)requestFailed:(YMRequest *)request;

@end

@interface YMRequest : ASIFormDataRequest <ASIHTTPRequestDelegate> {
}

@property (nonatomic, retain) id result;
@property (nonatomic, retain) id<YMRequestDelegate> requestDelegate;
@property (nonatomic, retain) YMDecodingFactory *decodeingFactory;

+ (YMImageCache *)imageCache;

@end
