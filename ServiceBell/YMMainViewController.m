//
//  YMMainViewController.m
//  ServiceBell
//
//  Created by chenwang on 14-1-19.
//  Copyright (c) 2014年 yomi. All rights reserved.
//

#import "YMMainViewController.h"
#import "YMAppDelegate.h"
#import "ZBarSDK.h"
#import "YMShopInfoViewController.h"
#import "YMAccountHelper.h"
#import "ASIHTTPRequest.h"
#import "QuartzCore/QuartzCore.h"
#import "YMMessageCenter.h"

@interface YMMainViewController () <UITableViewDataSource, UITableViewDelegate, ZBarReaderDelegate, ASIHTTPRequestDelegate>

@property (nonatomic, strong) UIButton *badgeButton;
@end

@implementation YMMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageCountChanged) name:@"MessageCountChanged" object:nil];
        [[YMMessageCenter defaultCenter] start];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"服务铃";
    
    UIButton *myButton = [UIButton buttonWithType:UIButtonTypeSystem];
    myButton.titleLabel.font = [UIFont systemFontOfSize:17];
    myButton.frame = CGRectMake(0, 0, 50, 44);
    [myButton setTitle:@"我的" forState:UIControlStateNormal];
    [myButton addTarget:self action:@selector(gotoUserCenter) forControlEvents:UIControlEventTouchUpInside];
    self.badgeButton = [self createBadgeViewOnItem:myButton];
    self.badgeButton.hidden = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:myButton];

    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"上海站" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)messageCountChanged
{
    NSUInteger msgCount = [YMMessageCenter defaultCenter].msgCount;
    if (msgCount > 0) {
        self.badgeButton.hidden = NO;
        [self.badgeButton setTitle:[NSString stringWithFormat:@"%d", msgCount] forState:UIControlStateNormal];
    } else {
        self.badgeButton.hidden = YES;
    }
}

- (UIButton *)createBadgeViewOnItem:(UIView *)itemView {
	UIButton *_badge = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(itemView.bounds)-20, 2.0, 23.0, 25.0)];
	UIImage *badgeImage = [[UIImage imageNamed:@"BadgeImage.png"] stretchableImageWithLeftCapWidth:11 topCapHeight:0];
	[_badge setBackgroundImage:badgeImage forState:UIControlStateNormal];
	_badge.contentEdgeInsets = UIEdgeInsetsMake(0.0, 1.0, 8.0, 0.0);
	_badge.titleLabel.font = [UIFont systemFontOfSize:14];
	_badge.showsTouchWhenHighlighted = NO;
	_badge.adjustsImageWhenDisabled = NO;
	_badge.adjustsImageWhenHighlighted = NO;
	_badge.reversesTitleShadowWhenHighlighted = NO;
	_badge.userInteractionEnabled = NO;
	[itemView addSubview:_badge];
	return _badge;
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)gotoUserCenter
{
    [[YMAppDelegate instance].drawerController openDrawerSide:MMDrawerSideRight animated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    view.backgroundColor = [UIColor colorWithRed:230/255.f green:230/255.f blue:230/255.f alpha:1];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(6, 0, 300, 20)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithRed:50/255.f green:50/255.f blue:50/255.f alpha:1];
    label.text = @"正在使用服务铃的商家";
    label.font = [UIFont systemFontOfSize:13];
    [view addSubview:label];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"YMMainCell" owner:nil options:nil];
        cell = arr[indexPath.row];
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(cell.frame)-1, 320, 0.5)];
        lineView.backgroundColor = [UIColor colorWithRed:135/255.f green:135/255.f blue:135/255.f alpha:1];
        [cell addSubview:lineView];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:1000];
        imageView.layer.cornerRadius = 2;
        imageView.layer.masksToBounds = YES;
        imageView.layer.borderColor = [UIColor colorWithRed:135/255.f green:135/255.f blue:135/255.f alpha:1].CGColor;
        imageView.layer.borderWidth = 0.5f;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (IBAction)scanAction:(id)sender {
    if ([YMAccountHelper instance].roomId > 0) { //已经在某个房间
        YMShopInfoViewController *shopInfoController = [[YMShopInfoViewController alloc] init];
        [self.navigationController pushViewController:shopInfoController animated:YES];
        return;
    }
    
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    
    ZBarImageScanner *scanner = reader.scanner;
    // TODO: (optional) additional reader configuration here
    
    // EXAMPLE: disable rarely used I2/5 to improve performance
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    // present and release the controller
    [self presentViewController:reader animated:YES completion:nil];
    
    [self performSelector:@selector(simulate:) withObject:reader afterDelay:1];
}

- (void)simulate:(id)sender
{
    [self imagePickerController:sender didFinishPickingMediaWithInfo:nil];
}

- (void) imagePickerController:(UIImagePickerController*)reader didFinishPickingMediaWithInfo:(NSDictionary*) info
{
    id<NSFastEnumeration> results =
    [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        break;
    
    NSString *result = symbol.data;
#ifdef TEST
    result = @"1,1";
#endif
    dlog(@"scan result: %@", result);
    NSArray *arr = [result componentsSeparatedByString:@","];
    if (arr.count != 2) {
        return;
    }
    NSString *shopId = arr[0];
    NSString *roomId = arr[1];
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    [reader dismissViewControllerAnimated:YES completion:^(void) {
        [self showWaiting:@"正在处理中..."];
        @weakify(self);
        [[YMAccountHelper instance] loginWithSuccess:^(void){
            @strongify(self);
            NSString *urlStr = [NSString stringWithFormat:@"http://%@/gotoroom?shopid=%@&roomid=%@&userid=%@", [YMAppDelegate instance].mainDomain, shopId, roomId, [YMAccountHelper instance].userId];
            NSURL *url = [NSURL URLWithString:urlStr];
            ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
            request.delegate = self;
            [request startAsynchronous];
        } failed:^(void) {
            @strongify(self);
            [self showSplash:@"服务异常，请稍候重试"];
        }];
        
    }];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [self hideWaiting];
    NSDictionary *dict = [request.responseString JSONValue];
    if (((NSNumber *)[dict objectForKey:@"success"]).boolValue) {
        NSDictionary *roomDict = dict[@"room"];
        [YMAccountHelper instance].shopId = ((NSNumber *)roomDict[@"shopid"]).integerValue;
        [YMAccountHelper instance].roomId = ((NSNumber *)roomDict[@"id"]).integerValue;
        [YMAccountHelper instance].roomName = roomDict[@"name"];
        YMShopInfoViewController *shopInfoController = [[YMShopInfoViewController alloc] init];
        [self.navigationController pushViewController:shopInfoController animated:YES];
    } else {
        [self showSplash:dict[@"msg"]];
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
