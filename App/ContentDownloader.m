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
static NSString * const stringForURLRequest = @"https://api.backendless.com/v1/data/Data";

@interface ContentDownloader () <NSURLConnectionDataDelegate>

@property (strong, nonatomic) NSURLConnection *currentConnection;
@property (strong, nonatomic) NSMutableData *returnedData;

@end

@implementation ContentDownloader

- (void)downloadContent {
    NSString *restCall = stringForURLRequest;
    NSURL *restURL = [NSURL URLWithString:restCall];
    NSMutableURLRequest *restReqest = [NSMutableURLRequest requestWithURL:restURL];
    [restReqest addValue:applicatonId forHTTPHeaderField:@"application-id"];
    [restReqest addValue:restId forHTTPHeaderField:@"secret-key"];
    [restReqest setHTTPMethod:@"GET"];
    if (self.currentConnection) {
        [self.currentConnection cancel];
        self.currentConnection = nil;
        self.returnedData = nil;
    }
    self.currentConnection = [[NSURLConnection alloc] initWithRequest:restReqest delegate:self];
    self.returnedData = [NSMutableData data];
}

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse *)response {
    [self.returnedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.returnedData appendData:data];
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error {
    NSLog(@"URL Connection Failed With Error %@!", error);
    self.currentConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSError *error;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:self.returnedData options:0 error:&error];
    if (error) {
        NSLog(@"Error Parsing JSON %@", error);
    } else {
        [self.delegate contentDownloader:self didDownloadContentToArray:[parsedObject valueForKey:@"data"]];
    }
    self.currentConnection = nil;
}

@end