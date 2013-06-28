//
//  LocatePositionManager.m
//  DownLoadAndUPImage
//
//  Created by david on 13-5-8.
//  Copyright (c) 2013年 david. All rights reserved.
//

#import "LocatePositionManager.h"
@interface LocatePositionManager()
@property(nonatomic,strong) CLLocationManager *locationManager;
@property(nonatomic,strong) CLGeocoder *geocoder;
@property(nonatomic,strong) void(^successBlock)(NSString *locatitonName,CLLocationCoordinate2D locationg);
@property(nonatomic,strong) void(^errorBlock)(NSError *error);
@end
@implementation LocatePositionManager
static LocatePositionManager *locateManager;
+(id)defaultLocatePosition{
    if (!locateManager) {
        locateManager = [[LocatePositionManager alloc] init];
    }
    return locateManager;
}
+(void)locatePositionSuccess:(void(^)(NSString *locatitonName,CLLocationCoordinate2D locationg))success failure:(void(^)(NSError *error))error{
    if (success) {
        [[LocatePositionManager defaultLocatePosition] setSuccessBlock:success];
    }
    if (error) {
        [[LocatePositionManager defaultLocatePosition] setErrorBlock:error];
    }
    CLLocationManager *manager = [[LocatePositionManager defaultLocatePosition] locationManager];
    LocatePositionManager *myPositionManager = [LocatePositionManager defaultLocatePosition];
    if ([CLLocationManager locationServicesEnabled]) {
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
//        manager.distanceFilter = kCLDistanceFilterNone;
        manager.distanceFilter = 500.0;
        [manager startUpdatingLocation];
//        myPositionManager.myLocation = manager.location.coordinate;
//        [myPositionManager getLocationNameWithCoordinate2D:myPositionManager.myLocation];
        
    }else{
        if (myPositionManager.errorBlock) {
            myPositionManager.errorBlock([LocatePositionManager getErrorObjWithMessage:@"系统禁用定位服务"]);
        }
    }
}

+(void)stopUpdate{
   CLLocationManager *manager = [[LocatePositionManager defaultLocatePosition] locationManager];
    [manager stopUpdatingLocation];
}

-(void)getLocationNameWithCoordinate2D:(CLLocationCoordinate2D)coordinate{
    if (self.geocoder.geocoding) {
        [self.geocoder cancelGeocode];
    }else{
        CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        DRLOG(@"%@", error);
        if (error) {
            if (self.errorBlock) {
                self.errorBlock([LocatePositionManager getErrorObjWithMessage:@"error"]);
            }
        }else{
            if ([[placemarks lastObject] isKindOfClass:[CLPlacemark class]]) {
                CLPlacemark *place = [placemarks lastObject];
                if (self.successBlock) {
                    self.successBlock(place.locality,self.myLocation);
                }
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"当前城市名称" message:place.locality delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                [alert show];
            }
        }
    }];
    }
}
#pragma mark CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{

}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region{

}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    if (self.errorBlock) {
        self.errorBlock([LocatePositionManager getErrorObjWithMessage:@"系统定位失败"]);
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *location = [locations lastObject];
    [self getLocationNameWithCoordinate2D:location.coordinate];
}
-(void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager{

}

-(void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager{

}
#pragma mark --

-(CLLocationManager *)locationManager{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc]init];
        _locationManager.delegate = self;
    }
    return _locationManager;
}

-(CLGeocoder *)geocoder{
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}
@end
