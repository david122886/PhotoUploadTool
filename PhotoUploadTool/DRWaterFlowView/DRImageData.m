//
//  DRImageData.m
//  PhotoUploadTool
//
//  Created by david on 13-5-17.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import "DRImageData.h"

@implementation DRImageData
+(DRImageData*)imageDataWithImageWidth:(float)width withHeight:(float)height withURLStr:(NSString*)urlStr{
    DRImageData *data = [[DRImageData alloc] init];
    data.imageWidth = width;
    data.imageHeight = height;
    data.imageURLStr = urlStr;
    return data;
}
@end
