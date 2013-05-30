//
//  ForgetPasswordAlertView.m
//  PhotoUploadTool
//
//  Created by david on 13-5-22.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import "ForgetPasswordAlertView.h"
#define INPUTVIEW_INTERVAL 0.5
#define BORDERVIEW_HEIGHT 300
@interface ForgetPasswordAlertView()
@property(nonatomic,assign) void(^successBlock)();
@property(nonatomic,assign) void(^failureBlock)(NSError *error);
@property(nonatomic,assign) void(^cancelBlock)();
@property(nonatomic,strong) NSString *emailStr;
@property (weak, nonatomic) IBOutlet UIView *borderView;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *rePasswordField;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
- (IBAction)cancelBtClicked:(id)sender;
- (IBAction)okBtClicked:(id)sender;

@end
@implementation ForgetPasswordAlertView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}
+(ForgetPasswordAlertView*)defaultAlertViewWithEmal:(NSString*)email withSuccess:(void(^)())success orFailure:(void(^)(NSError*error))failure orCancel:(void(^)())cancel{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Storyboard_iphone" bundle:nil];
    ForgetPasswordAlertView *alertView = (ForgetPasswordAlertView*)[[story instantiateViewControllerWithIdentifier:@"ForgetPasswordAlertView"] view];
    alertView.emailStr = email;
    alertView.successBlock = success;
    alertView.failureBlock = failure;
    alertView.cancelBlock = cancel;
    [alertView show];
    return alertView;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
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
            [self.passwordField becomeFirstResponder];
        }
    }];
    
}
- (void)dismiss{
//    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [UIView animateWithDuration:INPUTVIEW_INTERVAL delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^(){
        self.borderView.center = CGPointMake(self.borderView.center.x, -BORDERVIEW_HEIGHT/2);
    } completion:^(BOOL isFinished){
        if (isFinished) {
            [self.passwordField resignFirstResponder];
            [self.rePasswordField resignFirstResponder];
            [self removeFromSuperview];
        }
    }];
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.passwordField resignFirstResponder];
    [self.rePasswordField resignFirstResponder];
    CGPoint point = [(UITouch*)[touches anyObject] locationInView:self];
    if (!CGRectContainsPoint(self.borderView.frame, point)) {
        [self dismiss];
    }
}
- (IBAction)cancelBtClicked:(id)sender {
    [self dismiss];
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}

- (IBAction)okBtClicked:(id)sender {
    if ([self checkInputStr]) {
        
    }
}

-(void)setEmailStr:(NSString *)emailStr{
    if (emailStr) {
        _emailLabel.text = [NSString stringWithFormat:@"邮箱地址：%@",emailStr];
    }
}

-(BOOL)checkInputStr{
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *rePassword = [self.rePasswordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([password isEqualToString:@""]) {
        self.tipLabel.text = @"密码不为空";
        return NO;
    }
    if ([rePassword isEqualToString:@""]) {
        self.tipLabel.text = @"确认密码不为空";
        return NO;
    }
    if (![password isEqualToString:rePassword]) {
        self.tipLabel.text = @"两次输入密码不相同";
        return NO;
    }
    return YES;
}

@end
