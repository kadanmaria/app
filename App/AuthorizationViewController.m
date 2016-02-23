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

@interface AuthorizationViewController () <UITextFieldDelegate, AuthorizationManagerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *loginTextField;
@property (strong, nonatomic) AuthorizationManager *authorizationManager;

@property (strong, nonatomic) NSString *userToken;

@end

@implementation AuthorizationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AuthorizationManager *authorizationManager = [[AuthorizationManager alloc] init];
    authorizationManager.delegate = self;
    self.authorizationManager = authorizationManager;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)logIn:(UIButton *)sender {
    [self.authorizationManager userTokenAfterAuthorizationWithLogin:self.loginTextField.text password:self.passwordTextField.text];
}

#pragma mark - <AuthorizationManagerDelegate>

- (void)authorizationManager:(AuthorizationManager *)manager hasRecievedUserToken:(NSString *)token {
    self.userToken = token;
    if (self.userToken) {
        NSLog(@"IS AUTHORISED");
        [self performSegueWithIdentifier:@"LogInSegue" sender:self];
    } else {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Log in problem" message:@"Ooops! Try another login/password!" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil]];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
        NSLog(@"Not authorised");
    }

}

#pragma mark - <UITextFieldDelegate>

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"LogInSegue"]) {
        FeedViewController *feedViewController = [segue destinationViewController];
        feedViewController.userToken = self.userToken;
    }
}

@end
