//
//  NSString+ Encrypt.h
//  PhotoUploadTool
//
//  Created by david on 13-6-4.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
@interface NSString (Encrypt)
- (NSString *)MD5Hash;
@end
