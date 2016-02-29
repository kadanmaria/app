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
    NSString *restCall = stringForURLRequest;
    NSURL *restURL = [NSURL URLWithString:restCall];
    
    NSMutableURLRequest *restRequest = [self request];
    restRequest.URL = restURL;
    [restRequest setHTTPMethod:@"GET"];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *jsonData = [session dataTaskWithRequest:restRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            if (!error) {
                NSError *localError;
                NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (localError) {
                        [self.delegate contentManager:self hasExecutedWithError:localError];
                        NSLog(@"Error Parsing JSON %@", localError);
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

    [backgroundContext performBlock:^{
        __block NSError *uploadingError = nil;
        NSArray *feeds = [[FeedManager sharedInstance] changedFeedsInContext:backgroundContext];
        
        if (feeds.count > 0) {
            dispatch_group_t putGroup = dispatch_group_create();
            
            for (Feed *feed in feeds) {
                NSString *putString = [[NSString alloc] init];
                
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
                
                dispatch_group_enter(putGroup);
                NSURLSessionDataTask *putTask = [[NSURLSession sharedSession] dataTaskWithRequest:putReqest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    if (!error) {
                        
                        dispatch_async(dispatch_get_global_queue(0, 0), ^{
                            if (error) {
                                uploadingError = error;
                            } else {
                                feed.hasChanged = [NSNumber numberWithBool:NO];
                            }
                        });
                        
                    } else {
                        uploadingError = error;
                    }
                    dispatch_group_leave(putGroup);
                }];
                [putTask resume];
            }
            if (!uploadingError) {
                dispatch_group_notify(putGroup, dispatch_get_main_queue(), ^{
                    [self.delegate contentManagerDidUploadObjectsToServer:self];
                });
            } else {
                [self.delegate contentManager:self hasExecutedWithError:uploadingError];
            }
            
            NSError *savingBackgroundContextError = nil;
            if (![backgroundContext save:&savingBackgroundContextError]) {
                NSLog(@"Unresolved error %@, %@", savingBackgroundContextError, [savingBackgroundContextError userInfo]);
            }
            
            [mainContext performBlock:^{
                NSError *savingMainContextError = nil;
                if (![mainContext save:&savingMainContextError]) {
                    NSLog(@"Unresolved error %@, %@", savingMainContextError, [savingMainContextError userInfo]);
                }
            }];
        } else {
            [self.delegate contentManagerDidUploadObjectsToServer:self];
        }
    }];
}

@end