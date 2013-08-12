//
//  LocatePositionManager.h
//  DownLoadAndUPImage
//
//  Created by david on 13-5-8.
//  Copyright (c) 2013年 david. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "DRNetWorkingException.h"
@interface LocatePositionManager: DRNetWorkingException<CLLocationManagerDelegate>
@property(nonatomic,assign) CLLocationCoordinate2D myLocation;
+(id)defaultLocatePosition;
+(void)stopUpdate;

+(void)locatePositionSuccess:(void(^)(NSString *locatitonName,CLLocationCoordinate2D locationg))success failure:(void(^)(NSError *error))error;
@end
