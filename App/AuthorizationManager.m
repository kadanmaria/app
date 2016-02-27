//
//  AuthorizationManager.m
//  App
//
//  Created by Admin on 23.02.16.
//  Copyright © 2016 OrgName. All rights reserved.
//

#import "AuthorizationManager.h"

static NSString * const applicatonId = @"8D2F3524-3D1D-88BC-FF2C-536BF2717200";
static NSString * const restId = @"A8A7BD7A-0B83-C7DC-FFA0-52D384DA6B00";
static NSString * const contentType = @"application/json";
static NSString * const applicationType = @"REST";
static NSString * const stringForAuthorizationRequest = @"https://api.backendless.com/v1/users/login";
static NSString * const stringForValidatationRequest = @"https://api.backendless.com/v1/users/isvalidusertoken/";

@implementation AuthorizationManager

- (void)loginWithLogin:(NSString *)login password:(NSString *)password {
    
    NSString *loginString = stringForAuthorizationRequest;
    NSURL *loginURL = [NSURL URLWithString:loginString];
    NSMutableURLRequest *loginRequest = [NSMutableURLRequest requestWithURL:loginURL];
    
    [loginRequest addValue:applicatonId forHTTPHeaderField:@"application-id"];
    [loginRequest addValue:restId forHTTPHeaderField:@"secret-key"];
    [loginRequest addValue:contentType forHTTPHeaderField:@"Content-Type"];
    [loginRequest addValue:applicationType forHTTPHeaderField:@"application-type"];
    
    [loginRequest setHTTPMethod:@"POST"];
    
    NSMutableDictionary *loginDict = [[NSMutableDictionary alloc] init];
    [loginDict setObject:login forKey:@"login"];
    [loginDict setObject:password forKey:@"password"];
    
    NSData *requestBody = [NSJSONSerialization dataWithJSONObject:loginDict options:0 error:0];
    [loginRequest setHTTPBody:requestBody];
  
    NSURLSessionDataTask *loginTask = [[NSURLSession sharedSession] dataTaskWithRequest:loginRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            if (!error) {
                NSError *localError;
                NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
             
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (localError) {
                        NSLog(@"Error Parsing JSON %@", localError);
                    } else {
                        if ([parsedObject valueForKey:@"user-token"]) {
                            [self.delegate authorizationManager:self hasRecievedUserToken:[parsedObject valueForKey:@"user-token"] forLogin:login];
                        } else {
                            [self.delegate authorizationManager:self hasRecievedUserToken:nil forLogin:login];
                        }
                    }
                });
                
            } else {
                [self.delegate authorizationManager:self hasExecutedWithError:error];
                NSLog(@"jsonDataTask with error %@", error);
            }
        });
    }];
    [loginTask resume];
}

- (void)isSessionValid {
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    if (token) {
        [self isSessionValidWithUserToken:token];
    } else {
        [self.delegate authorizationManagerSessionIsNotValid];
    }
}


- (void)isSessionValidWithUserToken:(NSString *)token {
    
    NSString *validationString = [NSString stringWithFormat:@"%@%@", stringForValidatationRequest, token];
    
    NSURL *validationURL = [NSURL URLWithString:validationString];
    NSMutableURLRequest *validationReqest = [NSMutableURLRequest requestWithURL:validationURL];
    
    [validationReqest addValue:applicatonId forHTTPHeaderField:@"application-id"];
    [validationReqest addValue:restId forHTTPHeaderField:@"secret-key"];
    [validationReqest addValue:applicationType forHTTPHeaderField:@"application-type"];
    
    [validationReqest setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *validationTask = [session dataTaskWithRequest:validationReqest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            if (!error) {
                NSString *boolInString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                BOOL isValid = [boolInString boolValue];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (isValid) {
                        [self.delegate authorizationManagerSessionIsValid];
                    } else {
                        [self.delegate authorizationManagerSessionIsNotValid];
                    }
            });
            }else {
                [self.delegate authorizationManager:self hasExecutedWithError:error];
                NSLog(@"Error %@", error);
            }
            
        });
    }];
    [validationTask resume];
}

@end
