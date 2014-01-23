//
//  YMImageView.m
//  YM
//
//  Created by chen wang on 12-2-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "YMImageView.h"
#import "YMRequest.h"

@implementation YMImageView
@synthesize delegate;
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib {
}

+ (YMMemCache *)memCache {
	static YMMemCache *cache = nil;
	if(cache == nil) {
		cache = [[YMMemCache alloc] initWithMaxSize:128 maxLifetime:0];
	}
	return cache;
}

- (void)setImageUrl:(NSString *)url {
    dlog(@"%@", url);
    if ([url isEqual:[NSNull null]] || url.length == 0) {
        if ([delegate respondsToSelector:@selector(noImage)]) {
            self.image = [delegate noImage];  
            if ([delegate respondsToSelector:@selector(didFailedLoadImage:)]) {
                [delegate didFailedLoadImage:self];
            }
        }
        return;
    }
    
    NSData *imageData = nil;
    if ([url hasPrefix:@"file://"]) {
        NSString *filePath = [url substringFromIndex:[url rangeOfString:@"file://"].length];
        imageData = [NSData dataWithContentsOfFile:filePath];
    } else {
        imageData = [[YMImageView memCache] objectForKey:url];
        
        if (imageData == nil) {
            imageData = [[YMRequest imageCache] fetch:url];
        }
    }
    if (imageData) {
        self.image = [UIImage imageWithData:imageData]; 
        if ([delegate respondsToSelector:@selector(didFinishLoadImage:)]) {
            [delegate didFinishLoadImage:self];
        }
    } else {
        if ([delegate respondsToSelector:@selector(loadingImage)]) {
            self.image = [delegate loadingImage];            
        }
        REQUEST_RELEASE_SAFELY(photoRequest);
        photoRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
        photoRequest.delegate = self;
        [photoRequest startAsynchronous];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSData *data = request.responseData;
    if (data) {
        UIImage *image = [UIImage imageWithData:data]; 
        if (image) {
            self.image = image;
            [[YMRequest imageCache] push:data forKey:request.url.absoluteString];
            if ([delegate respondsToSelector:@selector(didFinishLoadImage:)]) {
                [delegate didFinishLoadImage:self];
            }
        } else {
            if ([delegate respondsToSelector:@selector(noImage)]) {
                self.image = [delegate noImage];            
            }
            if ([delegate respondsToSelector:@selector(didFailedLoadImage:)]) {
                [delegate didFailedLoadImage:self];
            }
        }
    } else{
        if ([delegate respondsToSelector:@selector(noImage)]) {
            self.image = [delegate noImage];            
        }
        [delegate didFailedLoadImage:self];
    }
    REQUEST_RELEASE_SAFELY(photoRequest);
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    if ([delegate respondsToSelector:@selector(didFailedLoadImage:)]) {
        [delegate didFailedLoadImage:self];
    }
    dlog(@"%@", [request error]);
    if ([delegate respondsToSelector:@selector(noImage)]) {
        self.image = [delegate noImage];            
    }
    REQUEST_RELEASE_SAFELY(photoRequest);
}

- (void)dealloc {
    REQUEST_RELEASE_SAFELY(photoRequest);
    [super dealloc];
}

@end
