//
//  SettingPrivatePwdView.m
//  PhotoUploadTool
//
//  Created by david on 13-5-28.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import "SettingPrivatePwdView.h"
#define INPUTVIEW_INTERVAL 0.5
#define BORDERVIEW_HEIGHT 300
@interface SettingPrivatePwdView()
@property (weak, nonatomic) IBOutlet UIView *borderView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property(nonatomic,strong) void(^successBlock)(NSString *password);
@property(nonatomic,strong) void(^failureBlock)(NSError *error);
@property(nonatomic,strong) void(^cancelBlock)();
@property(nonatomic,strong) NSString *pwdStr;
- (IBAction)okBt:(UIButton *)sender;
- (IBAction)deleteBt:(id)sender;

@end
@implementation SettingPrivatePwdView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

+(SettingPrivatePwdView*)defaultSettingPrivatePwdViewType:(SettingPrivatePwdViewType)type
                                             withAlbumPwd:(NSString*)albumPwd
                                              withSuccess:( void(^)(NSString *password))success
                                                orFailure:(void(^)(NSError*error))failure
                                                 orCancel:(void(^)())cancel{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Storyboard_iphone" bundle:nil];
    SettingPrivatePwdView *settingView = (SettingPrivatePwdView*)([[story instantiateViewControllerWithIdentifier:@"SettingPrivatePwdView"] view]);
    settingView.successBlock = success;
    settingView.failureBlock = failure;
    settingView.cancelBlock = cancel;
    settingView.pwdStr = albumPwd;
    [settingView setTipValue:type];
    [settingView show];
    return settingView;
}

-(void)setTipValue:(SettingPrivatePwdViewType)type{
    [self modifyTitleLabelText];
    if (type == PRIVATEPWDVIEW_SETTING) {
        self.tipLabel.text = @"设置相册密码:";
    }else{
        self.tipLabel.text = @"修改相册密码:";
    }
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
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.textField resignFirstResponder];
    CGPoint point = [(UITouch*)[touches anyObject] locationInView:self];
    if (!CGRectContainsPoint(self.borderView.frame, point)) {
        [self dismiss];
    }
}


- (IBAction)okBt:(UIButton *)sender {
    if ([self checkInputStr]) {
        if (self.successBlock) {
             NSString *password = [self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            self.successBlock(password);
        }
        [self dismiss];
    }
}

- (IBAction)deleteBt:(id)sender {
    if (!self.pwdStr || [self.pwdStr isEqualToString:@""]) {
        self.tipLabel.text = @"提示 : 密码不为空";
        return;
    }
    if (self.cancelBlock) {
        self.cancelBlock();
    }
    [self dismiss];
}

-(void)modifyTitleLabelText{
    self.titleLabel.text = @"提示:私有相册需要设置密码";
}
-(BOOL)checkInputStr{
    NSString *password = [self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([password isEqualToString:@""]) {
        self.tipLabel.text = @"提示 : 密码不为空";
//        [self performSelector:@selector(modifyTitleLabelText) withObject:nil afterDelay:3.0];
        return NO;
    }
    return YES;
}

-(void)viewExit{
    self.successBlock = nil;
    self.failureBlock = nil;
    self.cancelBlock = nil;
}
@end
