//
//  ModifyEmailView.h
//  PhotoUploadTool
//
//  Created by david on 13-5-29.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ModifyEmailView : UIView
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIView *borderView;
- (IBAction)okBtClicked:(id)sender;
- (IBAction)cancelBtClicked:(id)sender;
+(ModifyEmailView*)defaultModifyEmailViewWithEmail:(NSString*)emailstr WithSuccess:(void(^)(NSString *password))success orFailure:(void(^)(NSError*error))failure orCancel:(void(^)())cancel;
@end
