//
//  EDViewController.m
//  EDrivel
//
//  Created by chen wang on 11-11-19.
//  Copyright (c) 2011年 bonet365.com. All rights reserved.
//

#import "YMViewController.h"

@implementation YMViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)showSplash:(NSString *)text delegate:(id<MBProgressHUDDelegate>)delegate tag:(NSInteger)tag {
    [self showSplash:text detailText:nil delegate:delegate tag:tag];
}

- (void)showSplash:(NSString *)text detailText:(NSString *)detailText delegate:(id<MBProgressHUDDelegate>)delegate tag:(NSInteger)tag {
    REMOVESUBVIEW_SAFELY(hud);
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.tag = tag;
    hud.delegate = delegate;
    hud.labelText = text;
    hud.detailsLabelText = detailText;
    hud.mode = MBProgressHUDModeNone;
    [hud show:YES];  
    [hud hide:YES afterDelay:3];
}

- (void)showSplash:(NSString *)text {
    [self showSplash:text delegate:nil tag:0];
}

- (void)showSplash:(NSString *)text detailText:(NSString *)detailText {
    [self showSplash:text detailText:detailText delegate:nil tag:0];
}

- (void)hideSplash:(UIAlertView *)alertView {
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)showWaiting:(NSString *)text withView:(UIView *)view {
    REMOVESUBVIEW_SAFELY(hud);
    hud = [[MBProgressHUD alloc] initWithView:view];
    [self.view addSubview:hud];
    hud.labelText = text;
    [hud show:YES];    
}

- (void)showWaiting:(NSString *)text {
    [self showWaiting:text withView:self.view];
}

- (void)hideWaiting {
    [hud hide:YES];
    REMOVESUBVIEW_SAFELY(hud);
}

- (void)showAlert:(NSString *)text {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:text delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    REMOVESUBVIEW_SAFELY(hud);
    
    [super dealloc];
}

@end
