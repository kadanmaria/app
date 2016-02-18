//
//  FeedController.h
//  App
//
//  Created by Admin on 18.02.16.
//  Copyright © 2016 OrgName. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface FeedController : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)initializeCoreData;
- (void)insertNewOrUpdateObject:(NSDictionary *)object;
- (void)manageObjects:(NSArray *)objects;

@end
