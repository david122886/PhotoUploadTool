//
//  AppDelegate.h
//  PhotoUploadTool
//
//  Created by david on 13-5-14.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import "UserObj.h"
#import "MBProgressHUD.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) AFHTTPClient *afhttpClient;
@property ( strong, nonatomic) UserObj *user;
@property ( strong, nonatomic)  NSString *token;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
