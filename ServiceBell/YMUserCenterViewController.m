//
//  YMUserCenterViewController.m
//  ServiceBell
//
//  Created by chenwang on 14-1-19.
//  Copyright (c) 2014年 yomi. All rights reserved.
//

#import "YMUserCenterViewController.h"
#import "YMMessageCenter.h"
#import "YMNotificationCell.h"
#import "NVShopRate.h"
#import "PXAlertView.h"
#import "ASIHTTPRequest.h"
#import "YMAppDelegate.h"
#import "YMAccountHelper.h"

@interface YMUserCenterViewController () <UITableViewDataSource, UITableViewDelegate, ASIHTTPRequestDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *messageList;
@property (nonatomic, strong) NSDictionary *currentSelectedMessage;
@property (nonatomic, strong) NVShopRate *shopRate;

@property (nonatomic, strong) ASIHTTPRequest *rateRequest;
@property (nonatomic, strong) ASIHTTPRequest *nickRequest;

@end

@implementation YMUserCenterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageChanged) name:@"MessageChanged" object:nil];
        self.messageList = [NSMutableArray array];
    }
    return self;
}

- (void)messageChanged
{
    [self.messageList removeAllObjects];
    [self.messageList addObjectsFromArray:[YMMessageCenter defaultCenter].msgList];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *nick = [YMAccountHelper instance].nickName;
    if (nick.length == 0) {
        self.title = @"待办事项";
    } else {
        self.title = [NSString stringWithFormat:@"%@的待办事项", nick];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [self.messageList count];
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        YMNotificationCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (cell == nil) {
            NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"YMNotificationCell" owner:nil options:nil];
            cell = views[0];
        }
        NSDictionary *msg = [self.messageList objectAtIndex:indexPath.row];
        [cell showMessage:msg[@"title"] content:msg[@"content"] isRead:NO];
        return cell;        
    } else {
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        }
        NSString *text = nil;
        switch (indexPath.row) {
            case 0:
                text = @"";
                break;
                
            default:
                break;
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        self.currentSelectedMessage = [self.messageList objectAtIndex:indexPath.row];
        NSString *action = self.currentSelectedMessage[@"action"];
        if ([action isEqualToString:@"rate"]) {
            self.shopRate = [[NVShopRate alloc] initWithFrame:CGRectMake(30, 60, 185, 36)];
            [PXAlertView showAlertWithTitle:@"康道按摩(南京西路店)"
                                    message:nil
                                cancelTitle:@"取消"
                                 otherTitle:@"提交"
                                contentView:self.shopRate
                                 completion:^(BOOL cancelled, NSInteger buttonIndex) {
                                     if (!cancelled) {
                                         NSDictionary *msg = self.currentSelectedMessage;
                                         [self rate:((NSNumber *)msg[@"shopid"]).integerValue roomId:((NSNumber *)msg[@"roomid"]).integerValue];
                                     }
                                 }];
        } else if ([action isEqualToString:@"register"]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"输入自己的呢称" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"提交", nil];
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alertView show];
        }
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        NSString *nick = [[alertView textFieldAtIndex:0].text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (nick.length > 0) {
            [self nick:nick];
        }
    }
}

- (void)rate:(NSInteger)shopId roomId:(NSInteger)roomId
{
    [self showWaiting:@"正在提交..."];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/rate?userid=%@&shopid=%d&rate=%d", [YMAppDelegate instance].mainDomain, [YMAccountHelper instance].userId, shopId, self.shopRate.rate]]];
    request.delegate = self;
    self.rateRequest = request;
    [request startAsynchronous];
}

- (void)nick:(NSString *)nickName
{
    [self showWaiting:@"正在提交..."];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/updatenick?userid=%@&nick=%@", [YMAppDelegate instance].mainDomain, [YMAccountHelper instance].userId, [nickName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
    request.delegate = self;
    self.nickRequest = request;
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [self hideWaiting];
    NSDictionary *dict = [request.responseString JSONValue];
    if (((NSNumber *)[dict objectForKey:@"success"]).boolValue) {
        if (self.rateRequest == request) {
            [[YMMessageCenter defaultCenter] readMsg:((NSNumber *)self.currentSelectedMessage[@"id"]).integerValue];
            [self showSplash:@"提交成功"];
            [self.messageList removeObject:self.currentSelectedMessage];
            [self.tableView reloadData];
        } else if (self.nickRequest == request) {
            NSString *nick = dict[@"nick"];
            [YMAccountHelper instance].nickName = nick;
            self.title = [NSString stringWithFormat:@"%@的待办事项", nick];
            [self showSplash:@"提交成功"];
            [self.messageList removeObject:self.currentSelectedMessage];
            [self.tableView reloadData];
        }
    } else {
        [self showSplash:@"服务异常，请稍候重试"];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [self hideWaiting];
    [self showSplash:@"网络异常，请稍候重试"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
