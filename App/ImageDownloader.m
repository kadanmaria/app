//
//  ImageDownloader.m
//  App
//
//  Created by Admin on 13.02.16.
//  Copyright © 2016 OrgName. All rights reserved.
//

#import "ImageDownloader.h"


@interface ImageDownloaderTasks : NSObject

@property (strong, nonatomic) NSMutableDictionary *tasks;

@end

@implementation ImageDownloaderTasks

+ (instancetype)sharedInstance {
    static ImageDownloaderTasks *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        NSMutableDictionary *tasks = [[NSMutableDictionary alloc] init];
        self.tasks = tasks;
    }
    return self;
}

- (NSURLSessionDataTask *)imageDownloaderTaskforKey:(NSString *)key {
    return [self.tasks objectForKey:key];
}

- (void)setImageDownloaderTasks:(NSURLSessionDataTask *)task forKey:(NSString *)key {
    [self.tasks setValue:task forKey:key];
}

@end


@interface ImageDownloader ()

@end

@implementation ImageDownloader

+ (void)load {
    [super load];
    [self setSharedCacheForImages];
}

+ (void)downloadImageFromString:(NSString *)imageString forIndexPath:(NSIndexPath *)indexPath completion:(void (^)(UIImage *image, NSIndexPath *indexPath))completion {
    if ([[ImageDownloaderTasks sharedInstance] imageDownloaderTaskforKey:imageString]) {
        [[[ImageDownloaderTasks sharedInstance] imageDownloaderTaskforKey:imageString] cancel];
    }
    
    NSURL *imageURL = [NSURL URLWithString:imageString];
    NSURLRequest *imageReqest = [NSURLRequest requestWithURL:imageURL];
    
    NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:imageReqest];
    
    if (cachedResponse.data) {
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            UIImage *image = [UIImage imageWithData:cachedResponse.data];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(image, indexPath);
            });
            
        });
        
    } else {
        
        NSURLSessionDataTask *imageDataTask = [[NSURLSession sharedSession] dataTaskWithRequest:imageReqest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                if(!error) {
                    UIImage *image = [UIImage imageWithData:data];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (!image) {
                            NSLog(@"Error Setting Image");
                        } else {
                            [[ImageDownloaderTasks sharedInstance] setImageDownloaderTasks:imageDataTask forKey:imageString];
                            completion (image, indexPath);
                        }
                    });
                    
                } else {
                    NSLog(@"Error imageDataTask %@", error);
                }
            });
        }];
        [imageDataTask resume];
    }
}

+ (void)setSharedCacheForImages {
    NSUInteger cacheSize = 500 * 1024 * 1024;
    NSUInteger cacheDiskSize = 500 * 1024 * 1024;
    NSURLCache *imageCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSize diskCapacity:cacheDiskSize diskPath:@"AppImagesCache"];
    [NSURLCache setSharedURLCache:imageCache];
}

@end
