//
//  FeedController.h
//  App
//
//  Created by Admin on 18.02.16.
//  Copyright © 2016 OrgName. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface FeedManager : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

- (void)initializeCoreData;
- (void)manageObjects:(NSArray *)objects;

@end