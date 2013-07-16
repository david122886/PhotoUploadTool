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
+(void)downloadFriendObjsWithCityName:(NSString*)_cityName withPageIndex:(int)_pageIndex withSuccess:(void (^)(NSDictionary *friendsDic))_success withfailure:(void (^)(NSError *error))_failure;
+(void)identifyFriendAlbumPwdWithFriendObjID:(NSString*)_friendID withAlbumPwd:(NSString*)_albumPwd withSuccess:(void (^)(NSString *success))_success withfailure:(void (^)(NSError *error))_failure;
@end
