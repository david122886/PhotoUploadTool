//
//  NotificationDao.m
//  PhotoUploadTool
//
//  Created by david on 13-6-3.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import "NotificationDao.h"

@implementation NotificationDao
+(void)notificationDaoDownloadWithUserObjID:(NSString*)_userID WithSuccess:(void(^)(NSArray* notificationArr))_success withFailure:(void(^)(NSError *error))_failure{
    if (_failure) {
        _failure([NotificationDao getErrorObjWithMessage:@"加载通知失败"]);
    }
}

+(void)deleteNotificationWithUserObjID:(NSString*)_userID withNotID:(NSString*)_notificationID withSuccess:(void(^)(NSArray* notificationArr))_success withFailure:(void(^)(NSError *error))_failure{

}
@end
