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
@property (assign, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) UIImage *image;

@end

@implementation ImageDownloader

- (void)downloadImageFromString:(NSString *)imageString forIndexPath:(NSIndexPath *)indexPath {
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
}

#pragma mark - <NSURLConnectionDelegate>

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse *)response {
    self.dataContainingImage = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.dataContainingImage appendData:data];
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error {
    NSLog(@"URL Connection Failed With Error %@!", error);
    self.currentConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    UIImage *image = [UIImage imageWithData:self.dataContainingImage];
        if (!image) {
            NSLog(@"Error Setting Image");
        } else {
            self.image = image;
            NSLog(@"Did download image for row %lu", self.indexPath.row);
            [self.delegate imageDownloader:self didDownloadImage:self.image forIndexPath:self.indexPath];
            
        }
    self.currentConnection = nil;
}

@end
