//
//  StatusMessage.m
//  Macalline
//
//  Created by chen wang on 12-5-1.
//  Copyright (c) 2012年 YoMi. All rights reserved.
//

#import "StatusMessage.h"

@implementation StatusMessage

@synthesize isSuccess = _isSuccess;
@synthesize errorcode = _errorcode;
@synthesize errorInfo = _errorInfo;

- (void)dealloc {
    [_errorInfo release];
    [super dealloc];
}

- (id)initWithErrorcode:(int)errorcode errorInfo:(NSString *)errorInfo {
    self = [super init];
    if (self) {
        _isSuccess = NO;
        _errorcode = errorcode;
        _errorInfo = [errorInfo copy];
    }
    return self;
}

- (id)initWithData:(NSDictionary *)data {
    self = [super init];
    if (self) {
        _isSuccess = [[data objectForKey:@"success"] boolValue];
        _errorcode = [[data objectForKey:@"errorcode"] intValue];
        _errorInfo = [[data objectForKey:@"errorstr"] copy];
    }
    return self;
}

+ (YMDecodingFactory *)decodingFactory {
    static YMDecodingFactory *factory;
    if (factory == nil) {
        factory = [[YMDecodingFactory alloc] initWithClass:[StatusMessage class]];
    }
    return factory;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"success:%d,errorcode:%d, errorinfo:%@", _isSuccess, _errorcode, _errorInfo];
}

@end
