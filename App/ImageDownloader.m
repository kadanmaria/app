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
//
//+ (id)sharedImageDownloader {
//    static ImageDownloader *sharedImageDownloader = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        sharedImageDownloader = [[self alloc] init];
//    });
//    return sharedImageDownloader;
//}

- (void)downloadImageFromString:(NSString *)imageString forIndexPath:(NSIndexPath *)indexPath {
    self.indexPath = indexPath;
    [self setSharedCacheForImages];
    
    NSURL *imageURL = [NSURL URLWithString:imageString];
    NSURLRequest *imageReqest = [NSURLRequest requestWithURL:imageURL];
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:imageReqest];
    if (cachedResponse.data) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [UIImage imageWithData:cachedResponse.data];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.image = image;
                [self.delegate imageDownloader:self didDownloadImage:self.image forIndexPath:self.indexPath];
            });
        });
    } else {
        
        NSURLSessionDataTask *imageData = [session dataTaskWithRequest:imageReqest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
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
}

- (void)setSharedCacheForImages {
    NSUInteger cacheSize = 500 * 1024 * 1024;
    NSUInteger cacheDiskSize = 500 * 1024 * 1024;
    NSURLCache *imageCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSize diskCapacity:cacheDiskSize diskPath:nil];
    [NSURLCache setSharedURLCache:imageCache];
}

@end
