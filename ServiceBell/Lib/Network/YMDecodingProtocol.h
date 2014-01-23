//
//  EDDecodingProtocol.h
//  EDrivel
//
//  Created by chen wang on 11-11-20.
//  Copyright (c) 2011年 bonet365.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YMDecodingFactory;

@protocol YMDecodingProtocol <NSObject>

- (id)initWithData:(NSDictionary *)data;
+ (YMDecodingFactory *)decodingFactory;

@end
