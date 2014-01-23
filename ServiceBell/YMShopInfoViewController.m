//
//  YMShopInfoControllerViewController.m
//  ServiceBell
//
//  Created by chenwang on 14-1-19.
//  Copyright (c) 2014年 yomi. All rights reserved.
//

#import "YMShopInfoViewController.h"
#import "YMAccountHelper.h"
#import "YMAppDelegate.h"
#import "ASIHTTPRequest.h"

@interface YMShopInfoViewController () <UITableViewDataSource, UITableViewDelegate, ASIHTTPRequestDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *bellLayout;
@property (strong, nonatomic) IBOutlet UIView *shopInfoHeader;

@property (strong, nonatomic) IBOutlet UITableViewCell *cell1;
@property (strong, nonatomic) IBOutlet UITableViewCell *cell2;

@property (nonatomic, strong) ASIHTTPRequest *bellRequest;
@property (nonatomic, strong) ASIHTTPRequest *exitRequest;

@end

@implementation YMShopInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyExitRoom) name:@"notifyExitRoom" object:nil];
    }
    return self;
}

- (void)notifyExitRoom
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (IBAction)wifiAction:(id)sender {
    NSString *wifiPwd = @"12345678";
    UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];
    [gpBoard setValue:wifiPwd forPasteboardType:@"public.utf8-plain-text"];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"WiFi: iKangDao\n密码:%@\n(密码已拷贝,直接粘贴)", wifiPwd] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertView show];
}

- (IBAction)exitRoom:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定要退出？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        [self showWaiting:@"正在退出..."];
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/exitroom?shopid=%d&roomid=%d&userid=%@", [YMAppDelegate instance].mainDomain, [YMAccountHelper instance].shopId, [YMAccountHelper instance].roomId, [YMAccountHelper instance].userId]]];
        request.delegate = self;
        self.exitRequest = request;
        [request startAsynchronous];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"%@房间", [YMAccountHelper instance].roomName];
    self.tableView.tableHeaderView = self.shopInfoHeader;
}

- (IBAction)bellAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSString *status = [button titleForState:UIControlStateNormal];

    [self showWaiting:@"正在呼叫..."];
    
    NSInteger shopId = [YMAccountHelper instance].shopId;
    NSInteger roomId = [YMAccountHelper instance].roomId;
    NSString *userId = [YMAccountHelper instance].userId;

    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/bell?shopid=%d&roomid=%d&userid=%@&status=%@", [YMAppDelegate instance].mainDomain, shopId, roomId, userId, [status stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
    request.delegate = self;
    self.bellRequest = request;
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [self hideWaiting];
    if (request == self.bellRequest) {
        NSDictionary *dict = [request.responseString JSONValue];
        if (((NSNumber *)[dict objectForKey:@"success"]).boolValue) {
            [self showSplash:@"呼叫已送达，请耐心等候～"];
        } else {
            [self showSplash:@"服务异常，请稍候重试"];
        }
    } else if (request == self.exitRequest) {
        NSDictionary *dict = [request.responseString JSONValue];
        if (((NSNumber *)[dict objectForKey:@"success"]).boolValue) {
            [YMAccountHelper instance].shopId = 0;
            [YMAccountHelper instance].roomId = 0;
            
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self showSplash:@"服务异常，请稍候重试"];
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [self hideWaiting];
    [self showSplash:@"网络异常，请稍候重试"];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return self.cell1;
    } else {
        return self.cell2;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
