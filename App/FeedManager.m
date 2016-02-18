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

- (void)deleteObjects:(NSMutableArray *)objects {
  
    for (NSManagedObject *object in objects) {
        [[self managedObjectContext] deleteObject:object];
        
        NSLog(@"There is an object to be deleted");
    }
}

- (void)insertObjects:(NSMutableArray *)objects {
    
//    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Feed" inManagedObjectContext:[self managedObjectContext]];
    Feed *feed = [[Feed alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
    for (NSDictionary *object in objects) {
        feed = [NSEntityDescription insertNewObjectForEntityForName:@"Feed" inManagedObjectContext:[self managedObjectContext]];
    
        NSLog(@"New object inserted");

        [feed setValue:[object valueForKey:@"objectId"] forKey:@"objectId"];
        [feed setValue:[object valueForKey:@"title"] forKey:@"title"];
        [feed setValue:[object valueForKey:@"subtitle"] forKey:@"subtitle"];
        [feed setValue:[object valueForKey:@"image_name"] forKey:@"image_name"];
    }
}

- (void)updateCoreDataObjects:(NSMutableArray *)coreDataObjects accordingToRecievedArray:(NSArray *)recievedObjects {
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Feed" inManagedObjectContext:[self managedObjectContext]];
//    Feed *feed = [[Feed alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
    for (Feed *feed in coreDataObjects) {
        if (feed.title != [recievedObjects valueForKey:@"title"]) {
            feed.title = [recievedObjects valueForKey:@"title"];
        }
        if (feed.subtitle != [recievedObjects valueForKey:@"subtitle"]) {
            feed.subtitle = [recievedObjects valueForKey:@"subtitle"];
        }
        if (feed.image_name != [recievedObjects valueForKey:@"image_name"]) {
            feed.image_name = [recievedObjects valueForKey:@"image_name"];
        }
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
    for (Feed *feedFromCoreData in objectsFromCoreData) {
        [setOfCoreDataObjects addObject:feedFromCoreData.objectId];
    }
   
    NSMutableSet *setOfObjects = [[NSMutableSet alloc] init];
    for (NSDictionary *object in objects) {
        [setOfObjects addObject:[object valueForKey:@"objectId"]];
    }

    NSMutableSet *copySetOfCoreDataObjects = [NSMutableSet setWithSet:setOfCoreDataObjects];
    NSMutableSet *copySetOfObjects = [NSMutableSet setWithSet:setOfObjects];
    
    NSMutableSet *objectsTobeDeleted = copySetOfCoreDataObjects;
    [objectsTobeDeleted minusSet:setOfObjects];
    
    NSMutableArray *arrayOfObjectsToBeDeleted = [[NSMutableArray alloc] init];
    for (Feed *object in objectsFromCoreData) {
        if ( [objectsTobeDeleted containsObject:object.objectId]) {
                [arrayOfObjectsToBeDeleted addObject:object];
            }
    }
    [self deleteObjects:arrayOfObjectsToBeDeleted];
    
    NSMutableSet *objectsToBeInserted = copySetOfObjects;
    [objectsToBeInserted minusSet:setOfCoreDataObjects];
    
    NSMutableArray *arrayOfObjectsToBeInserted = [[NSMutableArray alloc] init];
    for (NSDictionary *object in objects) {
        if ( [objectsToBeInserted containsObject:[object valueForKey:@"objectId"]]) {
            [arrayOfObjectsToBeInserted addObject:object];
        }
    }
    [self insertObjects:arrayOfObjectsToBeInserted];
    
    NSLog(@"COPYSETOFCOREDATAOBJECTS %@", setOfCoreDataObjects);

    NSMutableSet *objectsToBeUpdated = setOfCoreDataObjects;
    [objectsToBeUpdated minusSet:objectsTobeDeleted];
    
    NSMutableArray *arrayOfObjectsToBeUpdated = [[NSMutableArray alloc] init];
    for (Feed *object in objectsFromCoreData) {
        if ([objectsToBeUpdated containsObject:object.objectId]) {
            [arrayOfObjectsToBeUpdated addObject:object];
        }
    }
    [self updateCoreDataObjects:arrayOfObjectsToBeUpdated accordingToRecievedArray:objects];
    
    NSLog(@"objectsToBeUpdated count %lu", [arrayOfObjectsToBeUpdated count]);
    NSLog(@"objectsToBeInserted count %lu", [arrayOfObjectsToBeInserted count]);
    NSLog(@"objectsToBeDeleted count %lu", [arrayOfObjectsToBeDeleted count]);
    NSLog(@"objectsFromCoreData count %lu", [objectsFromCoreData count]);
    NSLog(@"Objects Recieved count %lu", [objects count]);
}

//- (void)insertNewOrUpdateObject:(NSDictionary *)object {
//    
//    NSManagedObjectContext *context = [self managedObjectContext];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Feed" inManagedObjectContext:context];
//    
//    Feed *feed = [[Feed alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
//    
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    [fetchRequest setEntity:entity];
//    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId like %@", [object valueForKey:@"objectId"]];
//    fetchRequest.predicate = predicate;
//    
//    NSArray *objects = [context executeFetchRequest:fetchRequest error:nil];
//    
//    if (objects.count > 0) {
//        feed = [objects firstObject];
//        NSLog(@"Object is updated");
//    } else {
//        feed = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
//        NSLog(@"New object added");
//    }
//    
//    [feed setValue:[object valueForKey:@"objectId"] forKey:@"objectId"];
//    [feed setValue:[object valueForKey:@"title"] forKey:@"title"];
//    [feed setValue:[object valueForKey:@"subtitle"] forKey:@"subtitle"];
//    [feed setValue:[object valueForKey:@"image_name"] forKey:@"image_name"];
//    
//}

@end
