//
//  ModifyEmailView.m
//  PhotoUploadTool
//
//  Created by david on 13-5-29.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import "ModifyEmailView.h"
#define INPUTVIEW_INTERVAL 0.5
#define BORDERVIEW_HEIGHT 300
@interface ModifyEmailView()
@property(nonatomic,strong) void(^successBlock)(NSString *password);
@property(nonatomic,strong) void(^failureBlock)(NSError *error);
@property(nonatomic,strong) void(^cancelBlock)();
@property(nonatomic,strong) NSString *emailString;
@end
@implementation ModifyEmailView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+(ModifyEmailView*)defaultModifyEmailViewWithEmail:(NSString*)emailstr WithSuccess:(void(^)(NSString *password))success orFailure:(void(^)(NSError*error))failure orCancel:(void(^)())cancel{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Storyboard_iphone" bundle:nil];
    ModifyEmailView *modifyEmailView = (ModifyEmailView*)([[story instantiateViewControllerWithIdentifier:@"ModifyEmailView"] view]);
    modifyEmailView.successBlock = success;
    modifyEmailView.failureBlock = failure;
    modifyEmailView.cancelBlock = cancel;
    modifyEmailView.emailString = emailstr;
    modifyEmailView.textField.text = emailstr;
    [modifyEmailView show];
    return modifyEmailView;
}

- (IBAction)okBtClicked:(id)sender {
    if ([self checkInputStr]) {
         NSString *email = [self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([email isEqualToString:self.emailString]) {
            if (self.cancelBlock) {
                self.cancelBlock();
            }
        }else{
            if (self.successBlock) {
                self.successBlock(self.textField.text);
            }
        }
        [self dismiss];
    }
}

- (IBAction)cancelBtClicked:(id)sender {
    if (self.cancelBlock) {
        self.cancelBlock();
    }
    [self dismiss];
}

-(BOOL)checkInputStr{
    NSString *email = [self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([email isEqualToString:@""]) {
        self.tipLabel.text = @"提示 : 邮箱地址不为空";
        //        [self performSelector:@selector(modifyTitleLabelText) withObject:nil afterDelay:3.0];
        return NO;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES '\\\\w+([-+.]\\\\w+)*@\\\\w+([-.]\\\\w+)*\\\\.\\\\w+([-.]\\\\w+)*'"];
    if (![predicate evaluateWithObject:email]){
         self.tipLabel.text = @"提示 : 无效邮箱地址";
        return NO;
    }
    return YES;
}

- (void)show{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    self.frame = window.bounds;
    self.backgroundColor = [UIColor colorWithRed:0.6 green:0.2 blue:0.4 alpha:0.6];
    [window addSubview:self];
    self.borderView.center = CGPointMake(self.borderView.center.x, - BORDERVIEW_HEIGHT/2);
    [UIView animateWithDuration:INPUTVIEW_INTERVAL delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^(){
        self.borderView.center = CGPointMake(self.borderView.center.x, BORDERVIEW_HEIGHT/2);
    } completion:^(BOOL isFinished){
        if (isFinished) {
            [self.textField becomeFirstResponder];
        }
    }];
    
}
- (void)dismiss{
    //    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [UIView animateWithDuration:INPUTVIEW_INTERVAL delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^(){
        self.borderView.center = CGPointMake(self.borderView.center.x, -BORDERVIEW_HEIGHT/2);
    } completion:^(BOOL isFinished){
        if (isFinished) {
            [self.textField resignFirstResponder];
            [self removeFromSuperview];
            [self viewExit];
        }
    }];
}

-(void)viewExit{
    self.successBlock = nil;
    self.failureBlock = nil;
    self.cancelBlock = nil;
}
@end
