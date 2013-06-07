//
//  DRImageObj.h
//  PhotoUploadTool
//
//  Created by david on 13-6-6.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DRImageObj : NSObject
@property(nonatomic,strong) NSString *smallImageURLStr;
@property(nonatomic,strong) NSString *bigImageURLStr;
@property(nonatomic,strong) NSString *describle;
@property(nonatomic,assign) NSString *imageDataID;
@end
