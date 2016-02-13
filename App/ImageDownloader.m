//
//  ImageDownloader.m
//  App
//
//  Created by Admin on 13.02.16.
//  Copyright © 2016 OrgName. All rights reserved.
//

#import "ImageDownloader.h"

@interface ImageDownloader () <NSURLConnectionDelegate>

@property (strong, nonatomic) NSURLConnection *currentConnection;
@property (strong, nonatomic) NSMutableData *dataContainingImage;
@property (strong, nonatomic) NSString *imageURL;
@property (assign, nonatomic) NSIndexPath *indexPath;

@end

@implementation ImageDownloader

- (void)downloadImageFromString:(NSString *)imageString withIndexPath:(NSIndexPath *)indexPath {
    self.imageURL = imageString;
    self.indexPath = indexPath;
    NSString *restCall = imageString;
    NSURL *restURL = [NSURL URLWithString:restCall];
    NSURLRequest *restReqest = [NSURLRequest requestWithURL:restURL];
    if (self.currentConnection) {
        [self.currentConnection cancel];
        self.currentConnection = nil;
        self.dataContainingImage = nil;
    }
    self.currentConnection = [[NSURLConnection alloc] initWithRequest:restReqest delegate:self];
    self.dataContainingImage = [NSMutableData data];
}

- (void)downloadImagesFromArray:(NSArray *)imagesArray {
    NSString *restCall = imageString;
    NSURL *restURL = [NSURL URLWithString:restCall];
    NSURLRequest *restReqest = [NSURLRequest requestWithURL:restURL];
    if (self.currentConnection) {
        [self.currentConnection cancel];
        self.currentConnection = nil;
        self.dataContainingImage = nil;
    }
    self.currentConnection = [[NSURLConnection alloc] initWithRequest:restReqest delegate:self];
    self.dataContainingImage = [NSMutableData data];



}

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse *)response {
    [self.dataContainingImage setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.dataContainingImage appendData:data];
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error {
    NSLog(@"URL Connection Failed With Error %@!", error);
    self.currentConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.imageURL]];
    if (!data) {
        NSLog(@"Error Downloading Data");
    } else {
        [self.delegate imageDownloader:self didDownloadData:data forIndexPath:self.indexPath];
    }
    self.currentConnection = nil;
}

@end
