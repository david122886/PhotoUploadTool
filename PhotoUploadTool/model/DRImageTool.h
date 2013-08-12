//
//  DRImageTool.h
//  PhotoUploadTool
//
//  Created by david on 13-5-31.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRGridViewData.h"
#import "DRNetWorkingException.h"
typedef enum {PUBLIC_IMAGEDATA,PRIVATE_IMAGEDATA}ImageDataType;
@interface DRImageTool : DRNetWorkingException
+(void)downLoadDRImageDataWithUserID:(NSString*)_userID withType:(ImageDataType)_imageType withSuccess:(void(^)(NSArray *drImageDataArr))_success withFailure:(void(^)(NSError *error) )_failure;
+(void)deleteDRImageDataWithDRImageDataID:(NSString*)_drimageDataId withSuccess:(void(^)(NSString *success))_success withFailure:(void(^)(NSError *error) )_failure;

+(void)setCoverImageWithUserID:(NSString*)_userID withPhotoID:(NSString*)_photoID withSuccess:(void(^)(NSString *success))_success withFailure:(void(^)(NSError *error) )_failure;
@end
