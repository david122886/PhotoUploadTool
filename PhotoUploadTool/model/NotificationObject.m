//
//  NotificationObject.m
//  PhotoUploadTool
//
//  Created by david on 13-5-24.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import "NotificationObject.h"

@implementation NotificationObject
+(NotificationObject*)initNotificationWithDateStr:(NSString*)dateStr withDetailStr:(NSString*)detailStr{
    NotificationObject *notification = [[NotificationObject alloc] init];
    notification.date = dateStr;
    notification.deail = detailStr;
    return notification;
}
@end
