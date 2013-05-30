//
//  DRImageData.h
//  PhotoUploadTool
//
//  Created by david on 13-5-17.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DRImageData : NSObject
@property(nonatomic,assign) float imageWidth;
@property(nonatomic,assign) float imageHeight;
@property(nonatomic,strong) NSString *imageURLStr;
+(DRImageData*)imageDataWithImageWidth:(float)width withHeight:(float)height withURLStr:(NSString*)urlStr;
@end
