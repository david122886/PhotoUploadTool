//
//  UserObjDao.m
//  PhotoUploadTool
//
//  Created by david on 13-5-31.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import "UserObjDao.h"
@interface UserObjDao()

@end
@implementation UserObjDao

+(UserObj*)convertUserObjFromJsonDic:(NSDictionary*)jsonStr{
    if (!jsonStr) {
        return nil;
    }
    DRLOG(@"%@",jsonStr);
    NSString *userID = [NSString stringWithFormat:@"%@",[jsonStr objectForKey:@"id"]];
    if (!userID || [userID isEqualToString:@"<null>"]) {
        return nil;
    }
    UserObj *user = [[UserObj alloc] init];
    user.userId = userID;
    
    NSString *location = [NSString stringWithFormat:@"%@",[jsonStr objectForKey:@"city_id"]];
    if (location && ![[location class] isSubclassOfClass:[NSNull class]] && ![location isEqualToString:@"<null>"]) {
         user.userLocation = location;
    }
    
    NSString *name = [jsonStr objectForKey:@"name"];
    if (name && ![[name class] isSubclassOfClass:[NSNull class]] && ![name isEqualToString:@"<null>"]) {
        user.userName = name;
    }
    
    NSString *email = [jsonStr objectForKey:@"email"];
    if (email && ![[email class] isSubclassOfClass:[NSNull class]] && ![email isEqualToString:@"<null>"]) {
        user.userEmail = email;
    }
    
    NSString *albumPwd = [jsonStr objectForKey:@"photo_password"];
    if (albumPwd && ![[albumPwd class] isSubclassOfClass:[NSNull class]] && ![albumPwd isEqualToString:@"<null>"]) {
         user.userAlbumPwd = [FBEncryptorAES decryptBase64String:albumPwd keyString:ENCRYPT_KEY];
    }
    NSString *pwd = [jsonStr objectForKey:@"password"];
    if (pwd && ![[pwd class] isSubclassOfClass:[NSNull class]] && ![pwd isEqualToString:@"<null>"]) {
        user.userPwd = [FBEncryptorAES decryptBase64String:pwd keyString:ENCRYPT_KEY];
    }
    
    NSString *webURL = [jsonStr objectForKey:@"url"];
    if (webURL && ![[webURL class] isSubclassOfClass:[NSNull class]] && ![webURL isEqualToString:@"<null>"]) {
        user.userWebURL = webURL;
    }
    
    NSString *describle = [jsonStr objectForKey:@"describle"];
    if (describle && ![[describle class] isSubclassOfClass:[NSNull class]] && ![describle isEqualToString:@"<null>"]) {
        user.userDescrible = describle;
    }
    
    if (user.userId == nil  && user.userName == nil) {
        return nil;
    }
    return user;
}


