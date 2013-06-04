//
//  DRGridViewData.h
//  PhotoUploadTool
//
//  Created by david on 13-5-26.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum {DRGRIDVIEWDATA_LOCATION,DRGRIDVIEWDATA_NETWORK}DRGridViewDataSourceType;
@interface DRGridViewData : NSObject
@property(nonatomic,strong) NSString *imageURLStr;
@property(nonatomic,strong) NSString *bigImageURLStr;
@property(nonatomic,assign) int imageID;
@property(nonatomic,assign) DRGridViewDataSourceType imageSourceType;
@end