//
//  Data.m
//  App
//
//  Created by Admin on 11.02.16.
//  Copyright © 2016 OrgName. All rights reserved.
//

#import "Data.h"

#define APP_ID @"8D2F3524-3D1D-88BC-FF2C-536BF2717200"
#define REST_ID @"A8A7BD7A-0B83-C7DC-FFA0-52D384DA6B00"

@implementation Data

- (void)getData {
    NSString *restCall = @"https://api.backendless.com/v1/data/Data";
    NSURL *restURL = [NSURL URLWithString:restCall];
    NSMutableURLRequest *restReqest = [NSMutableURLRequest requestWithURL:restURL];
    [restReqest addValue:APP_ID forHTTPHeaderField:@"application-id"];
    [restReqest addValue:REST_ID forHTTPHeaderField:@"secret-key"];
    [restReqest setHTTPMethod:@"GET"];
    if(currentConnection) {
        [currentConnection cancel];
        currentConnection = nil;
        self.returnedData = nil;
    }
    currentConnection = [[NSURLConnection alloc] initWithRequest:restReqest delegate:self];
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
    currentConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSError *error;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:self.returnedData options:0 error:&error];
    if(error) {
        NSLog(@"Error Parsing JSON %@", error);
    } else {
        [self.JSONDelegate recievedArrayFromJSON:[parsedObject valueForKey:@"data"]];
    }
    currentConnection = nil;
}

@end