//
//  NotificationDao.m
//  PhotoUploadTool
//
//  Created by david on 13-6-3.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import "NotificationDao.h"

@implementation NotificationDao

+(NSArray*)convertNotificationObjFromJsonArr:(NSArray*)jsonStr{
    if (!jsonStr || [jsonStr count] <= 0) {
        return nil;
    }
    DRLOG(@"%@",jsonStr);
    NSMutableArray *notificationArr = [NSMutableArray arrayWithCapacity:[jsonStr count]];
    for (NSDictionary *notiObj in jsonStr) {
        NSString *notiID = [NSString stringWithFormat:@"%@",[notiObj objectForKey:@"id"]];
        if (!notiID || [notiID isEqualToString:@"<null>"]) {
            continue;
        }
        NotificationObject *obj = [[NotificationObject alloc] init];
        obj.notificationID = notiID;
        
        NSString *content = [NSString stringWithFormat:@"%@",[notiObj objectForKey:@"content"]];
        if (content || ![content isEqualToString:@"<null>"]) {
            obj.deail = content;
        }
        
        NSString *createDate = [NSString stringWithFormat:@"%@",[notiObj objectForKey:@"created_at"]];
        if (createDate || ![createDate isEqualToString:@"<null>"]) {
            obj.date = createDate;
        }
        [notificationArr addObject:obj];
    }
    
    return notificationArr;
    
}
+(void)notificationDaoDownloadWithUserObjID:(NSString*)_userID WithSuccess:(void(^)(NSArray* notificationArr))_success withFailure:(void(^)(NSError *error))_failure{
    AppDelegate *appDelete = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    AFHTTPClient *client = appDelete.afhttpClient;
//    http://192.168.1.12:3000/messages/read_messages?id=9
    //    [client postPath:@"users/change_city"
    [client getPath:@"messages/read_messages"
         parameters:@{@"id":_userID}
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                if (responseStr) {
                    if (responseStr.length < 6 && [responseStr isEqualToString:@"false"]) {
                        if (_failure) {
                            _failure([NotificationDao getErrorObjWithMessage:@"获取消息列表失败"]);
                        }
                    }else{
                        NSArray *objArr = [NotificationDao convertNotificationObjFromJsonArr:[responseStr objectFromJSONString]];
                        if (objArr) {
                            if (_success) {
                                _success(objArr);
                            }
                        }else{
                            if (_failure) {
                                _failure([NotificationDao getErrorObjWithMessage:@"获取消息列表失败"]);
                            }
                        }
                    }
                }else{
                    if (_failure) {
                        _failure([NotificationDao getErrorObjWithMessage:@"获取消息列表失败"]);
                    }
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                DRLOG(@"notificationDaoDownloadWithUserObjID%@",error);
                if ([NotificationDao judgeErrorTypeWithFailureBlock:_failure withError:error]) {
                    
                }else
                    if (_failure) {
                        _failure([NotificationDao getErrorObjWithMessage:@"获取消息列表失败"]);
                    }
            }];
}

+(void)deleteNotificationWithNotificationID:(NSString*)_userID withNotID:(NSString*)_notificationID withSuccess:(void(^)(NSString* success))_success withFailure:(void(^)(NSError *error))_failure{
//    http://192.168.1.12:3000/messages/delete?id=4
    AppDelegate *appDelete = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    AFHTTPClient *client = appDelete.afhttpClient;
    //    [client postPath:@"users/change_city"
    [client getPath:@"messages/delete"
         parameters:@{@"id":_userID}
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                if (responseStr) {
                    if (responseStr.length < 6 && [responseStr isEqualToString:@"error"]) {
                        if (_failure) {
                            _failure([NotificationDao getErrorObjWithMessage:@"删除消息失败"]);
                        }
                    }else
                        if (responseStr.length < 8 && [responseStr isEqualToString:@"success"]) {
                            if (_success) {
                                _success(@"删除消息成功");
                            }
                        }else{
                            if (_failure) {
                                _failure([NotificationDao getErrorObjWithMessage:@"删除消息失败"]);
                            }
                        }
                }else{
                    if (_failure) {
                        _failure([NotificationDao getErrorObjWithMessage:@"删除消息失败"]);
                    }
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                DRLOG(@"deleteNotificationWithUserObjID%@",error);
                if ([NotificationDao judgeErrorTypeWithFailureBlock:_failure withError:error]) {
                    
                }else
                    if (_failure) {
                        _failure([NotificationDao getErrorObjWithMessage:@"删除消息失败"]);
                    }
            }];
}
@end
