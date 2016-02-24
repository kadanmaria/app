//
//  AuthorizationManager.h
//  App
//
//  Created by Admin on 23.02.16.
//  Copyright © 2016 OrgName. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AuthorizationManager;

@protocol AuthorizationManagerDelegate <NSObject>

- (void)authorizationManager:(AuthorizationManager *)manager hasRecievedUserToken:(NSString *)token forLogin:(NSString *)login;

@end

@interface AuthorizationManager : NSObject

@property (weak, nonatomic) id <AuthorizationManagerDelegate> delegate;

- (void)loginWithLogin:(NSString *)login password:(NSString *)password;
- (void)isSessionValidWithUserToken:(NSString *)token completion:(void(^)(bool isValid))completion ;

@end
