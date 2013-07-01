//
//  FriendObjDao.m
//  PhotoUploadTool
//
//  Created by david on 13-7-1.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import "FriendObjDao.h"

@implementation FriendObjDao
//+(void)downloadFriendObjsWithCityName:(NSString*)_cityName withPageIndex:(int)_pageIndex withSuccess:(void (^)(NSArray *friendsArr))_success withfailure:(void (^)(NSError *error))_failure{
//    AppDelegate *appDelete = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//    AFHTTPClient *client = appDelete.afhttpClient;
//    //    http://192.168.1.12:3000/users/users_citys?name=苏州
//    //    [client postPath:@"users/change_city"
//    [client getPath:@"users/users_citys"
//         parameters:@{@"name":_cityName?:@"all"}
//            success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//                if (responseStr) {
//                    if (responseStr.length < 6 && [responseStr isEqualToString:@"false"]) {
//                        if (_failure) {
//                            _failure([FriendObjDao getErrorObjWithMessage:@"获取用户列表失败"]);
//                        }
//                    }else{
//                        NSArray *objArr = [FriendObjDao convertFriendsObjFromJsonArr:[responseObject objectFromJSONString]];
//                        if (objArr) {
//                            if (_success) {
//                                _success(objArr);
//                            }
//                        }else{
//                            if (_failure) {
//                                _failure([FriendObjDao getErrorObjWithMessage:@"获取用户列表失败"]);
//                            }
//                        }
//                    }
//                }else{
//                    if (_failure) {
//                        _failure([FriendObjDao getErrorObjWithMessage:@"获取用户列表失败"]);
//                    }
//                }
//                
//            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                DRLOG(@"downloadFriendObjsWithCityName%@",error);
//                if ([FriendObjDao judgeErrorTypeWithFailureBlock:_failure withError:error]) {
//                    
//                }else
//                    if (_failure) {
//                        _failure([FriendObjDao getErrorObjWithMessage:@"获取用户列表失败"]);
//                    }
//            }];
//}


+(void)downloadFriendObjsWithCityName:(NSString*)_cityName withPageIndex:(int)_pageIndex withSuccess:(void (^)(NSArray *friendsArr))_success withfailure:(void (^)(NSError *error))_failure{
    NSMutableArray  *objArr = [NSMutableArray array];
    for (int index = 0; index < 30; index++) {
        FriendObj *obj = [[FriendObj alloc] init];
        obj.friendID = [NSString stringWithFormat:@"%d",index];
        obj.webURL = @"http://ww4.sinaimg.cn/mw600/9ca9e24agw1e665f1ctynj20dw0jqadc.jpg";
        [objArr addObject:obj];
    }
    if (_success) {
        _success(objArr);
    }
}
+(NSArray*)convertFriendsObjFromJsonArr:(NSArray*)_jsonStrArr{
    return _jsonStrArr;
}
@end
