//
//  DRNetWorkingException.h
//  PhotoUploadTool
//
//  Created by david on 13-6-6.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "AppDelegate.h"
#import "JSONKit.h"
@interface DRNetWorkingException : NSObject
+(BOOL)judgeErrorTypeWithFailureBlock:(void(^)(NSError *errror))_failure withError:(NSError*)error;
+(NSError*)getErrorObjWithMessage:(NSString*)msg;
@end
