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

- (void)setImageDownloaderTask:(NSURLSessionDataTask *)task forKey:(NSString *)key {
    [self.tasks setValue:task forKey:key];
}

@end

static NSString * const applicatonId = @"8D2F3524-3D1D-88BC-FF2C-536BF2717200";
static NSString * const restId = @"A8A7BD7A-0B83-C7DC-FFA0-52D384DA6B00";
static NSString * const contentType = @"application/json";
static NSString * const applicationType = @"REST";
static NSString * const stringForURLRequest = @"https://api.backendless.com/v1/files/media/images/";

@interface ImageDownloader ()

@end

@implementation ImageDownloader

+ (void)load {
    [super load];
    [self setSharedCacheForImages];
}

+ (void)uploadImage:(NSData *)data {
    NSString *PATH = @"somePath";
    NSString *requestString = [NSString stringWithFormat:@"%@%@", stringForURLRequest, PATH];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request addValue:applicatonId forHTTPHeaderField:@"application-id"];
    [request addValue:restId forHTTPHeaderField:@"secret-key"];
    [request addValue:applicationType forHTTPHeaderField:@"application-type"];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    [request addValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] forHTTPHeaderField:@"user-token"];
    
    request.URL = [NSURL URLWithString:requestString];
    [request setHTTPMethod:@"POST"];
    
    [request setHTTPBody:data];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *uploadTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            if (!error) {
                NSError *localError;
                NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (localError) {
                        NSLog(@"Error Parsing JSON %@", localError);
                    } else {
                        NSLog(@"file url %@", [parsedObject valueForKey:@"fileURL"]);
                    }
                });
                
            } else {
                NSLog(@"%@", error);
            }
        });
    }];
    [uploadTask resume];
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
                            [[ImageDownloaderTasks sharedInstance] setImageDownloaderTask:imageDataTask forKey:imageString];
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
