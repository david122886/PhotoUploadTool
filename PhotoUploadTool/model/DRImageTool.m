//
//  DRImageTool.m
//  PhotoUploadTool
//
//  Created by david on 13-5-31.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import "DRImageTool.h"
#import "DRImageObj.h"
@implementation DRImageTool

+(NSArray*)parseImagesDataFromJsonStr:(NSArray*)jsonStr withUserID:(NSString*)_userID{
    if (!jsonStr) {
        return nil;
    }
    NSMutableArray *dataArr = [NSMutableArray arrayWithCapacity:[jsonStr count]];
    for (NSDictionary *dataDic in jsonStr) {
        DRImageObj *obj = [[DRImageObj alloc] init];
        obj.imageDataID = [dataDic objectForKey:@"id"];
        NSString *smallUrl = [dataDic objectForKey:@"small_photo_name"];
        if (smallUrl && ![smallUrl isEqualToString:@"<null>"]) {
            obj.smallImageURLStr = [NSString stringWithFormat:@"%@/uploads/%@/%@",LIUYUSERVER_URL,_userID,smallUrl];
        }
        NSString *largeUrl = [dataDic objectForKey:@"big_photo_name"];
        if (largeUrl && ![largeUrl isEqualToString:@"<null>"]) {
            obj.bigImageURLStr = [NSString stringWithFormat:@"%@/uploads/%@/%@",LIUYUSERVER_URL,_userID,largeUrl];
        }
        obj.describle = [dataDic objectForKey:@"describe"];
        [dataArr addObject:obj];
    }
    NSLog(@"%@",jsonStr);
    return dataArr;
}

+(void)downLoadDRImageDataWithUserID:(NSString*)_userID withType:(ImageDataType)_imageType withSuccess:(void(^)(NSArray *drImageDataArr))_success withFailure:(void(^)(NSError *error) )_failure{
    AppDelegate *appDelete = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    AFHTTPClient *client = appDelete.afhttpClient;
    int status = _imageType == PUBLIC_IMAGEDATA?1:0;
    //    [client postPath:@"/users/destroy_user"
    [client getPath:@"photos/download"
         parameters:@{@"id":_userID,@"status":[NSString stringWithFormat:@"%d",status]}
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                if (responseStr) {
                    if ([responseStr isEqualToString:@"error"]) {
                        if (_failure) {
                            _failure([DRImageTool getErrorObjWithMessage:@"下载照片失败,请重新下载"]);
                        }
                    }else{
                        NSArray *imageDatas = [DRImageTool parseImagesDataFromJsonStr:[responseStr objectFromJSONString] withUserID:_userID];
                        if (!imageDatas) {
                            if (_failure) {
                                _failure([DRImageTool getErrorObjWithMessage:@"下载照片失败,请重新下载"]);
                            }
                        }else{
                            if (_success) {
                                _success(imageDatas);
                            }
                        }
                    }
                }else{
                    if (_failure) {
                        _failure([DRImageTool getErrorObjWithMessage:@"下载照片失败,请重新下载"]);
                    }
                    
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                DRLOG(@"destroyUserObjID:%@",error);
                if ([DRImageTool judgeErrorTypeWithFailureBlock:_failure withError:error]) {
                    
                }else
                    if (_failure) {
                        _failure([DRImageTool getErrorObjWithMessage:@"注销帐户失败，请重新注销"]);
                    }
            }];
}
+(void)deleteDRImageDataWithDRImageDataID:(NSString*)_drimageDataId withSuccess:(void(^)(NSString *success))_succes withFailure:(void(^)(NSError *error) )_failure{

}
@end
