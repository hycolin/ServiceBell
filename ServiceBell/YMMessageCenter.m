//
//  YMMessageCenter.m
//  ServiceBell
//
//  Created by chenwang on 14-1-22.
//  Copyright (c) 2014年 yomi. All rights reserved.
//

#import "YMMessageCenter.h"
#import "ASIHTTPRequest.h"
#import "YMAccountHelper.h"
#import "YMAppDelegate.h"

static YMMessageCenter *_instance;

@interface YMMessageCenter () <ASIHTTPRequestDelegate>

@property (nonatomic, strong) ASIHTTPRequest *unreadMessageRequest;
@property (nonatomic, strong) ASIHTTPRequest *readMessageRequest;

@end

@implementation YMMessageCenter
{
    NSMutableArray *_msgList;
}
@synthesize msgList = _msgList;

+ (void)initialize
{
    _instance = [[YMMessageCenter alloc] init];
}

+ (YMMessageCenter *)defaultCenter
{
    return _instance;
}

- (id)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        _msgList = [NSMutableArray array];
    }
    return self;
}

- (void)start
{
}

- (void)applicationDidBecomeActive:(id)n
{
    [self checkMessage];
}

- (NSUInteger)msgCount
{
    return [self.msgList count];
}

- (void)checkMessage
{
    if ([[YMAccountHelper instance] isLogin]) {
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/unreadmessage?userid=%@", [YMAppDelegate instance].mainDomain, [YMAccountHelper instance].userId]]];
        request.defaultResponseEncoding = NSUTF8StringEncoding;
        request.delegate = self;
        self.unreadMessageRequest = request;
        [self.unreadMessageRequest startAsynchronous];
    } else {
        [self performSelector:@selector(checkMessage) withObject:nil afterDelay:3];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSDictionary *dict = [request.responseString JSONValue];
    if (((NSNumber *)[dict objectForKey:@"success"]).boolValue) {
        if (self.unreadMessageRequest == request) {
            NSInteger oldMsgCount = self.msgCount;
            [_msgList removeAllObjects];
            [_msgList addObjectsFromArray:(NSArray *)dict[@"bellmsglist"]];
            if ([YMAccountHelper instance].nickName.length == 0) {
                [_msgList addObject:@{
                                      @"type": @(2),
                                      @"action": @"register",
                                      @"title": @"你还没有名字哦～",
                                      @"content": @"点击此处给自己取个别名吧",
                                      }];
            }
            [self parseMessage];
            if (oldMsgCount != self.msgCount) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"MessageCountChanged" object:nil];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MessageChanged" object:nil];
            [self performSelector:@selector(checkMessage) withObject:nil afterDelay:1];
        } else if (self.readMessageRequest == request) {
            [self checkMessage];
        }
    } else {
        [self performSelector:@selector(checkMessage) withObject:nil afterDelay:3];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (self.unreadMessageRequest == request) {
        [self performSelector:@selector(checkMessage) withObject:nil afterDelay:3];
    }
}

- (void)parseMessage
{
    for (NSDictionary *dict in self.msgList) {
        NSInteger type = ((NSNumber *)dict[@"type"]).integerValue;
        NSString *action = (NSString *)dict[@"action"];
        NSInteger shopId = ((NSNumber *)dict[@"shopid"]).integerValue;
        NSInteger roomId = ((NSNumber *)dict[@"roomid"]).integerValue;
        
        if (type == 2 && [action isEqualToString:@"rate"] && [YMAccountHelper instance].shopId == shopId && [YMAccountHelper instance].roomId == roomId) {
            [YMAccountHelper instance].shopId = 0;
            [YMAccountHelper instance].roomId = 0;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"notifyExitRoom" object:nil];
        } else if (type == 1 && [action isEqualToString:@"alert"]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:dict[@"title"] message:dict[@"content"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertView show];
        }
    }
}

- (void)readMsg:(NSInteger)msgId
{
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/readmsg?userid=%@&messageid=%d", [YMAppDelegate instance].mainDomain, [YMAccountHelper instance].userId, msgId]]];
    request.delegate = self;
    self.unreadMessageRequest = request;
    [self.unreadMessageRequest startAsynchronous];
}

@end
