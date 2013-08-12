//
//  AppDelegate.m
//  PhotoUploadTool
//
//  Created by david on 13-5-14.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import "AppDelegate.h"
#import "UserObjDao.h"
#import "DRNetWorkingException.h"
#import "LocatePositionManager.h"
#define  DEFAULT_TOKEN @"default_token"
@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize afhttpClient = _afhttpClient;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    // Override point for customization after application launch.
//    self.window.backgroundColor = [UIColor whiteColor];
//    [self.window makeKeyAndVisible];
//    UIImage *NavigationPortraitBackground = [[UIImage imageNamed:@"tabbarbg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    // Create image for navigation background - landscape
    
//    UIImage *NavigationLandscapeBackground = [[UIImage imageNamed:@"NavigationLandscapeBackground"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    
    // Set the background image all UINavigationBars
    
//    [[UINavigationBar appearance] setBackgroundImage:NavigationPortraitBackground forBarMetrics:UIBarMetricsDefault];
//    [[UINavigationBar appearance] setBackgroundImage:NavigationLandscapeBackground forBarMetrics:UIBarMetricsLandscapePhone];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 50;
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:LOCATE_POSITION_TYPE];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [self saveContext];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:LOCATE_POSITION_TYPE];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSLog(@"My token is: %@", deviceToken);
    self.token = [[[[deviceToken description]
                    stringByReplacingOccurrencesOfString: @"<" withString: @""]
                   stringByReplacingOccurrencesOfString: @">" withString: @""]
                  stringByReplacingOccurrencesOfString: @" " withString: @""];
    NSString *defaultToken = [[NSUserDefaults standardUserDefaults] objectForKey:DEFAULT_TOKEN];
    if (!self.user) {
        return;
    }
    if (!defaultToken || ![defaultToken isEqualToString:self.token]) {
        [UserObjDao setAPNSTokenUserObjId:self.user.userId withToken:self.token withSuccess:nil withFailure:nil];
        [[NSUserDefaults standardUserDefaults] setObject:self.token forKey:DEFAULT_TOKEN];
    }
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    DRLOG(@"idReceiveRemoteNotification::%@", userInfo);
}
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PhotoUploadTool" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"PhotoUploadTool.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

-(void)setAutoLocationForController:(UIViewController*)contr{
    UIViewController __weak *weakContr = contr;
    NSNumber *locatePosionType = [[NSUserDefaults standardUserDefaults] objectForKey:LOCATE_POSITION_TYPE];
    if (!locatePosionType) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:LOCATE_POSITION_TYPE];
    }
    AppDelegate __weak *weakSelf = self;
    if (!locatePosionType || [locatePosionType boolValue] == YES) {
        [LocatePositionManager locatePositionSuccess:^(NSString *locatitonName, CLLocationCoordinate2D locationg) {
            NSString *cityS = nil;
            if (locatitonName) {
                cityS = [locatitonName stringByReplacingOccurrencesOfString:@"市" withString:@""];
            }
            weakSelf.city = cityS;
            [[NSUserDefaults standardUserDefaults] setObject:cityS forKey:LAST_LOCATION_CITY];
            [[NSNotificationCenter defaultCenter] postNotificationName:LOCATE_POSITION_SUCCESS object:weakContr userInfo:@{@"city": cityS?:@""}];
//            [weakSelf updateUserLocationForBack:weakSelf.user updateCity:cityS];
        } failure:^(NSError *error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:LOCATE_POSITION_FAILURE object:weakContr userInfo:@{@"error": [[error userInfo] objectForKey:@"NSLocalizedDescription"]?:@""}];
        }];
    }
}

-(void)updateUserLocationForBack:(UserObj *)userObj updateCity:(NSString*)locate{
    if (userObj) {
        [UserObjDao modifyUserLocationUserObjId:userObj.userId withUserLocation:locate withSuccess:^(NSString *success) {
        } withFailure:^(NSError *errror) {            
        }];
    }
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark property
-(AFHTTPClient *)afhttpClient{
    if (!_afhttpClient) {
        _afhttpClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:LIUYUSERVER_URL]];
    }
    return _afhttpClient;
}

#pragma mark --
@end
