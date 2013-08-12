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
@property(nonatomic,assign) BOOL isAlertError;
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
    myPositionManager.isAlertError = NO;
    if ([CLLocationManager locationServicesEnabled]) {
        CLAuthorizationStatus locationStatus = [CLLocationManager authorizationStatus];
        switch (locationStatus) {
            case kCLAuthorizationStatusNotDetermined:
                ;
            case kCLAuthorizationStatusAuthorized:
                manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
                //        manager.distanceFilter = kCLDistanceFilterNone;
                manager.distanceFilter = 500.0;
//                [manager startMonitoringSignificantLocationChanges];
                [manager startUpdatingLocation];
                break;
            case kCLAuthorizationStatusDenied:
                if (myPositionManager.errorBlock && !myPositionManager.isAlertError) {
                    myPositionManager.errorBlock([LocatePositionManager getErrorObjWithMessage:@"系统禁用定位服务"]);
                    myPositionManager.isAlertError = YES;
                }
                break;
            default:
                break;
        }
//        myPositionManager.myLocation = manager.location.coordinate;
//        [myPositionManager getLocationNameWithCoordinate2D:myPositionManager.myLocation];
        
    }else{
        if (myPositionManager.errorBlock && !myPositionManager.isAlertError) {
            myPositionManager.errorBlock([LocatePositionManager getErrorObjWithMessage:@"系统不支持定位服务"]);
            myPositionManager.isAlertError = YES;
        }
    }
}

+(void)stopUpdate{
   CLLocationManager *manager = [[LocatePositionManager defaultLocatePosition] locationManager];
//    [manager stopMonitoringSignificantLocationChanges];
    [manager stopUpdatingLocation];
}

-(void)getLocationNameWithCoordinate2D:(CLLocationCoordinate2D)coordinate{
    if (self.geocoder.geocoding) {
        [self.geocoder cancelGeocode];
    }
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        DRLOG(@"%@", error);
        if (error) {
            if (self.errorBlock && !self.isAlertError) {
                self.errorBlock([LocatePositionManager getErrorObjWithMessage:@"获取地理位置失败"]);
                self.isAlertError = YES;
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
#pragma mark CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{

}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region{

}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"%@",error);
   
    if ([error domain] == kCLErrorDomain) {
        
        // We handle CoreLocation-related errors here
        switch ([error code]) {
                // "Don't Allow" on two successive app launches is the same as saying "never allow". The user
                // can reset this for all apps by going to Settings > General > Reset > Reset Location Warnings.
            case kCLErrorDenied:
                if (self.errorBlock && !self.isAlertError) {
                    self.errorBlock([LocatePositionManager getErrorObjWithMessage:@"流云相册没有权限启动定位服务，到设备系统设置中开启"]);
                    self.isAlertError = YES;
                }
                break;
            case kCLErrorRegionMonitoringDenied:
                if (self.errorBlock && !self.isAlertError) {
                    self.errorBlock([LocatePositionManager getErrorObjWithMessage:@"流云相册没有权限启动定位服务，到设备系统设置中开启"]);
                    self.isAlertError = YES;
                }
                break;
            default:
                if (self.errorBlock && !self.isAlertError) {
                    self.errorBlock([LocatePositionManager getErrorObjWithMessage:@"系统定位失败"]);
                    self.isAlertError = YES;
                }
                break;
        }
    } else {
        // We handle all non-CoreLocation errors here
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
