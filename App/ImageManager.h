//
//  ImageManager.h
//  App
//
//  Created by Admin on 13.02.16.
//  Copyright © 2016 OrgName. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageManager : NSObject

+ (void)downloadImageFromString:(NSString *)imageString
                   forIndexPath:(NSIndexPath *)indexPath
                     completion:(void (^)(UIImage *image, NSIndexPath *indexPath))completion;

+ (void)uploadImage:(UIImage *)image completion:(void (^)(NSURL *imageURL))completion;

@end
