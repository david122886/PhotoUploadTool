// UIImageView+AFNetworking.m
//
// Copyright (c) 2011 Gowalla (http://gowalla.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "AFHTTPClient.h"
#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
#import "UIImageView+AFNetworking.h"

@interface AFImageCache : NSCache
- (UIImage *)cachedImageForRequest:(NSURLRequest *)request;
- (void)cacheImage:(UIImage *)image
        forRequest:(NSURLRequest *)request;
@end

#pragma mark -

static char kAFImageRequestOperationObjectKey;
static char kAFImageRequestOperationUploadObjectKey;
@interface UIImageView (_AFNetworking)
@property (readwrite, nonatomic, strong, setter = af_setImageRequestOperation:) AFImageRequestOperation *af_imageRequestOperation;
@property (readwrite, nonatomic, strong, setter = upload_setImageRequestOperation:) AFHTTPRequestOperation *upload_imageRequestOperation;
@end

@implementation UIImageView (_AFNetworking)
@dynamic af_imageRequestOperation;
@dynamic upload_imageRequestOperation;
@end

#pragma mark -

@implementation UIImageView (AFNetworking)

- (AFHTTPRequestOperation *)af_imageRequestOperation {
    return (AFHTTPRequestOperation *)objc_getAssociatedObject(self, &kAFImageRequestOperationObjectKey);
}

- (void)af_setImageRequestOperation:(AFImageRequestOperation *)imageRequestOperation {
    objc_setAssociatedObject(self, &kAFImageRequestOperationObjectKey, imageRequestOperation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (AFHTTPRequestOperation *)upload_imageRequestOperation {
    return (AFHTTPRequestOperation *)objc_getAssociatedObject(self, &kAFImageRequestOperationUploadObjectKey);
}

- (void)upload_setImageRequestOperation:(AFHTTPRequestOperation *)imageRequestOperation {
    objc_setAssociatedObject(self, &kAFImageRequestOperationUploadObjectKey, imageRequestOperation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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

+ (AFImageCache *)af_sharedImageCache {
    static AFImageCache *_af_imageCache = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _af_imageCache = [[AFImageCache alloc] init];
    });

    return _af_imageCache;
}

#pragma mark -

- (void)setImageWithURL:(NSURL *)url {
    [self setImageWithURL:url placeholderImage:nil];
}

- (void)setImageWithURL:(NSURL *)url
       placeholderImage:(UIImage *)placeholderImage
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];

    [self setImageWithURLRequest:request placeholderImage:placeholderImage success:nil failure:nil];
}

- (void)setImageWithURLRequest:(NSURLRequest *)urlRequest
              placeholderImage:(UIImage *)placeholderImage
                       success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
                       failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
{
    DRLOG(@"UIImageView AFnetworking setImageWithURL%@",[urlRequest description]);
    [self cancelImageRequestOperation];

    UIImage *cachedImage = [[[self class] af_sharedImageCache] cachedImageForRequest:urlRequest];
    if (cachedImage) {
        if (success) {
            success(nil, nil, cachedImage);
        } else {
            self.image = cachedImage;
        }

        self.af_imageRequestOperation = nil;
    } else {
        self.image = placeholderImage;
        UIImageView __weak *weakSelf = self;
        AFImageRequestOperation *requestOperation = [[AFImageRequestOperation alloc] initWithRequest:urlRequest];
        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (weakSelf) {
                if ([urlRequest isEqual:[weakSelf.af_imageRequestOperation request]]) {
                    if (success) {
                        success(operation.request, operation.response, responseObject);
                    } else if (responseObject) {
                        weakSelf.image = responseObject;
                    }
                    
                    if (weakSelf.af_imageRequestOperation == operation) {
                        weakSelf.af_imageRequestOperation = nil;
                    }
                }
                
                [[[weakSelf class] af_sharedImageCache] cacheImage:responseObject forRequest:urlRequest];

            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (weakSelf) {
                if ([urlRequest isEqual:[weakSelf.af_imageRequestOperation request]]) {
                    if (failure) {
                        failure(operation.request, operation.response, error);
                    }
                    
                    if (weakSelf.af_imageRequestOperation == operation) {
                        weakSelf.af_imageRequestOperation = nil;
                    }
                }

            }
        }];

        self.af_imageRequestOperation = requestOperation;

        [[[self class] af_sharedImageRequestOperationQueue] addOperation:self.af_imageRequestOperation];
    }
}

- (void)cancelImageRequestOperation {
    [self.af_imageRequestOperation cancel];
    self.af_imageRequestOperation = nil;
}

- (void)cancelUploadRequestOperation{
    [self.upload_imageRequestOperation cancel];
    self.upload_imageRequestOperation = nil;
}
-(void)uploadImageWithURL:(NSURL*)url withParameters:(NSDictionary*)parameters success:(void (^)(NSString *success))success error:(void (^)(NSError *error))failure{
    [self uploadImageWithURL:url withParameters:parameters success:success error:failure progressBlock:nil];
}

-(void)uploadImageWithURL:(NSURL*)url
           withParameters:(NSDictionary*)parameters
                  success:(void (^)(NSString *success))success
                    error:(void (^)(NSError *error))failure
            progressBlock:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progress{
    if (self.image == nil) {
        return;
    }
    [self cancelUploadRequestOperation];
    if (!url) {
        if (failure) {
            failure(nil);
        }
        return;
    }
    AFHTTPClient *httpClient =[AFHTTPClient clientWithBaseURL:url];
    NSData *imageData = UIImageJPEGRepresentation(self.image, 0.5);
    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:@"photos/upload" parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        [formData appendPartWithFileData:imageData name:@"img" fileName:@"MainMedia.jpeg" mimeType:@"image/jpeg"];
    }];
    UIImageView __weak *weakSelf = self;
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        NSLog(@"%d,%lld,%lld",bytesRead,totalBytesRead,totalBytesExpectedToRead);
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (weakSelf) {
            if ([request isEqual:[weakSelf.upload_imageRequestOperation request]]) {
                if (success) {
                    success(operation.responseString);
                } else if (responseObject) {
                    success(responseObject);
                }
                NSLog(@"upload success");
                if (weakSelf.upload_imageRequestOperation == operation) {
                    weakSelf.upload_imageRequestOperation = nil;
                }
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (weakSelf) {
            if ([request isEqual:[weakSelf.upload_imageRequestOperation request]]) {
                if (failure) {
                    failure(error);
                }
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
@end

#pragma mark -

static inline NSString * AFImageCacheKeyFromURLRequest(NSURLRequest *request) {
    return [[request URL] absoluteString];
}

@implementation AFImageCache

- (UIImage *)cachedImageForRequest:(NSURLRequest *)request {
    switch ([request cachePolicy]) {
        case NSURLRequestReloadIgnoringCacheData:
        case NSURLRequestReloadIgnoringLocalAndRemoteCacheData:
            return nil;
        default:
            break;
    }

	return [self objectForKey:AFImageCacheKeyFromURLRequest(request)];
}

- (void)cacheImage:(UIImage *)image
        forRequest:(NSURLRequest *)request
{
    if (image && request) {
        [self setObject:image forKey:AFImageCacheKeyFromURLRequest(request)];
    }
}

@end

#endif
