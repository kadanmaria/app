//
//  Data.h
//  App
//
//  Created by Admin on 11.02.16.
//  Copyright © 2016 OrgName. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONDelegate.h"

@interface Data : NSObject <NSURLConnectionDataDelegate> {
    NSURLConnection *currentConnection;
}

@property (strong, nonatomic) NSMutableData *returnedData;
@property (weak, nonatomic) id<JSONDelegate> JSONDelegate;

- (void)getData;

@end
