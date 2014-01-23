//
//  YMMessageCenter.h
//  ServiceBell
//
//  Created by chenwang on 14-1-22.
//  Copyright (c) 2014年 yomi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YMMessageCenter : NSObject

+ (YMMessageCenter *)defaultCenter;

- (void)start;

@property (nonatomic, readonly) NSUInteger msgCount;
@property (nonatomic, readonly) NSArray *msgList;

- (void)readMsg:(NSInteger)msgId;

@end
