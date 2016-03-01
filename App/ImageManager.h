//
//  ImageManager.h
//  App
//
//  Created by Admin on 13.02.16.
//  Copyright © 2016 OrgName. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Feed.h"

@interface ImageManager : NSObject

+ (void)downloadImageFromString:(NSString *)imageString
                   forIndexPath:(NSIndexPath *)indexPath
                     completion:(void (^)(UIImage *image, NSIndexPath *indexPath))completion;

+ (void)uploadImagesWithCompletion:(void (^)(NSError *error))completion;

@end
