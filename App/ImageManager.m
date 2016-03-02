//
//  ImageManager.m
//  App
//
//  Created by Admin on 13.02.16.
//  Copyright © 2016 OrgName. All rights reserved.
//

#import "ImageManager.h"
#import "FeedManager.h"

@interface ImageManagerTasks : NSObject

@property (strong, nonatomic) NSMutableDictionary *tasks;

@end

@implementation ImageManagerTasks

+ (instancetype)sharedInstance {
    static ImageManagerTasks *instance = nil;
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

- (NSURLSessionDataTask *)imageManagerTaskforKey:(NSString *)key {
    return [self.tasks objectForKey:key];
}

- (void)setImageManagerTask:(NSURLSessionDataTask *)task forKey:(NSString *)key {
    [self.tasks setValue:task forKey:key];
}

@end

static NSString * const applicatonId = @"8D2F3524-3D1D-88BC-FF2C-536BF2717200";
static NSString * const restId = @"A8A7BD7A-0B83-C7DC-FFA0-52D384DA6B00";
static NSString * const contentType = @"multipart/form-data";
static NSString * const applicationType = @"REST";
static NSString * const stringForURLRequest = @"https://api.backendless.com/v1/files/media/images/";

@interface ImageManager ()

@end

@implementation ImageManager

+ (void)load {
    [super load];
    [self setSharedCacheForImages];
}

+ (void)uploadImagesWithCompletion:(void (^)(NSError *error))completion {
    
    NSManagedObjectContext *backgroundContext = [[FeedManager sharedInstance] backgroundContext];
    NSManagedObjectContext *mainContext = [[FeedManager sharedInstance] mainContext];
    
    __block NSError *uploadingError = nil;
    dispatch_group_t putGroup = dispatch_group_create();
    
    [backgroundContext performBlock:^{
        NSArray *feeds = [[FeedManager sharedInstance] feedsWithLocalImagesInContext:backgroundContext];
        for (Feed *feed in feeds) {    
    
            // Prepare request.
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyyMMdd_HHmmss"];
            NSString *date = [dateFormatter stringFromDate:[NSDate date]];
            
            NSString *boundary = [NSString stringWithFormat:@"%lu", feed.localImage.length];
            
            NSString *name = [NSString stringWithFormat:@"IMG_%@_%@.jpeg",date, boundary];
            NSString *requestString = [NSString stringWithFormat:@"%@%@", stringForURLRequest, name];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString]];
            
            NSString *contentTypeFull = [NSString stringWithFormat:@"%@; boundary=%@", contentType, boundary];
            
            [request addValue:applicatonId forHTTPHeaderField:@"application-id"];
            [request addValue:restId forHTTPHeaderField:@"secret-key"];
            [request addValue:applicationType forHTTPHeaderField:@"application-type"];
            [request addValue:contentTypeFull forHTTPHeaderField:@"Content-Type"];
            [request addValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"] forHTTPHeaderField:@"user-token"];
            
            [request setHTTPMethod:@"POST"];
            
            NSMutableData *body = [NSMutableData data];
            [body appendData:[[NSString stringWithFormat:@"--%@\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=%@; filename=imageName.jpg\n", @"imageFormKey"] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Type: image/jpeg\n\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:feed.localImage];
            [body appendData:[[NSString stringWithFormat:@"\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"--%@--\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            
            [request setHTTPBody:body];
            
            NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
            [request addValue:postLength forHTTPHeaderField:@"Content-Length"];

            // Send request.
            dispatch_group_enter(putGroup);
            NSURLSessionDataTask *uploadTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    if (!error) {
                        NSError *localError;
                        NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (localError) {
                                uploadingError = error;
                            } else {
                                feed.imageName = [parsedObject valueForKey:@"fileURL"];
                                feed.localImage = NULL;
                                dispatch_group_leave(putGroup);
                            }
                        });
                        
                    } else {
                        completion(error);
                        dispatch_group_leave(putGroup);
                    }
                });
            }];
            [uploadTask resume];
        }
        
        dispatch_group_notify(putGroup, dispatch_get_main_queue(), ^{
            if (!uploadingError) {
                [backgroundContext performBlock:^{
                    
                    NSError *savingBackgroundContextError = nil;
                    if ([backgroundContext save:&savingBackgroundContextError]) {
                        
                        [mainContext performBlock:^{
                            NSError *savingMainContextError = nil;
                            if ([mainContext save:&savingMainContextError]) {
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    completion(nil);
                                });
                                
                            } else {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    completion(savingMainContextError);
                                });
                            }
                        }];
                        
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(savingBackgroundContextError);
                        });
                    }
                }];
                
            } else {
                completion(uploadingError);
            }
            
        });

    }];
}

+ (void)downloadImageFromString:(NSString *)imageString forIndexPath:(NSIndexPath *)indexPath completion:(void (^)(UIImage *image, NSIndexPath *indexPath))completion {
    if ([[ImageManagerTasks sharedInstance] imageManagerTaskforKey:imageString]) {
        [[[ImageManagerTasks sharedInstance] imageManagerTaskforKey:imageString] cancel];
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
        //Send request.
        NSURLSessionDataTask *imageDataTask = [[NSURLSession sharedSession] dataTaskWithRequest:imageReqest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                if(!error) {
                    UIImage *image = [UIImage imageWithData:data];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (!image) {
                            completion(nil, nil);
                        } else {
                            [[ImageManagerTasks sharedInstance] setImageManagerTask:imageDataTask forKey:imageString];
                            completion (image, indexPath);
                        }
                    });
                    
                } else {
                    completion(nil, nil);
                }
            });
        }];
        [imageDataTask resume];
    }
}

+ (void)setSharedCacheForImages {
    NSUInteger cacheSize = 500 * 1024 * 1024;
    NSUInteger cacheDiskSize = 500 * 1024 * 1024;
    NSURLCache *imageCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSize diskCapacity:cacheDiskSize diskPath:@"AppCacheImages"];
    [NSURLCache setSharedURLCache:imageCache];
}

@end
