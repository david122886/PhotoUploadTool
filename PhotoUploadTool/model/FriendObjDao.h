//
//  FriendObjDao.h
//  PhotoUploadTool
//
//  Created by david on 13-7-1.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FriendObj.h"
#import "DRNetWorkingException.h"
@interface FriendObjDao : DRNetWorkingException
+(void)downloadFriendObjsWithCityName:(NSString*)_cityName withPageIndex:(int)_pageIndex withSuccess:(void (^)(NSArray *friendsArr))_success withfailure:(void (^)(NSError *error))_failure;
@end
