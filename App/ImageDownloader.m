//
//  ImageDownloader.m
//  App
//
//  Created by Admin on 13.02.16.
//  Copyright © 2016 OrgName. All rights reserved.
//

#import "ImageDownloader.h"

@interface ImageDownloader ()

@property (assign, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) UIImage *image;

@end

@implementation ImageDownloader

- (void)downloadImageFromString:(NSString *)imageString forIndexPath:(NSIndexPath *)indexPath {
    self.indexPath = indexPath;
    NSString *restCall = imageString;
    NSURL *restURL = [NSURL URLWithString:restCall];
    NSURLRequest *restReqest = [NSURLRequest requestWithURL:restURL];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *imageData = [session dataTaskWithRequest:restReqest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if(!error) {
            UIImage *image = [UIImage imageWithData:data];
                
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!image) {
                    NSLog(@"Error Setting Image");
                } else {
                    self.image = image;
                    [self.delegate imageDownloader:self didDownloadImage:self.image forIndexPath:self.indexPath];
                }
            });
                
            } else {
                NSLog(@"Error imageDataTask %@", error);
            }
        });
    }];
    [imageData resume];
}

@end
