//
//  NotificationDao.h
//  PhotoUploadTool
//
//  Created by david on 13-6-3.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRNetWorkingException.h"
#import "NotificationObject.h"
@interface NotificationDao : DRNetWorkingException

+(void)notificationDaoDownloadWithUserObjID:(NSString*)_userID WithSuccess:(void(^)(NSArray* notificationArr))_success withFailure:(void(^)(NSError *error))_failure;

+(void)deleteNotificationWithNotificationID:(NSString*)_userID withNotID:(NSString*)_notificationID withSuccess:(void(^)(NSString* success))_success withFailure:(void(^)(NSError *error))_failure;
@end
