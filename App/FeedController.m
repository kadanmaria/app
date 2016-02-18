//
//  FeedController.m
//  App
//
//  Created by Admin on 18.02.16.
//  Copyright © 2016 OrgName. All rights reserved.
//

#import "FeedController.h"
#import "Feed.h"

@interface FeedController ()

@end

@implementation FeedController

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
//    NSPersistentStoreCoordinator *thePersistentStoreCoordinator = [[self managedObjectContext] persistentStoreCoordinator];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Error %@, %@", error, [error userInfo]);
    }
}

- (void)insertNewOrUpdateObject:(NSDictionary *)object {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Feed" inManagedObjectContext:context];
    
    Feed *feed = [[Feed alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId like %@", [object valueForKey:@"objectId"]];
    fetchRequest.predicate = predicate;
    
    NSArray *objects = [context executeFetchRequest:fetchRequest error:nil];
    
    if (objects.count > 0) {
        feed = [objects firstObject];
        NSLog(@"Object is updated");
    } else {
        feed = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
        NSLog(@"New object added");
    }
    
    [feed setValue:[object valueForKey:@"objectId"] forKey:@"objectId"];
    [feed setValue:[object valueForKey:@"title"] forKey:@"title"];
    [feed setValue:[object valueForKey:@"subtitle"] forKey:@"subtitle"];
    [feed setValue:[object valueForKey:@"image_name"] forKey:@"image_name"];
    
}


@end
