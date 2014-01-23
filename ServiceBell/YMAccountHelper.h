//
//  YMAccountHelper.h
//  ServiceBell
//
//  Created by chenwang on 14-1-19.
//  Copyright (c) 2014年 yomi. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^YMLoginBlock)(void);

@interface YMAccountHelper : NSObject

+ (YMAccountHelper *)instance;

@property (nonatomic, strong, readonly) NSString *userId;
@property (nonatomic, assign) NSInteger shopId;
@property (nonatomic, assign) NSInteger roomId;
@property (nonatomic, strong) NSString *roomName;
@property (nonatomic, strong) NSString *nickName;

- (BOOL)isLogin;
- (BOOL)isGotoRoom;

- (void)loginWithSuccess:(YMLoginBlock)successBlock failed:(YMLoginBlock)failedBlock;

@end
