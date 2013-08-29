//
//  DRNetWorkingException.m
//  PhotoUploadTool
//
//  Created by david on 13-6-6.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import "DRNetWorkingException.h"

@implementation DRNetWorkingException
+(NSError*)getErrorObjWithMessage:(NSString*)msg{
    return  [[NSError alloc] initWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey:msg}];
}

+(BOOL)judgeErrorTypeWithFailureBlock:(void(^)(NSError *errror))_failure withError:(NSError*)error{
    if ([[error.userInfo objectForKey:@"NSLocalizedDescription"] isEqualToString:@"Could not connect to the server."]) {
        _failure([DRNetWorkingException getErrorObjWithMessage:@"无法连接服务器"]);
        return YES;
    }
    if ([[error.userInfo objectForKey:@"NSLocalizedDescription"] isEqualToString:@"Expected status code in (200-299)"]) {
        _failure([DRNetWorkingException getErrorObjWithMessage:@"无法连接服务器"]);
        return YES;
    }
    if ([[error.userInfo objectForKey:@"NSLocalizedDescription"] isEqualToString:@"The network connection was lost."]) {
        _failure([DRNetWorkingException getErrorObjWithMessage:@"无法连接服务器"]);
        return YES;
    }
    
    if ([[error.userInfo objectForKey:@"NSLocalizedDescription"] isEqualToString:@"未能连接到服务器。"]) {
        _failure([DRNetWorkingException getErrorObjWithMessage:@"未能连接到服务器"]);
        return YES;
    }
    
    if ([[error.userInfo objectForKey:@"NSLocalizedDescription"] isEqualToString:@"似乎已断开与互联网的连接。"]) {
        _failure([DRNetWorkingException getErrorObjWithMessage:@"无法连接网络"]);
        return YES;
    }
    return NO;
}
@end
