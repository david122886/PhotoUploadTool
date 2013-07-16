//
//  FriendObjDao.m
//  PhotoUploadTool
//
//  Created by david on 13-7-1.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import "FriendObjDao.h"

@implementation FriendObjDao
+(void)downloadFriendObjsWithCityName:(NSString*)_cityName withPageIndex:(int)_pageIndex withSuccess:(void (^)(NSDictionary *friendsDic))_success withfailure:(void (^)(NSError *error))_failure{
    AppDelegate *appDelete = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    AFHTTPClient *client = appDelete.afhttpClient;
    //    http://192.168.1.12:3000/users/users_citys?name=苏州
    //    [client postPath:@"users/change_city"
    [client getPath:@"users/users_citys"
         parameters:@{@"name":_cityName?:@"all",@"page":[NSString stringWithFormat:@"%d",_pageIndex+1]}
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                if (responseStr) {
                    if (responseStr.length < 6 && [responseStr isEqualToString:@"false"]) {
                        if (_failure) {
                            _failure([FriendObjDao getErrorObjWithMessage:@"获取用户列表失败"]);
                        }
                    }else{
                        NSDictionary *objDic = [FriendObjDao convertFriendsObjFromJsonArr:[responseStr objectFromJSONString]];
                        if (objDic) {
                            if (_success) {
                                _success(objDic);
                            }
                        }else{
                            if (_failure) {
                                _failure([FriendObjDao getErrorObjWithMessage:@"获取用户列表失败"]);
                            }
                        }
                    }
                }else{
                    if (_failure) {
                        _failure([FriendObjDao getErrorObjWithMessage:@"获取用户列表失败"]);
                    }
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                DRLOG(@"downloadFriendObjsWithCityName%@",error);
                if ([FriendObjDao judgeErrorTypeWithFailureBlock:_failure withError:error]) {
                    
                }else
                    if (_failure) {
                        _failure([FriendObjDao getErrorObjWithMessage:@"获取用户列表失败"]);
                    }
            }];
}


//+(void)downloadFriendObjsWithCityName:(NSString*)_cityName withPageIndex:(int)_pageIndex withSuccess:(void (^)(NSArray *friendsArr))_success withfailure:(void (^)(NSError *error))_failure{
//    NSMutableArray  *objArr = [NSMutableArray array];
//    for (int index = 0; index < 150; index++) {
//        FriendObj *obj = [[FriendObj alloc] init];
//        obj.friendID = [NSString stringWithFormat:@"%d",index];
//        obj.webURL = @"http://ww4.sinaimg.cn/mw600/9ca9e24agw1e665f1ctynj20dw0jqadc.jpg";
//        [objArr addObject:obj];
//    }
//    if (_success) {
//        _success(objArr);
//    }
//}

+(void)identifyFriendAlbumPwdWithFriendObjID:(NSString*)_friendID withAlbumPwd:(NSString*)_albumPwd withSuccess:(void (^)(NSString *success))_success withfailure:(void (^)(NSError *error))_failure{
    AppDelegate *appDelete = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    AFHTTPClient *client = appDelete.afhttpClient;
    
    [client getPath:@"photos/friends_pwd"
         parameters:@{@"id":_friendID,@"photo_pwd":_albumPwd}
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];;
                if (responseStr) {
                    if ([responseStr isEqualToString:@"error"]) {
                        if (_failure) {
                            _failure([FriendObjDao getErrorObjWithMessage:@"相册密码不正确，请重新输入"]);
                        }
                    }else
                    if ([responseStr isEqualToString:@"success"]) {
                        if (_success) {
                            _success(@"success");
                        }
                    }else{
                        if (_failure) {
                            _failure([FriendObjDao getErrorObjWithMessage:@"相册密码匹配失败，请重试"]);
                        }
                    }
                }else{
                    if (_failure) {
                        _failure([FriendObjDao getErrorObjWithMessage:@"相册密码匹配失败，请重试"]);
                    }
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                DRLOG(@"identifyFriendAlbumPwdWithFriendObjID:%@",error);
                if ([FriendObjDao judgeErrorTypeWithFailureBlock:_failure withError:error]) {
                    
                }else
                    if (_failure) {
                        _failure([FriendObjDao getErrorObjWithMessage:@"相册密码匹配失败，请重试"]);
                    }
            }];
}


+(NSDictionary*)convertFriendsObjFromJsonArr:(NSDictionary*)_jsonStrDic{
    if (!_jsonStrDic) {
        return nil;
    }
    DRLOG(@"%@", _jsonStrDic);
    NSMutableDictionary *friendsDic = [NSMutableDictionary dictionaryWithCapacity:[_jsonStrDic count]];
    NSString *pageCount = [NSString stringWithFormat:@"%@",[_jsonStrDic objectForKey:@"page"]];
    NSString *city = [NSString stringWithFormat:@"%@",[_jsonStrDic objectForKey:@"current_city"]];
    if (city && ![city isEqualToString:@"<null>"] && ![city isEqualToString:@"error"]) {
        [friendsDic setObject:city forKey:@"city"];
    }else{
        [friendsDic setObject:@"error" forKey:@"city"];
    }

    if (pageCount && ![pageCount isEqualToString:@"<null>"]) {
        [friendsDic setObject:pageCount forKey:@"pageCount"];
    }else{
        [friendsDic setObject:@"1" forKey:@"pageCount"];
    }
    NSArray *friends = [_jsonStrDic objectForKey:@"user"];
    NSMutableArray *friendsArr = [NSMutableArray arrayWithCapacity:[friends count]];
    for (NSDictionary *obj in friends) {
        NSString *friendID = [NSString stringWithFormat:@"%@",[obj objectForKey:@"id"]];
        if (friendID  && ![friendID isEqualToString:@"<null>"]) {
            
        }else{
            continue;
        }
        
        NSString *smallImage = [obj objectForKey:@"small_photo"];
        NSString *friendWebUrl = nil;
        if (smallImage  && ![smallImage isEqualToString:@"<null>"]) {
            friendWebUrl = [NSString stringWithFormat:@"%@/uploads/%@/%@",LIUYUSERVER_URL,friendID,smallImage];
        }else{
            continue;
        }
        
        FriendObj *friend = [[FriendObj alloc] init];
        friend.friendID = friendID;
        friend.webURL = friendWebUrl;
        [friendsArr addObject:friend];
    }
    [friendsDic setObject:friendsArr forKey:@"users"];
    return friendsDic;
}
@end
