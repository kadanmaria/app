//
//  AuthorizationViewController.m
//  App
//
//  Created by Admin on 22.02.16.
//  Copyright © 2016 OrgName. All rights reserved.
//

#import "AuthorizationViewController.h"
#import "FeedViewController.h"
#import "AuthorizationManager.h"
#import "AppDelegate.h"

@interface AuthorizationViewController () <UITextFieldDelegate, AuthorizationManagerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *loginTextField;

@property (strong, nonatomic) AuthorizationManager *authorizationManager;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIView *carpetView;

@end

@implementation AuthorizationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AuthorizationManager *authorizationManager = [[AuthorizationManager alloc] init];
    authorizationManager.delegate = self;
    self.authorizationManager = authorizationManager;
    
    UIView *grayView = [[UIView alloc] initWithFrame:self.view.frame];
    grayView.backgroundColor = [UIColor blackColor];
    grayView.alpha = 0.1;
    self.carpetView = grayView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];

    if ([user objectForKey:@"token"]) {
        
        [self.view addSubview:self.carpetView];
        [self.activityIndicator startAnimating];
        
        [self.authorizationManager isSessionValidWithUserToken:[user objectForKey:@"token"] completion:^(bool isValid) {
            if (isValid) {
                [self.activityIndicator stopAnimating];
                NSDate *lastLoginDate = [NSDate date];
                [(AppDelegate *)[[UIApplication sharedApplication] delegate] setLastLoginDate:lastLoginDate];
                [self dismissViewControllerAnimated:NO completion:nil];
            } else {
                [self.activityIndicator stopAnimating];
                [self.carpetView removeFromSuperview];
            }
        }];
    }
}

#pragma mark - IBActions

- (IBAction)login:(id)sender {
    if (self.loginButton.isEnabled) {
        [self.authorizationManager loginWithLogin:self.loginTextField.text password:self.passwordTextField.text];
   //     [self.authorizationManager loginWithLogin:@"user" password:@"user"];
        
        [self.loginTextField resignFirstResponder];
        [self.passwordTextField resignFirstResponder];
        
        self.loginButton.enabled = NO;
        [self.view addSubview:self.carpetView];
        [self.activityIndicator startAnimating];
    }
}

#pragma mark - <AuthorizationManagerDelegate>

- (void)authorizationManager:(AuthorizationManager *)manager hasRecievedUserToken:(NSString *)token forLogin:(NSString *)login {
    [self.activityIndicator stopAnimating];
    [self.carpetView removeFromSuperview];
    if (token) {
        self.loginButton.enabled = YES;
        
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        [user setObject:token forKey:@"token"];
        [user setObject:login forKey:@"login"];
        
        NSDate *lastLoginDate = [NSDate date];
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] setLastLoginDate:lastLoginDate];
        
        [self dismissViewControllerAnimated:NO completion:nil];
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Log in problem"
                                                                                 message:@"Ooops! Try another login/password!"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        self.loginButton.enabled = YES;
    }
}

#pragma mark - <UITextFieldDelegate>

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.loginTextField) {
        [textField resignFirstResponder];
        [self.passwordTextField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
        [self login:nil];
    }
    return YES;
}

@end
