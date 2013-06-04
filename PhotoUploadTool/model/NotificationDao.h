//
//  NotificationDao.h
//  PhotoUploadTool
//
//  Created by david on 13-6-3.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationDao : NSObject
-(void)notificationDaoDownloadWithSuccess:(void(^)(NSArray* notificationArr))_success withFailure:(void(^)(NSError *error))_failure;
@end
