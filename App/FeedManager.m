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

@property (strong, nonatomic) NSManagedObjectContext *backgroundContext;

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

#pragma mark - FetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Feed"];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    [fetchRequest setFetchBatchSize:10];
    
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:self.managedObjectContext
                                                                                                 sectionNameKeyPath:nil cacheName:@"Cache"];
    self.fetchedResultsController = fetchedResultsController;
    
    return _fetchedResultsController;
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
        NSLog(@"Error initializing MainContext");
    }
    NSManagedObjectContext *backgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    backgroundContext.parentContext = managedObjectContext;
    if (!backgroundContext) {
        NSLog(@"Error initializing BackgroundContext");
    }
    self.backgroundContext = backgroundContext;
    
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

    NSManagedObjectContext *mainContext = [self managedObjectContext];
    NSManagedObjectContext *backgroundContext = [self backgroundContext];
    
    [backgroundContext performBlock:^{

        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Feed" inManagedObjectContext:backgroundContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];

        NSError *error;
        NSArray *objectsFromCoreData = [backgroundContext executeFetchRequest:fetchRequest error:&error];
        if (error) {
            NSLog(@"Error fetching data %@, %@", error, [error userInfo]);
        }
        
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
        }
        
        NSError *savingBackgroundContextError = nil;
        if (![backgroundContext save:&savingBackgroundContextError]) {
            NSLog(@"Unresolved error %@, %@", savingBackgroundContextError, [savingBackgroundContextError userInfo]);
        }
        
        [mainContext performBlock:^{
            NSError *savingMainContextError = nil;
            if (![mainContext save:&savingMainContextError]) {
                NSLog(@"Unresolved error %@, %@", savingMainContextError, [savingMainContextError userInfo]);
            }
        }];
        
    }];
}

- (void)deleteObjects:(NSMutableArray *)objects {
    for (NSManagedObject *object in objects) {
        [[self backgroundContext] deleteObject:object];
    }
}

- (void)insertObjects:(NSMutableArray *)objects {
    for (NSDictionary *object in objects) {
        Feed *feed = [NSEntityDescription insertNewObjectForEntityForName:@"Feed" inManagedObjectContext:[self backgroundContext]];

        [feed setValue:[object valueForKey:@"objectId"] forKey:@"objectId"];
        [feed setValue:[object valueForKey:@"subtitle"] forKey:@"subtitle"];
        [feed setValue:[object valueForKey:@"title"] forKey:@"title"];
        [feed setValue:[object valueForKey:@"imageName"] forKey:@"imageName"];
        
    }
}

- (void)updateObjects:(NSMutableArray *)coreDataObjects accordingToRecievedArray:(NSArray *)recievedObjects {
    for (Feed *feed in coreDataObjects) {
        for (NSDictionary *object in recievedObjects) {
            
            if ([[feed valueForKey:@"objectId"] isEqualToString:[object valueForKey:@"objectId"]]) {
                
                if (![[feed valueForKey:@"title"] isEqualToString:[object valueForKey:@"title"]]) {
                     [feed setValue:[object valueForKey:@"title"] forKey:@"title"];
                }
                if (![[feed valueForKey:@"subtitle"] isEqualToString:[object valueForKey:@"subtitle"]]) {
                    [feed setValue:[object valueForKey:@"subtitle"] forKey:@"subtitle"];
                }
                if (![[feed valueForKey:@"imageName"] isEqualToString:[object valueForKey:@"imageName"]]) {
                   [feed setValue:[object valueForKey:@"imageName"] forKey:@"imageName"];
                }
                
            }
        }
    }
}

@end
