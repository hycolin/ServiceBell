//
//  NSDate+Util.m
//  EDrivel
//
//  Created by chen wang on 11-12-21.
//  Copyright (c) 2011年 bonet365.com. All rights reserved.
//

#import "NSDate+Util.h"

@implementation NSDate (Format)

- (NSString *)formatRelative {
	return [self formatRelativeWithTime:YES];
}

- (NSString *)formatRelativeWithTime:(BOOL)ti {
    NSDate *now = [NSDate date];
    NSTimeInterval t = [self timeIntervalSinceDate:now];
    if (fabs(t) < 60) {
        return @"刚刚";
    } else if (t > -60 * 60 && t < -60) { //显示分钟
        return [NSString stringWithFormat:@"%d分钟以前", (int)(-t/60)];
    } else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *result = [dateFormatter stringFromDate:self];
        [dateFormatter release];
        return result;
    }
}

+ (NSDate *)localDate {
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    return [date dateByAddingTimeInterval:interval];
}

@end