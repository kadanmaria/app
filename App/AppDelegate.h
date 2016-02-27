//
//  AppDelegate.h
//  App
//
//  Created by Admin on 07.02.16.
//  Copyright © 2016 OrgName. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedManager.h"
#import "AuthorizationManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NSDate *lastLoginDate;

- (void)startThinkingInViewController:(UIViewController *)viewController;
- (void)stopThinkingInViewController:(UIViewController *)viewController;

@end

