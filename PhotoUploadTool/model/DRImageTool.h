//
//  DRImageTool.h
//  PhotoUploadTool
//
//  Created by david on 13-5-31.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRGridViewData.h"
@interface DRImageTool : NSObject
+(void)downLoadDRImageDataWithUserID:(NSString*)_userId withSuccess:(void(^)(NSArray *drImageDataArr))_succes withFailure:(void(^)(NSError *error) )_failure;
+(void)deleteDRImageDataWithDRImageDataID:(NSString*)_drimageDataId withSuccess:(void(^)(NSString *success))_succes withFailure:(void(^)(NSError *error) )_failure;
@end
