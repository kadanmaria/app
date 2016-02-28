//
//  Data.h
//  App
//
//  Created by Admin on 11.02.16.
//  Copyright © 2016 OrgName. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@class ContentManager;
@class Feed;

@protocol ContentManagerDelegate

- (void)contentManager:(ContentManager *)contentManager didDownloadContentToArray:(NSArray *)array;
- (void)contentManagerDidUploadObjectsToServer:(ContentManager *)contentManager;

@end

@interface ContentManager : NSObject

@property (weak, nonatomic) id <ContentManagerDelegate> delegate;

- (void)downloadContent;
- (void)putChangesToServer:(NSArray *)feeds inContext:(NSManagedObjectContext *)context;

@end
