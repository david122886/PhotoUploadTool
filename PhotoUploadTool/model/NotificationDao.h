//
//  NotificationDao.h
//  PhotoUploadTool
//
//  Created by david on 13-6-3.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRNetWorkingException.h"
@interface NotificationDao : DRNetWorkingException

+(void)notificationDaoDownloadWithUserObjID:(NSString*)_userID WithSuccess:(void(^)(NSArray* notificationArr))_success withFailure:(void(^)(NSError *error))_failure;

+(void)deleteNotificationWithUserObjID:(NSString*)_userID withNotID:(NSString*)_notificationID withSuccess:(void(^)(NSArray* notificationArr))_success withFailure:(void(^)(NSError *error))_failure;
@end
