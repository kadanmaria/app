//
//  Feed+CoreDataProperties.h
//  App
//
//  Created by Admin on 02.03.16.
//  Copyright © 2016 OrgName. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Feed.h"

NS_ASSUME_NONNULL_BEGIN

@interface Feed (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *hasChanged;
@property (nullable, nonatomic, retain) NSString *imageName;
@property (nullable, nonatomic, retain) NSData *localImage;
@property (nullable, nonatomic, retain) NSString *objectId;
@property (nullable, nonatomic, retain) NSString *subtitle;
@property (nullable, nonatomic, retain) NSString *title;

@end

NS_ASSUME_NONNULL_END
