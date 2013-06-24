
//
//  UIImage+AFNetWorking.m
//  PhotoUploadTool
//
//  Created by david on 13-6-19.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import "UIImage+AFNetWorking.h"
#import <objc/runtime.h>
@interface UIImage(private)
@property (readwrite, nonatomic, strong, setter = upload_setImageRequestOperation:) AFHTTPRequestOperation *upload_imageRequestOperation;
@end

@implementation UIImage(private)
@dynamic upload_imageRequestOperation;
@end


static char kAFImageRequestOperationUploadObjectKey;
@implementation UIImage(AFNetWorking)



- (AFHTTPRequestOperation *)upload_imageRequestOperation {
    return (AFHTTPRequestOperation *)objc_getAssociatedObject(self, &kAFImageRequestOperationUploadObjectKey);
}

- (void)upload_setImageRequestOperation:(AFHTTPRequestOperation *)imageRequestOperation {
    objc_setAssociatedObject(self, &kAFImageRequestOperationUploadObjectKey, imageRequestOperation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


-(void)uploadImageWithURL:(NSURL*)url withParameters:(NSDictionary*)parameters success:(void (^)(NSString *success))success error:(void (^)(NSError *error))failure{
    [self uploadImageWithURL:url withParameters:parameters success:success error:failure progressBlock:nil];
}

/*do not copy self
-(void)uploadImageWithURL:(NSURL*)url
           withParameters:(NSDictionary*)parameters
                  success:(void (^)(NSString *success))success
                    error:(void (^)(NSError *error))failure
            progressBlock:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progress{

    [self cancelUploadRequestOperation];
    if (!url) {
        if (failure) {
            failure([NSError errorWithDomain:@"" code:1 userInfo:@{NSLocalizedDescriptionKey:@"图片ip地址错误"}]);
        }
        return;
    }
    AFHTTPClient *httpClient =[AFHTTPClient clientWithBaseURL:url];
    NSData *imageData = UIImageJPEGRepresentation(self, 0.5);
    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:@"photos/upload" parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        [formData appendPartWithFileData:imageData name:@"img" fileName:@"MainMedia.jpeg" mimeType:@"image/jpeg"];
    }];
    UIImage __weak *weakSelf = self;
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        NSLog(@"%d,%lld,%lld",bytesRead,totalBytesRead,totalBytesExpectedToRead);
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(operation.responseString);
        } else if (responseObject) {
            success(responseObject);
        }
        if (weakSelf) {
            if ([request isEqual:[weakSelf.upload_imageRequestOperation request]]) {
                NSLog(@"upload success");
                if (weakSelf.upload_imageRequestOperation == operation) {
                    weakSelf.upload_imageRequestOperation = nil;
                }
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
        if (weakSelf) {
            
            if ([request isEqual:[weakSelf.upload_imageRequestOperation request]]) {
                
                NSLog(@"upload error:%@",error);
                if (weakSelf.upload_imageRequestOperation == operation) {
                    weakSelf.upload_imageRequestOperation = nil;
                }
            }
            
        }
    }];
    self.upload_imageRequestOperation = operation;
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        if (progress) {
            progress(bytesRead,totalBytesRead,totalBytesExpectedToRead);
        }
    }];
    [[[self class] af_sharedImageRequestOperationQueue] addOperation:self.upload_imageRequestOperation];
    [self.upload_imageRequestOperation start];
}
*/

//must copy self
-(void)uploadImageWithURL:(NSURL*)url
           withParameters:(NSDictionary*)parameters
                  success:(void (^)(NSString *success))success
                    error:(void (^)(NSError *error))failure
            progressBlock:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progress{
    
    [self cancelUploadRequestOperation];
    if (!url) {
        if (failure) {
            failure([NSError errorWithDomain:@"" code:1 userInfo:@{NSLocalizedDescriptionKey:@"图片ip地址错误"}]);
        }
        return;
    }
    
    AFHTTPClient *httpClient =[AFHTTPClient clientWithBaseURL:url];
    NSData *imageData = UIImageJPEGRepresentation(self, 0.5);
    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:@"photos/upload" parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        [formData appendPartWithFileData:imageData name:@"img" fileName:@"MainMedia.jpeg" mimeType:@"image/jpeg"];
    }];
    DRLOG(@"uploadImageWithURL:%@", request);
    DRLOG(@"uploadImageWithURL:%@", parameters);
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        NSLog(@"%d,%lld,%lld",bytesRead,totalBytesRead,totalBytesExpectedToRead);
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        DRLOG(@"setCompletionBlockWithSuccess:%@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        if (success) {
            success(operation.responseString);
        } else if (responseObject) {
            success(responseObject);
        }
        if (self) {
            if ([request isEqual:[self.upload_imageRequestOperation request]]) {
                NSLog(@"upload success");
                if (self.upload_imageRequestOperation == operation) {
                    self.upload_imageRequestOperation = nil;
                }
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
        if (self) {
            
            if ([request isEqual:[self.upload_imageRequestOperation request]]) {
                
                NSLog(@"upload error:%@",error);
                if (self.upload_imageRequestOperation == operation) {
                    self.upload_imageRequestOperation = nil;
                }
            }
            
        }
    }];
    self.upload_imageRequestOperation = operation;
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        if (progress) {
            progress(bytesRead,totalBytesRead,totalBytesExpectedToRead);
        }
    }];
    [[[self class] af_sharedImageRequestOperationQueue] addOperation:self.upload_imageRequestOperation];
    [self.upload_imageRequestOperation start];
}

+ (NSOperationQueue *)af_sharedImageRequestOperationQueue {
    static NSOperationQueue *_af_imageRequestOperationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _af_imageRequestOperationQueue = [[NSOperationQueue alloc] init];
        [_af_imageRequestOperationQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
    });
    
    return _af_imageRequestOperationQueue;
}

- (void)cancelUploadRequestOperation{
    [self.upload_imageRequestOperation cancel];
    self.upload_imageRequestOperation = nil;
}
@end
