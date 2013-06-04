//
//  UserObj.h
//  PhotoUploadTool
//
//  Created by david on 13-5-31.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserObj : NSObject
@property(nonatomic,strong) NSString *userId;
@property(nonatomic,strong) NSString *userName;
@property(nonatomic,strong) NSString *userPwd;
@property(nonatomic,strong) NSString *userEmail;
@property(nonatomic,strong) NSString *userAlbumPwd;
@property(nonatomic,strong) NSString *userDescrible;
@property(nonatomic,strong) NSString *userLocation;
@property(nonatomic,strong) NSString *userWebURL;
@end
