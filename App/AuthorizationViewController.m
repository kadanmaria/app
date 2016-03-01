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
#import "FeedManager.h"

@interface AuthorizationViewController () <UITextFieldDelegate, AuthorizationManagerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *loginTextField;

@property (strong, nonatomic) AuthorizationManager *authorizationManager;
@property (strong, nonatomic) AppDelegate *appDelegate;

@end

@implementation AuthorizationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AuthorizationManager *authorizationManager = [[AuthorizationManager alloc] init];
    authorizationManager.delegate = self;
    self.authorizationManager = authorizationManager;
    
    id appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.appDelegate = appDelegate;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - IBActions

- (IBAction)login:(id)sender {
//    [self.authorizationManager loginWithLogin:self.loginTextField.text password:self.passwordTextField.text];
    [self.authorizationManager loginWithLogin:@"user" password:@"user"];
    
    [self.loginTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    
    [self.appDelegate startThinkingInViewController:self];
    
}

#pragma mark - <AuthorizationManagerDelegate>

- (void)authorizationManager:(AuthorizationManager *)manager hasRecievedUserToken:(NSString *)token forLogin:(NSString *)login {

    [self.appDelegate stopThinkingInViewController:self];
    
    if (token) {
         NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        
        [user setObject:token forKey:@"token"];
        [user setObject:login forKey:@"login"];
        
        [self dismissViewControllerAnimated:NO completion:nil];
    } else {
        [self showAlertWithTitle:@"Log in problem" message:@"Ooops! Try another login/password!"];
    }
}

- (void)authorizationManager:(AuthorizationManager *)manager loginHasExecutedWithError:(NSError *)error {
    [self showAlertWithTitle:@"Log in problem" message:@"Ooops! Loging in has executed with error!"];
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

#pragma mark - Other

-(BOOL)shouldAutorotate {
    return NO;
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:NO completion:nil];
}

@end
