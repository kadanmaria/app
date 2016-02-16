//
//  Data.h
//  App
//
//  Created by Admin on 11.02.16.
//  Copyright © 2016 OrgName. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ContentDownloader;

@protocol ContentDownloaderDelegate

- (void)contentDownloader:(ContentDownloader *)contentDownloader didDownloadContentToArray:(NSArray *)array;

@end

@interface ContentDownloader : NSObject

@property (weak, nonatomic) id <ContentDownloaderDelegate> delegate;

- (void)downloadContent;

@end