+(void)registerUserObj:(UserObj*)_user withSuccess:(void(^)(UserObj *userObj))_success withFailure:(void(^)(NSError *errror))_failure{
    AppDelegate *appDelete = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    AFHTTPClient *client = appDelete.afhttpClient;
    NSString *pwd = [FBEncryptorAES encryptBase64String:_user.userPwd keyString:ENCRYPT_KEY separateLines:NO];
       [client getPath:@"users/register"
//    [client postPath:@"users/register"
          parameters:@{@"name":_user.userName,@"password":pwd,@"email":_user.userEmail}
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                 if (responseStr) {
                     if ([responseStr isEqualToString:@"close"]) {
                         if (_failure) {
                             _failure([UserObjDao getErrorObjWithMessage:@"用户注册功能暂时关闭，请稍候再试"]);
                         }
                     }else
                        if([responseStr isEqualToString:@"cityerror"]){
                            if (_failure) {
                                _failure([UserObjDao getErrorObjWithMessage:@"注册的城市不存在"]);
                            }
                     }else
                     if ([responseStr isEqualToString:@"emailerror"]) {
                         if (_failure) {
                             _failure([UserObjDao getErrorObjWithMessage:@"用户名或者邮箱地址已经存在"]);
                         }
                     }else
                     if ([responseStr isEqualToString:@"nameerror"]) {
                         if (_failure) {
                             _failure([UserObjDao getErrorObjWithMessage:@"用户名或者邮箱地址已经存在"]);
                         }
                     }else{
                         UserObj *user = [UserObjDao convertUserObjFromJsonDic:[responseStr objectFromJSONString]];
                         if (!user) {
                             if (_failure) {
                                 _failure([UserObjDao getErrorObjWithMessage:@"注册失败，请重新注册"]);
                             }
                         }else{
                             if (_success) {
                                 _success(user);
                             }
                         }
                     }
                 }else{
                     if (_failure) {
                         _failure([UserObjDao getErrorObjWithMessage:@"注册失败，请重新注册"]);
                     }
                     
                 }
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 DRLOG(@"registerUserObj:%@",error);
                 if ([UserObjDao judgeErrorTypeWithFailureBlock:_failure withError:error]) {
                     
                 }else
                 if (_failure) {
                      _failure([UserObjDao getErrorObjWithMessage:@"注册失败，请重新注册"]);
                 }
                
             }];
}

