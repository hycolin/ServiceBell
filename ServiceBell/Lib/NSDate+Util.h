//
//  NSDate+Util.h
//  EDrivel
//
//  Created by chen wang on 11-12-21.
//  Copyright (c) 2011年 bonet365.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Format)

- (NSString *)formatRelative;

- (NSString *)formatRelativeWithTime:(BOOL)t;

+ (NSDate *)localDate;

@end