//
//  SettingPrivatePwdView.h
//  PhotoUploadTool
//
//  Created by david on 13-5-28.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {PRIVATEPWDVIEW_SETTING = 100,PRIVATEPWDVIEW_MODIFY}SettingPrivatePwdViewType;
@interface SettingPrivatePwdView : UIView
+(SettingPrivatePwdView*)defaultSettingPrivatePwdViewType:(SettingPrivatePwdViewType)type withSuccess:(void(^)(NSString *password))success orFailure:(void(^)(NSError*error))failure orCancel:(void(^)())cancel;
@end
