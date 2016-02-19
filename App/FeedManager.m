//
//  FeedController.m
//  App
//
//  Created by Admin on 18.02.16.
//  Copyright © 2016 OrgName. All rights reserved.
//

#import "FeedManager.h"
#import "Feed.h"

@interface FeedManager ()

@end

@implementation FeedManager

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    [self initializeCoreData];
    return self;
}

- (void)initializeCoreData {
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"FeedModel" withExtension:@"momd"];
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    if (!managedObjectModel) {
        NSLog(@"Error initializing Model");
    }
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    if (!persistentStoreCoordinator) {
        NSLog(@"Error initializing Coordinator");
    }
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    if (!managedObjectContext) {
        NSLog(@"Error initializing Context");
    }
    [managedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];
    [self setManagedObjectContext:managedObjectContext];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [documentsURL URLByAppendingPathComponent:@"FeedModel.sqlite"];
    
    NSError *error;
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Error %@, %@", error, [error userInfo]);
    }
}


- (void)manageObjects:(NSArray *)objects {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Feed" inManagedObjectContext:context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *objectsFromCoreData = [context executeFetchRequest:fetchRequest error:&error];
    
    NSMutableSet *setOfCoreDataObjects = [NSMutableSet set];
    for (Feed *feed in objectsFromCoreData) {
        [setOfCoreDataObjects addObject:feed.objectId];
    }
    
    NSMutableSet *setOfObjects = [[NSMutableSet alloc] init];
    for (NSDictionary *object in objects) {
        [setOfObjects addObject:[object valueForKey:@"objectId"]];
    }
        
    NSMutableSet *objectsTobeDeleted = [NSMutableSet setWithSet:setOfCoreDataObjects];
    [objectsTobeDeleted minusSet:setOfObjects];
    
    if (objectsTobeDeleted.count > 0) {
        NSMutableArray *arrayOfObjectsToBeDeleted = [[NSMutableArray alloc] init];
        for (Feed *object in objectsFromCoreData) {
            if ( [objectsTobeDeleted containsObject:object.objectId]) {
                    [arrayOfObjectsToBeDeleted addObject:object];
                }
        }
        [self deleteObjects:arrayOfObjectsToBeDeleted];
         NSLog(@"objectsToBeDeleted count %lu", [arrayOfObjectsToBeDeleted count]);
    }
    
    NSMutableSet *objectsToBeInserted = [NSMutableSet setWithSet:setOfObjects];
    [objectsToBeInserted minusSet:setOfCoreDataObjects];
    
    if (objectsToBeInserted.count > 0) {
        NSMutableArray *arrayOfObjectsToBeInserted = [[NSMutableArray alloc] init];
        for (NSDictionary *object in objects) {
            if ( [objectsToBeInserted containsObject:[object valueForKey:@"objectId"]]) {
                [arrayOfObjectsToBeInserted addObject:object];
            }
        }
        [self insertObjects:arrayOfObjectsToBeInserted];
        NSLog(@"objectsToBeInserted count %lu", [arrayOfObjectsToBeInserted count]);
    }
    
    NSMutableSet *objectsToBeUpdated = setOfCoreDataObjects;
    [objectsToBeUpdated minusSet:objectsTobeDeleted];
    
    if (objectsToBeUpdated.count > 0) {
        NSMutableArray *arrayOfObjectsToBeUpdated = [[NSMutableArray alloc] init];
        for (Feed *object in objectsFromCoreData) {
            if ([objectsToBeUpdated containsObject:object.objectId]) {
                [arrayOfObjectsToBeUpdated addObject:object];
            }
        }
        [self updateObjects:arrayOfObjectsToBeUpdated accordingToRecievedArray:objects];
        NSLog(@"objectsToBeUpdated count %lu", [arrayOfObjectsToBeUpdated count]);
    }
}

- (void)deleteObjects:(NSMutableArray *)objects {
    for (NSManagedObject *object in objects) {
        [[self managedObjectContext] deleteObject:object];
    }
}

- (void)insertObjects:(NSMutableArray *)objects {
    for (NSDictionary *object in objects) {
        Feed *feed = [NSEntityDescription insertNewObjectForEntityForName:@"Feed" inManagedObjectContext:[self managedObjectContext]];
        
        [feed setValue:[object valueForKey:@"objectId"] forKey:@"objectId"];
        [feed setValue:[object valueForKey:@"title"] forKey:@"title"];
        [feed setValue:[object valueForKey:@"subtitle"] forKey:@"subtitle"];
        [feed setValue:[object valueForKey:@"image_name"] forKey:@"image_name"];
    }
}

- (void)updateObjects:(NSMutableArray *)coreDataObjects accordingToRecievedArray:(NSArray *)recievedObjects {
    for (Feed *feed in coreDataObjects) {
        for (NSDictionary *object in recievedObjects) {
            
            if ([[feed valueForKey:@"objectId"] isEqualToString:[object valueForKey:@"objectId"]]) {
                
                if (![[feed valueForKey:@"title"] isEqualToString:[object valueForKey:@"title"]]) {
                    feed.title = [object valueForKey:@"title"];
                }
                if (![[feed valueForKey:@"subtitle"] isEqualToString:[object valueForKey:@"subtitle"]]) {
                    feed.subtitle = [object valueForKey:@"subtitle"];
                }
                if (![[feed valueForKey:@"image_name"] isEqualToString:[object valueForKey:@"image_name"]]) {
                    feed.image_name = [object valueForKey:@"image_name"];
                }
                
            }
        }
    }
}

@end
