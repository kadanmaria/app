//
//  Data.m
//  App
//
//  Created by Admin on 11.02.16.
//  Copyright © 2016 OrgName. All rights reserved.
//

#import "ContentDownloader.h"


static NSString * const applicatonId = @"8D2F3524-3D1D-88BC-FF2C-536BF2717200";
static NSString * const restId = @"A8A7BD7A-0B83-C7DC-FFA0-52D384DA6B00";
static NSString * const stringForURLRequest = @"https://api.backendless.com/v1/data/Data?pageSize=100";

@implementation ContentDownloader

- (void)downloadContent {
    NSString *restCall = stringForURLRequest;
    NSURL *restURL = [NSURL URLWithString:restCall];
    NSMutableURLRequest *restReqest = [NSMutableURLRequest requestWithURL:restURL];
    [restReqest addValue:applicatonId forHTTPHeaderField:@"application-id"];
    [restReqest addValue:restId forHTTPHeaderField:@"secret-key"];
    [restReqest setHTTPMethod:@"GET"];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *jsonData = [session dataTaskWithRequest:restReqest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (!error) {
                NSError *localError;
                NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (localError) {
                        NSLog(@"Error Parsing JSON %@", localError);
                    } else {
                        [self.delegate contentDownloader:self didDownloadContentToArray:[parsedObject valueForKey:@"data"]];
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