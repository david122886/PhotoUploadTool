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

+(NSArray*)parseImagesDataFromJsonStr:(NSDictionary*)jsonStr withUserID:(NSString*)_userID{
    if (!jsonStr) {
        return nil;
    }
    NSString *coverImageID = nil;
    NSString *coverImage = [NSString stringWithFormat:@"%@",[jsonStr objectForKey:@"cover_image"]];
    if (coverImage && ![coverImage isEqualToString:@"<null>"]) {
        coverImageID = coverImage;
    }
    NSMutableArray *dataArr = [NSMutableArray arrayWithCapacity:[[jsonStr objectForKey:@"photo"] count]];
    for (NSDictionary *dataDic in [jsonStr objectForKey:@"photo"]) {
        DRImageObj *obj = [[DRImageObj alloc] init];
        NSString *dataId = [NSString stringWithFormat:@"%@",[dataDic objectForKey:@"id"]];
        if (dataId && ![dataId isEqualToString:@"<null>"]) {
            obj.imageDataID = dataId;
        }
        
        NSString *smallUrl = [dataDic objectForKey:@"small_photo_name"];
        if (smallUrl && ![smallUrl isEqualToString:@"<null>"]) {
            obj.smallImageURLStr = [NSString stringWithFormat:@"%@/uploads/%@/%@",LIUYUSERVER_URL,_userID,smallUrl];
        }
        NSString *largeUrl = [dataDic objectForKey:@"big_photo_name"];
        if (largeUrl && ![largeUrl isEqualToString:@"<null>"]) {
            obj.bigImageURLStr = [NSString stringWithFormat:@"%@/uploads/%@/%@",LIUYUSERVER_URL,_userID,largeUrl];
        }
        NSString *describle = [NSString stringWithFormat:@"%@",[dataDic objectForKey:@"describe"]];
        if (describle && ![describle isEqualToString:@"<null>"]) {
            obj.describle = describle;
        }
        if (coverImageID && [coverImageID isEqualToString:dataId]) {
            obj.isCoverImage = YES;
        }else{
            obj.isCoverImage = NO;
        }
        [dataArr addObject:obj];
    }
    DRLOG(@"%@", jsonStr);
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
                        _failure([DRImageTool getErrorObjWithMessage:@"下载照片失败,请重新下载"]);
                    }
            }];
}
+(void)deleteDRImageDataWithDRImageDataID:(NSString*)_drimageDataId withSuccess:(void(^)(NSString *success))_success withFailure:(void(^)(NSError *error) )_failure{
    AppDelegate *appDelete = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    AFHTTPClient *client = appDelete.afhttpClient;
    //    [client postPath:@"/users/destroy_user"
    [client getPath:@"photos/delete"
         parameters:@{@"id":[NSString stringWithFormat:@"%@",_drimageDataId]}
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                if (responseStr) {
                    if ([responseStr isEqualToString:@"success"]) {
                        if (_success) {
                            _success(@"删除照片成功");
                        }
                    }else
                        if([responseStr isEqualToString:@"error"]){
                            if (_failure) {
                                _failure([DRImageTool getErrorObjWithMessage:@"删除照片失败"]);
                            }
                        }else{
                            if (_failure) {
                                _failure([DRImageTool getErrorObjWithMessage:@"删除照片失败"]);
                            }
                        }
                }else{
                    if (_failure) {
                        _failure([DRImageTool getErrorObjWithMessage:@"删除照片失败"]);
                    }
                    
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                DRLOG(@"destroyUserObjID:%@",error);
                if ([DRImageTool judgeErrorTypeWithFailureBlock:_failure withError:error]) {
                    
                }else
                    if (_failure) {
                        _failure([DRImageTool getErrorObjWithMessage:@"删除照片失败"]);
                    }
            }];
}

+(void)setCoverImageWithUserID:(NSString*)_userID withPhotoID:(NSString*)_photoID withSuccess:(void(^)(NSString *success))_success withFailure:(void(^)(NSError *error) )_failure{
//    http://192.168.0.137:3000/users/set_cover?user_id=1&photo_id=2
    AppDelegate *appDelete = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    AFHTTPClient *client = appDelete.afhttpClient;
    //    [client postPath:@"/users/destroy_user"
    [client getPath:@"users/set_cover"
         parameters:@{@"user_id":_userID,@"photo_id":_photoID?:@"1"}
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                if (responseStr) {
                    if ([responseStr isEqualToString:@"success"]) {
                        if (_success) {
                            _success(@"设置封面成功");
                        }
                    }else
                        if([responseStr isEqualToString:@"usererror"]){
                            if (_failure) {
                                _failure([DRImageTool getErrorObjWithMessage:@"无法设置封面，该用户已经不存在"]);
                            }
                        }else
                    if([responseStr isEqualToString:@"photoerror"]){
                        if (_failure) {
                            _failure([DRImageTool getErrorObjWithMessage:@"当前照片已经被删除"]);
                        }
                    }
                        else{
                            if (_failure) {
                                _failure([DRImageTool getErrorObjWithMessage:@"设置封面照片失败"]);
                            }
                        }
                }else{
                    if (_failure) {
                        _failure([DRImageTool getErrorObjWithMessage:@"设置封面照片失败"]);
                    }
                    
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                DRLOG(@"destroyUserObjID:%@",error);
                if ([DRImageTool judgeErrorTypeWithFailureBlock:_failure withError:error]) {
                    
                }else
                    if (_failure) {
                        _failure([DRImageTool getErrorObjWithMessage:@"设置封面照片失败"]);
                    }
            }];
}

+(void)reportImageWithUserID:(NSString*)_userID withPhotoID:(NSString*)_photoID withSuccess:(void(^)(NSString *success))_success withFailure:(void(^)(NSError *error) )_failure{
    //    http://192.168.0.137:3000/users/set_cover?user_id=1&photo_id=2
    AppDelegate *appDelete = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    AFHTTPClient *client = appDelete.afhttpClient;
    //    [client postPath:@"/users/destroy_user"
    [client getPath:@"admins/report_user"
         parameters:@{@"id":_photoID?:@""}
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                if (responseStr) {
                    if ([responseStr isEqualToString:@"success"]) {
                        if (_success) {
                            _success(@"举报成功");
                        }
                    }else
                        if (_failure) {
                            _failure([DRImageTool getErrorObjWithMessage:@"举报失败"]);
                        }
                }else{
                    if (_failure) {
                        _failure([DRImageTool getErrorObjWithMessage:@"举报失败"]);
                    }
                    
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                DRLOG(@"destroyUserObjID:%@",error);
                if ([DRImageTool judgeErrorTypeWithFailureBlock:_failure withError:error]) {
                    
                }else
                    if (_failure) {
                        _failure([DRImageTool getErrorObjWithMessage:@"举报失败"]);
                    }
            }];
}
@end
