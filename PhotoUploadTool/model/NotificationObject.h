//
//  NotificationObject.h
//  PhotoUploadTool
//
//  Created by david on 13-5-24.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationObject : NSObject
@property(nonatomic,strong) NSString *date;
@property(nonatomic,strong) NSString *deail;
@property(nonatomic,strong) NSNumber *isExpand;
+(NotificationObject*)initNotificationWithDateStr:(NSString*)dateStr withDetailStr:(NSString*)detailStr;
@end
