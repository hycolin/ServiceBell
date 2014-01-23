//
//  StatusMessage.h
//  Macalline
//
//  Created by chen wang on 12-5-1.
//  Copyright (c) 2012年 YoMi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YMDecodingFactory.h"
#import "YMDecodingProtocol.h"

@interface StatusMessage : NSObject <YMDecodingProtocol>

@property (nonatomic, readonly) BOOL isSuccess;
@property (nonatomic, readonly) int errorcode;
@property (nonatomic, readonly) NSString *errorInfo;

- (id)initWithErrorcode:(int)errorcode errorInfo:(NSString *)errorInfo;

@end