+(void)destroyUserObjID:(NSString*)_userID withSuccess:(void(^)(NSString *success))_success withFailure:(void(^)(NSError *errror))_failure{
    AppDelegate *appDelete = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    AFHTTPClient *client = appDelete.afhttpClient;
//    [client postPath:@"/users/destroy_user"
       [client getPath:@"/users/destroy_user"
         parameters:@{@"id":_userID}
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        if (responseStr) {
            if ([responseStr isEqualToString:@"success"]) {
                if (_success) {
                    _success(@"用户注销成功");
                }
            }else
                if([responseStr isEqualToString:@"error"]){
                    if (_failure) {
                        _failure([UserObjDao getErrorObjWithMessage:@"注销帐户失败，请重新注销"]);
                    }
                }else{
                    if (_failure) {
                        _failure([UserObjDao getErrorObjWithMessage:@"注销帐户失败，请重新注销"]);
                    }
                }
        }else{
            if (_failure) {
                _failure([UserObjDao getErrorObjWithMessage:@"注销帐户失败，请重新注销"]);
            }
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DRLOG(@"destroyUserObjID:%@",error);
        if ([UserObjDao judgeErrorTypeWithFailureBlock:_failure withError:error]) {
            
        }else
        if (_failure) {
            _failure([UserObjDao getErrorObjWithMessage:@"注销帐户失败，请重新注销"]);
        }
    }];
    
}
+(void)loginInUserObjName:(NSString*)_userName withUserPwd:(NSString*)_userPwd withToken:(NSString*)_token withSuccess:(void(^)(UserObj *userObj))_success withFailure:(void(^)(NSError *errror))_failure{
    AppDelegate *appDelete = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    AFHTTPClient *client = appDelete.afhttpClient;
//    [client postPath:@"users/user_signin"
    [client getPath:@"users/user_signin"
          parameters:@{@"name":_userName,@"password":[FBEncryptorAES encryptBase64String:_userPwd keyString:ENCRYPT_KEY separateLines:NO],@"token":_token==nil?@"":_token}
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];;
                 if (responseStr) {
                     if ([responseStr isEqualToString:@"error"]) {
                         if (_failure) {
                             _failure([UserObjDao getErrorObjWithMessage:@"用户名或密码错误，请重新登陆"]);
                         }
                     }else{
                         UserObj *user = [UserObjDao convertUserObjFromJsonDic:[responseStr objectFromJSONString]];
                         if (!user) {
                             if (_failure) {
                                 _failure([UserObjDao getErrorObjWithMessage:@"登陆失败，请重新登陆"]);
                             }
                         }else{
                             if (_success) {
                                 _success(user);
                             }
                         }
                     }
                 }else{
                     if (_failure) {
                         _failure([UserObjDao getErrorObjWithMessage:@"登陆失败，请重新登陆"]);
                     }
                 }
                 
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DRLOG(@"loginInUserObjName:%@",error);
        if ([UserObjDao judgeErrorTypeWithFailureBlock:_failure withError:error]) {
           
        }else
        if (_failure) {
            _failure([UserObjDao getErrorObjWithMessage:@"登陆失败，请重新登陆"]);
        }
    }];
}
+(void)identifyEmailUserObjName:(NSString*)_userName withEmail:(NSString*)_userEmail withSuccess:(void(^)(UserObj *userObj))_success withFailure:(void(^)(NSError *errror))_failure{
    AppDelegate *appDelete = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    AFHTTPClient *client = appDelete.afhttpClient;
//    [client postPath:@"users/forget_pwd"
    [client getPath:@"users/forget_pwd"
          parameters:@{@"name":_userName,@"email":_userEmail}
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                 if (responseStr) {
                     if ([responseStr isEqualToString:@"error"]) {
                         if (_failure) {
                             _failure([UserObjDao getErrorObjWithMessage:@"用户名或者邮箱地址不存在"]);
                         }
                     }else{
                         UserObj *user = [UserObjDao convertUserObjFromJsonDic:[responseStr objectFromJSONString]];
                         if (!user) {
                             if (_failure) {
                                 _failure([UserObjDao getErrorObjWithMessage:@"验证失败"]);
                             }
                         }else{
                             if (_success) {
                                 _success(user);
                             }
                         }
                     }
                 }else{
                     if (_failure) {
                         _failure([UserObjDao getErrorObjWithMessage:@"验证失败"]);
                     }
                 }
                 
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 DRLOG(@"identifyEmailUserObjName%@",error);
                 if ([UserObjDao judgeErrorTypeWithFailureBlock:_failure withError:error]) {
                     
                 }else
                 if (_failure) {
                     _failure([UserObjDao getErrorObjWithMessage:@"验证失败"]);
                 }
             }];
    
}
+(void)modifyUserPwdUserObjName:(NSString*)_userName withUserPwd:(NSString*)_userPwd withEmail:(NSString *)_email withSuccess:(void(^)(NSString *success))_success withFailure:(void(^)(NSError *errror))_failure{
    AppDelegate *appDelete = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    AFHTTPClient *client = appDelete.afhttpClient;
//    [client postPath:@"users/change_pwd"
    [client getPath:@"users/change_pwd"
         parameters:@{@"name":_userName,@"email":_email?:@"",@"password":[FBEncryptorAES encryptBase64String:_userPwd keyString:ENCRYPT_KEY separateLines:NO]}
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                 if (responseStr) {
                     if ([responseStr isEqualToString:@"error"]) {
                         if (_failure) {
                             _failure([UserObjDao getErrorObjWithMessage:@"修改密码失败"]);
                         }
                     }else
                     if ([responseStr isEqualToString:@"emailerror"]) {
                         if (_failure) {
                             _failure([UserObjDao getErrorObjWithMessage:@"邮箱地址和用户名不匹配"]);
                         }
                     }else
                    if ([responseStr isEqualToString:@"success"]) {
                        if (_success) {
                            _success(@"修改密码成功");
                        }
                     }else{
                         if (_failure) {
                             _failure([UserObjDao getErrorObjWithMessage:@"修改密码失败"]);
                         }
                     }
                 }else{
                     if (_failure) {
                         _failure([UserObjDao getErrorObjWithMessage:@"修改密码失败"]);
                     }
                 }
                 
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 DRLOG(@"modifyUserPwdUserObjId%@",error);
                 if ([UserObjDao judgeErrorTypeWithFailureBlock:_failure withError:error]) {
                     
                 }else
                 if (_failure) {
                     _failure([UserObjDao getErrorObjWithMessage:@"修改密码失败"]);
                 }
             }];
}
+(void)modifyAlbumPwdUserObjId:(NSString*)_userID withAlbumPwd:(NSString*)_albumPwd withSuccess:(void(^)(NSString *success))_success withFailure:(void(^)(NSError *errror))_failure{
    AppDelegate *appDelete = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    AFHTTPClient *client = appDelete.afhttpClient;
//    [client postPath:@"users/album_pwd"
    [client getPath:@"users/album_pwd"
          parameters:@{@"id":_userID,@"photo_password":[FBEncryptorAES encryptBase64String:_albumPwd keyString:ENCRYPT_KEY separateLines:NO]}
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                 if (responseStr) {
                     if ([responseStr isEqualToString:@"error"]) {
                         if (_failure) {
                             _failure([UserObjDao getErrorObjWithMessage:@"修改相册密码失败"]);
                         }
                     }else
                         if ([responseStr isEqualToString:@"success"]) {
                             if (_success) {
                                 _success(@"修改相册密码成功");
                             }
                         }else{
                             if (_failure) {
                                 _failure([UserObjDao getErrorObjWithMessage:@"修改相册密码失败"]);
                             }
                         }
                 }else{
                     if (_failure) {
                         _failure([UserObjDao getErrorObjWithMessage:@"修改相册密码失败"]);
                     }
                 }
                 
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 DRLOG(@"modifyAlbumPwdUserObjId%@",error);
                 if ([UserObjDao judgeErrorTypeWithFailureBlock:_failure withError:error]) {
                     
                 }else
                 if (_failure) {
                     _failure([UserObjDao getErrorObjWithMessage:@"修改相册密码失败"]);
                 }
             }];
}
+(void)modifyUserDescribleUserObjId:(NSString*)_userID withUserDescrible:(NSString*)_userDescrible withSuccess:(void(^)(NSString *success))_success withFailure:(void(^)(NSError *errror))_failure{
    AppDelegate *appDelete = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    AFHTTPClient *client = appDelete.afhttpClient;
//    [client postPath:@"users/change_describle"
    [client getPath:@"users/change_describle"
          parameters:@{@"id":_userID,@"describle":_userDescrible}
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                 if (responseStr) {
                     if ([responseStr isEqualToString:@"error"]) {
                         if (_failure) {
                             _failure([UserObjDao getErrorObjWithMessage:@"修改用户说明失败"]);
                         }
                     }else
                         if ([responseStr isEqualToString:@"success"]) {
                             if (_success) {
                                 _success(@"修改用户说明成功");
                             }
                         }else{
                             if (_failure) {
                                 _failure([UserObjDao getErrorObjWithMessage:@"修改用户说明失败"]);
                             }
                         }
                 }else{
                     if (_failure) {
                         _failure([UserObjDao getErrorObjWithMessage:@"修改用户说明失败"]);
                     }
                 }
                 
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 DRLOG(@"modifyUserDescribleUserObjId%@",error);
                 if ([UserObjDao judgeErrorTypeWithFailureBlock:_failure withError:error]) {
                     
                 }else
                 if (_failure) {
                     _failure([UserObjDao getErrorObjWithMessage:@"修改用户说明失败"]);
                 }
             }];
}
+(void)modifyUserEmailUserObjId:(NSString*)_userID withUserEmail:(NSString*)_userEmail withSuccess:(void(^)(NSString *success))_success withFailure:(void(^)(NSError *errror))_failure{
    AppDelegate *appDelete = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    AFHTTPClient *client = appDelete.afhttpClient;
//    [client postPath:@"users/change_email"
    [client getPath:@"users/change_email"
          parameters:@{@"id":_userID,@"email":_userEmail}
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                 if (responseStr) {
                     if ([responseStr isEqualToString:@"emailerror"]) {
                         if (_failure) {
                             _failure([UserObjDao getErrorObjWithMessage:@"邮箱地址已被使用"]);
                         }
                     }else
                     if ([responseStr isEqualToString:@"error"]) {
                         if (_failure) {
                             _failure([UserObjDao getErrorObjWithMessage:@"修改用户邮箱失败"]);
                         }
                     }else
                         if ([responseStr isEqualToString:@"success"]) {
                             if (_success) {
                                 _success(@"修改用户邮箱成功");
                             }
                         }else{
                             if (_failure) {
                                 _failure([UserObjDao getErrorObjWithMessage:@"修改用户邮箱失败"]);
                             }
                         }
                 }else{
                     if (_failure) {
                         _failure([UserObjDao getErrorObjWithMessage:@"修改用户邮箱失败"]);
                     }
                 }
                 
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 DRLOG(@"modifyUserEmailUserObjId%@",error);
                 if ([UserObjDao judgeErrorTypeWithFailureBlock:_failure withError:error]) {
                     
                 }else
                 if (_failure) {
                     _failure([UserObjDao getErrorObjWithMessage:@"修改用户邮箱失败"]);
                 }
             }];
}
+(void)modifyUserLocationUserObjId:(NSString*)_userID withUserLocation:(NSString*)_userLocation withSuccess:(void(^)(NSString *success))_success withFailure:(void(^)(NSError *errror))_failure{
    AppDelegate *appDelete = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    AFHTTPClient *client = appDelete.afhttpClient;
//    [client postPath:@"users/change_city"
    [client getPath:@"users/change_city"
          parameters:@{@"id":_userID,@"name":_userLocation}
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                 if (responseStr) {
                     if ([responseStr isEqualToString:@"error"]) {
                         if (_failure) {
                             _failure([UserObjDao getErrorObjWithMessage:@"修改用户所在城市失败"]);
                         }
                     }else
                         if ([responseStr isEqualToString:@"success"]) {
                             if (_success) {
                                 _success(@"修改用户所在城市成功");
                             }
                         }else{
                             if (_failure) {
                                 _failure([UserObjDao getErrorObjWithMessage:@"修改用户所在城市失败"]);
                             }
                         }
                 }else{
                     if (_failure) {
                         _failure([UserObjDao getErrorObjWithMessage:@"修改用户所在城市失败"]);
                     }
                 }
                 
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 DRLOG(@"modifyUserLocationUserObjId%@",error);
                 if ([UserObjDao judgeErrorTypeWithFailureBlock:_failure withError:error]) {
                     
                 }else
                 if (_failure) {
                     _failure([UserObjDao getErrorObjWithMessage:@"修改用户所在城市失败"]);
                 }
             }];
}


