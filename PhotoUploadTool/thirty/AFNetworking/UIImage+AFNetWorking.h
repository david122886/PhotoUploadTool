//
//  UIImage+AFNetWorking.h
//  PhotoUploadTool
//
//  Created by david on 13-6-19.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"
@interface UIImage(AFNetWorking)
-(void)uploadImageWithURL:(NSURL*)url
           withParameters:(NSDictionary*)parameters
                  success:(void (^)(NSString *success))success
                    error:(void (^)(NSError *error))failure;

-(void)uploadImageWithURL:(NSURL*)url
           withParameters:(NSDictionary*)parameters
                  success:(void (^)(NSString *success))success
                    error:(void (^)(NSError *error))failure
            progressBlock:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progress;

- (void)cancelUploadRequestOperation;
@end
