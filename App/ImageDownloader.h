//
//  ImageDownloader.h
//  App
//
//  Created by Admin on 13.02.16.
//  Copyright © 2016 OrgName. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageDownloader : NSObject

+ (void)downloadImageFromString:(NSString *)imageString
                   forIndexPath:(NSIndexPath *)indexPath
                     completion:(void (^)(UIImage *image))completion;

@end
