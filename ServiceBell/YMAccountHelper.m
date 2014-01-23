//
//  YMAccountHelper.m
//  ServiceBell
//
//  Created by chenwang on 14-1-19.
//  Copyright (c) 2014年 yomi. All rights reserved.
//

#import "YMAccountHelper.h"
#import "ASIHTTPRequest.h"
#import "YMAppDelegate.h"
#import "OpenUDID.h"



@interface YMAccountHelper () <ASIHTTPRequestDelegate>

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) YMLoginBlock successBlock;
@property (nonatomic, strong) YMLoginBlock failedBlock;

@property (nonatomic, strong) ASIHTTPRequest *loginRequest;
@end

static YMAccountHelper *_instance;
@implementation YMAccountHelper

+ (void)initialize
{
    _instance = [[YMAccountHelper alloc] init];
}

+ (YMAccountHelper *)instance
{
    return _instance;
}

- (id)init
{
    if (self = [super init]) {
        _userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
        _nickName = [[NSUserDefaults standardUserDefaults] objectForKey:@"nickName"];
    }
    return self;
}

- (BOOL)isLogin
{
    return self.userId > 0;
}

- (BOOL)isGotoRoom
{
    return self.shopId > 0 && self.roomId > 0;
}

- (void)loginWithSuccess:(YMLoginBlock)successBlock failed:(YMLoginBlock)failedBlock
{
    if ([self isLogin]) {
        if (successBlock) {
            successBlock();
        }
        return;
    }
    self.successBlock = successBlock;
    self.failedBlock = failedBlock;
    
    if (self.loginRequest) {
        return;
    }
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/userlogin?deviceid=%@", [[YMAppDelegate instance] mainDomain], [OpenUDID value]]]];
    request.defaultResponseEncoding = NSUTF8StringEncoding;
    request.delegate = self;
    self.loginRequest = request;
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSDictionary *dict = [request.responseString JSONValue];
    if ([dict objectForKey:@"success"]) {
        NSDictionary *userDict = [dict objectForKey:@"user"];
        self.userId = [userDict objectForKey:@"userId"];
        NSString *tempNickName = [userDict objectForKey:@"nick"];
        if ([tempNickName isEqualToString:@"匿名"]) {
            tempNickName = nil;
        }
        self.nickName = tempNickName;
        
        if (self.successBlock) {
            self.successBlock();
        }
    } else {
        if (self.failedBlock) {
            self.failedBlock();
        }
    }
    self.loginRequest = nil;
}

- (void)setUserId:(NSString *)userId
{
    _userId = userId;
    [[NSUserDefaults standardUserDefaults]  setObject:self.userId forKey:@"userId"];
}

- (void)setNickName:(NSString *)nickName
{
    _nickName = nickName;
    [[NSUserDefaults standardUserDefaults]  setObject:self.nickName forKey:@"nickName"];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (self.failedBlock) {
        self.failedBlock();
    }
    self.loginRequest = nil;
}

@end
