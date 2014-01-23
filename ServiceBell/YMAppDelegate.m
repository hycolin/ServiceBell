//
//  YMAppDelegate.m
//  ServiceBell
//
//  Created by chenwang on 14-1-19.
//  Copyright (c) 2014年 yomi. All rights reserved.
//

#import "YMAppDelegate.h"
#import "YMMainViewController.h"
#import "YMUserCenterViewController.h"
#import "ASIHTTPRequest.h"
#import "OpenUDID.h"
#import "YMAccountHelper.h"

@interface YMAppDelegate () <ASIHTTPRequestDelegate>

@property (nonatomic, strong) YMMainViewController *mainViewController;

@end

@implementation YMAppDelegate

+ (YMAppDelegate *)instance
{
    return (YMAppDelegate *)[UIApplication sharedApplication].delegate;
}

- (NSString *)mainDomain
{
#ifdef TEST
    return @"127.0.0.1:8888";
#else
    return @"121.207.228.51:8888";
#endif
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    self.mainViewController = [[YMMainViewController alloc] init];
    UINavigationController *naviController = [[UINavigationController alloc] initWithRootViewController:self.mainViewController];
    
    UINavigationController *leftNaviController = [[UINavigationController alloc] initWithRootViewController:[[YMUserCenterViewController alloc] init]];
    self.drawerController = [[MMDrawerController alloc]
                             initWithCenterViewController:naviController
                             rightDrawerViewController:leftNaviController];
    [self.drawerController setMaximumRightDrawerWidth:260];
    [self.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [self.drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    
    self.window.rootViewController = self.drawerController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
    [[YMAccountHelper instance] loginWithSuccess:nil failed:nil];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
