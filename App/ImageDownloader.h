//
//  ImageDownloader.h
//  App
//
//  Created by Admin on 13.02.16.
//  Copyright © 2016 OrgName. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class ImageDownloader;

@protocol ImageDownloaderDelegate

- (void)imageDownloader:(ImageDownloader *)imageDownloader didDownloadImage:(UIImage *)image forIndexPath:(NSIndexPath *)indexPath;

@end

@interface ImageDownloader : NSObject

@property (weak, nonatomic) id <ImageDownloaderDelegate> delegate;

- (void)downloadImageFromString:(NSString *)imageString forIndexPath:(NSIndexPath *)indexPath;
//+ (id)sharedImageDownloader;

@end
