//
//  EDDecodingFactory.m
//  EDrivel
//
//  Created by chen wang on 11-11-20.
//  Copyright (c) 2011年 bonet365.com. All rights reserved.
//

#import "YMDecodingFactory.h"

@implementation YMDecodingFactory

- (id)initWithClass:(Class)class {
    self = [super init];
    if (self) {
        // Initialization code here.
        _class = class;
    }
    
    return self;
}

- (id<YMDecodingProtocol>)createInstance {
    return [[_class alloc] autorelease];
}

@end
