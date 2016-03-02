//
//  Data.m
//  App
//
//  Created by Admin on 11.02.16.
//  Copyright © 2016 OrgName. All rights reserved.
//

#import "ContentManager.h"
#import "Feed.h"
#import "FeedManager.h"

static NSString * const applicatonId = @"8D2F3524-3D1D-88BC-FF2C-536BF2717200";
static NSString * const restId = @"A8A7BD7A-0B83-C7DC-FFA0-52D384DA6B00";
static NSString * const contentType = @"application/json";
static NSString * const applicationType = @"REST";
static NSString * const stringForURLRequest = @"https://api.backendless.com/v1/data/Data?pageSize=100";
static NSString * const stringForPutRequest = @"https://api.backendless.com/v1/data/Data";

@implementation ContentManager

- (NSMutableURLRequest *)request {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request addValue:applicatonId forHTTPHeaderField:@"application-id"];
    [request addValue:restId forHTTPHeaderField:@"secret-key"];
    return request;
}

- (void)downloadContent {
    // Prepare request.
    NSString *restCall = stringForURLRequest;
    NSURL *restURL = [NSURL URLWithString:restCall];
    
    NSMutableURLRequest *restRequest = [self request];
    restRequest.URL = restURL;
    [restRequest setHTTPMethod:@"GET"];

    // Send request.
    NSURLSessionDataTask *jsonData = [[NSURLSession sharedSession] dataTaskWithRequest:restRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            if (!error) {
                NSError *localError;
                NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (localError) {
                        [self.delegate contentManager:self hasExecutedWithError:localError];
                    } else {
                        [self.delegate contentManager:self didDownloadContentToArray:[parsedObject valueForKey:@"data"]];
                    }
                });
            
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate contentManager:self hasExecutedWithError:error];
                });
            }
        });
    }];
    [jsonData resume];
}

- (void)putChangesToServer {    
    NSManagedObjectContext *backgroundContext = [[FeedManager sharedInstance] backgroundContext];
    NSManagedObjectContext *mainContext = [[FeedManager sharedInstance] mainContext];

    __block NSError *uploadingError = nil;
    dispatch_group_t putGroup = dispatch_group_create();
    
    [backgroundContext performBlock:^{
        NSArray *feeds = [[FeedManager sharedInstance] changedFeedsInContext:backgroundContext];
        for (Feed *feed in feeds) {
            
            // Prepare request.
            NSString *putString = @"";
            if ([[feed valueForKey:@"objectId"] isEqualToString:@"temporaryId"]) {
                putString = stringForPutRequest;
            } else {
                putString = [NSString stringWithFormat:@"%@/%@", stringForPutRequest, [feed valueForKey:@"objectId"]];
            }
            NSURL *putURL = [NSURL URLWithString:putString];
            NSMutableURLRequest *putReqest = [self request];
            putReqest.URL = putURL;
            [putReqest addValue:applicationType forHTTPHeaderField:@"application-type"];
            [putReqest addValue:contentType forHTTPHeaderField:@"Content-Type"];
            
            if ([[feed valueForKey:@"objectId"] isEqualToString:@"temporaryId"]) {
                NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
                [putReqest addValue:[user valueForKey:@"token"] forHTTPHeaderField:@"user-token"];
            }
            
            NSMutableDictionary *putBodyDictionary = [[NSMutableDictionary alloc] init];
            [putBodyDictionary setObject:[feed valueForKey:@"title"] forKey:@"title"];
            [putBodyDictionary setObject:[feed valueForKey:@"subtitle"] forKey:@"subtitle"];
            [putBodyDictionary setObject:[feed valueForKey:@"imageName"] forKey:@"imageName"];
            
            NSData *putBody = [NSJSONSerialization dataWithJSONObject:putBodyDictionary options:0 error:0];
            [putReqest setHTTPBody:putBody];
            [putReqest setHTTPMethod:@"PUT"];
            
            // Send request.
            dispatch_group_enter(putGroup);
            NSURLSessionDataTask *putTask = [[NSURLSession sharedSession] dataTaskWithRequest:putReqest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if (!error) {
                    
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        feed.hasChanged = @NO;
                        dispatch_group_leave(putGroup);
                    });
                    
                } else {
                    uploadingError = error;
                    dispatch_group_leave(putGroup);
                }
            }];
            [putTask resume];
        }
        
        dispatch_group_notify(putGroup, dispatch_get_main_queue(), ^{
            
            if (!uploadingError) {
                [backgroundContext performBlock:^{
                    
                    NSError *savingBackgroundContextError = nil;
                    if ([backgroundContext save:&savingBackgroundContextError]) {
                        
                        [mainContext performBlock:^{
                            NSError *savingMainContextError = nil;
                            if ([mainContext save:&savingMainContextError]) {
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self.delegate contentManagerDidUploadObjectsToServer];
                                });
                                
                            } else {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self.delegate contentManager:self hasExecutedWithError:savingMainContextError];
                                });
                            }
                        }];
                        
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.delegate contentManager:self hasExecutedWithError:savingBackgroundContextError];
                        });
                    }
                }];
                
            } else {
                [self.delegate contentManager:self hasExecutedWithError:uploadingError];
            }
            
        });

    }];
}

@end