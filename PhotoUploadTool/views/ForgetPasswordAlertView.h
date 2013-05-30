//
//  ForgetPasswordAlertView.h
//  PhotoUploadTool
//
//  Created by david on 13-5-22.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgetPasswordAlertView : UIView
+(ForgetPasswordAlertView*)defaultAlertViewWithEmal:(NSString*)email withSuccess:(void(^)())success orFailure:(void(^)(NSError*error))failure orCancel:(void(^)())cancel;
@end
