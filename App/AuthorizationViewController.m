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

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *loginTextField;
@property (strong, nonatomic) AuthorizationManager *authorizationManager;
@property (assign, nonatomic) BOOL isLoginButtonTapped;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation AuthorizationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AuthorizationManager *authorizationManager = [[AuthorizationManager alloc] init];
    authorizationManager.delegate = self;
    self.authorizationManager = authorizationManager;
    
    self.isLoginButtonTapped = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - IBActions

- (IBAction)login:(id)sender {
    if (self.loginButton.isEnabled) {
   //     [self.authorizationManager userTokenAfterAuthorizationWithLogin:self.loginTextField.text password:self.passwordTextField.text];
        [self.authorizationManager userTokenAfterAuthorizationWithLogin:@"user" password:@"user"];
        self.loginButton.enabled = NO;
    }
}

#pragma mark - <AuthorizationManagerDelegate>

- (void)authorizationManager:(AuthorizationManager *)manager hasRecievedUserToken:(NSString *)token forLogin:(NSString *)login {
    if (token) {
        self.loginButton.enabled = YES;
        
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        [user setObject:token forKey:@"token"];
        [user setObject:login forKey:@"login"];
        NSLog(@"TOKEN FROM USER DEFAULTS %@", [user objectForKey:@"token"]);
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