+(void)setAPNSTokenUserObjId:(NSString*)_userID withToken:(NSString*)_token withSuccess:(void(^)(NSString *success))_success withFailure:(void(^)(NSError *errror))_failure{
    AppDelegate *appDelete = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    AFHTTPClient *client = appDelete.afhttpClient;
//    http://192.168.3.106:3000/photos/edittoken?id=3&token=。。。。。
    //    [client postPath:@"users/album_pwd"
    [client getPath:@"photos/edittoken"
         parameters:@{@"id":_userID,@"token":_token?:@""}
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                if (responseStr) {
                    if ([responseStr isEqualToString:@"error"]) {
                        if (_failure) {
                            _failure([UserObjDao getErrorObjWithMessage:@"设置Token失败"]);
                        }
                    }else
                        if ([responseStr isEqualToString:@"success"]) {
                            if (_success) {
                                _success(@"设置Token失败成功");
                            }
                        }else{
                            if (_failure) {
                                _failure([UserObjDao getErrorObjWithMessage:@"设置Token失败"]);
                            }
                        }
                }else{
                    if (_failure) {
                        _failure([UserObjDao getErrorObjWithMessage:@"设置Token失败"]);
                    }
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                DRLOG(@"setAPNSTokenUserObjId%@",error);
                if ([UserObjDao judgeErrorTypeWithFailureBlock:_failure withError:error]) {
                    
                }else
                    if (_failure) {
                        _failure([UserObjDao getErrorObjWithMessage:@"设置Token失败失败"]);
                    }
            }];
}
@end
