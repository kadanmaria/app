//
//  AppDelegate.m
//  App
//
//  Created by Admin on 07.02.16.
//  Copyright © 2016 OrgName. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreData/CoreData.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    NSDate *lastLoginDate = [NSDate dateWithTimeIntervalSince1970:0];
    self.lastLoginDate = lastLoginDate;

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)stopThinkingInViewController:(UIViewController *)someViewController {
    for (UIView *someView in someViewController.view.subviews) {
        if ([someView isKindOfClass:[UIActivityIndicatorView class]] && someView.tag == 2) {
            [someView removeFromSuperview];
        }
        if ([someView isKindOfClass:[UIView class]] && someView.tag == 1) {
            [someView removeFromSuperview];
        }
    }
}

- (void)startThinkingInViewController:(UIViewController *)someViewController {
    UIView *grayView = [[UIView alloc] initWithFrame:someViewController.view.frame];
    grayView.backgroundColor = [UIColor blackColor];
    grayView.alpha = 0.05;
    grayView.tag = 1;
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.color = someViewController.view.tintColor;
    activityIndicator.center = someViewController.view.center;
    [activityIndicator startAnimating];
    activityIndicator.tag = 2;
    
    [someViewController.view addSubview:grayView];
    [someViewController.view addSubview:activityIndicator];
}

@end
