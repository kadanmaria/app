//
//  FeedController.h
//  App
//
//  Created by Admin on 18.02.16.
//  Copyright © 2016 OrgName. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Feed.h"

@interface FeedManager : NSObject

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *backgroundContext;
@property (strong, nonatomic) NSManagedObjectContext *mainContext;

+ (instancetype)sharedInstance;
- (void)initializeCoreData;

- (void)manageObjects:(NSArray *)objects;
- (void)updateOrAddFeed:(Feed *)feed accordingToChangedTitle:(NSString *)title subtitle:(NSString *)subtitle;
- (NSArray *)changedFeedsInContext:(NSManagedObjectContext *)context;
@end
