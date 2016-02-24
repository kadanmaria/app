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
static NSString * const stringForURLRequest = @"https://api.backendless.com/v1/users/login";

@implementation AuthorizationManager

- (void)userTokenAfterAuthorizationWithLogin:(NSString *)login password:(NSString *)password {
    
    NSString *restCall = stringForURLRequest;
    NSURL *restURL = [NSURL URLWithString:restCall];
    NSMutableURLRequest *restReqest = [NSMutableURLRequest requestWithURL:restURL];
    
    [restReqest addValue:applicatonId forHTTPHeaderField:@"application-id"];
    [restReqest addValue:restId forHTTPHeaderField:@"secret-key"];
    [restReqest addValue:contentType forHTTPHeaderField:@"Content-Type"];
    [restReqest addValue:applicationType forHTTPHeaderField:@"Content-Type"];
    
    [restReqest setHTTPMethod:@"POST"];
    
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:login forKey:@"login"];
    [requestDict setObject:password forKey:@"password"];
    
    NSData *requestBody = [NSJSONSerialization dataWithJSONObject:requestDict options:0 error:0];
    [restReqest setHTTPBody:requestBody];
  
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *jsonData = [session dataTaskWithRequest:restReqest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            if (!error) {
                NSError *localError;
                NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
             
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (localError) {
                        NSLog(@"Error Parsing JSON %@", localError);
                    } else {
                        if ([parsedObject valueForKey:@"user-token"]) {
                            [self.delegate authorizationManager:self hasRecievedUserToken:[parsedObject valueForKey:@"user-token"]];
                            
                        } else {
                            [self.delegate authorizationManager:self hasRecievedUserToken:nil];
                        }
//                        NSLog(@"%@", parsedObject);
//                        NSLog(@"Response %@", response);
                        NSLog(@"1");
                    }
                });
                
            } else {
                NSLog(@"jsonDataTask with error %@", error);
            }
        });
    }];
    
    [jsonData resume];
}

@end
