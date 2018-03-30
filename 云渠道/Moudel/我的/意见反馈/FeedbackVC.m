//
//  FeedbackVC.m
//  云渠道
//
//  Created by 谷治墙 on 2018/3/23.
//  Copyright © 2018年 xiaoq. All rights reserved.
//

#import "FeedbackVC.h"

@interface FeedbackVC ()<UITextViewDelegate>

@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, strong) UILabel *placeL;

@property (nonatomic, strong) UIButton *confirmBtn;

@end

@implementation FeedbackVC

- (void)viewDidLoad {
    [super viewDidLoad];
    

    [self initUI];
}

- (void)textViewDidChange:(UITextView *)textView{
    
    if (textView.text.length) {
        
        _placeL.hidden = YES;
    }else{
        
        _placeL.hidden = NO;
    }
}

- (void)ActionConfirmBtn:(UIButton *)btn{
    
    
}

- (void)initUI{
    
    self.navBackgroundView.hidden = NO;
    self.titleLabel.text = @"意见反馈";
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, SCREEN_Width, 150 *SIZE)];
    view.backgroundColor = CH_COLOR_white;
    [self.view addSubview:view];
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(22 *SIZE, 10 *SIZE, 320 *SIZE, 105 *SIZE)];
    _textView.delegate = self;
    [view addSubview:_textView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 123 *SIZE, 350 *SIZE, 11 *SIZE)];
    label.textColor = YJContentLabColor;
    label.font = [UIFont systemFontOfSize:12 *SIZE];
    label.textAlignment = NSTextAlignmentRight;
    label.text = @"200字以内";
    [view addSubview:label];
    
    
    
    _placeL = [[UILabel alloc] initWithFrame:CGRectMake(5 *SIZE, 8 *SIZE, 150 *SIZE, 11 *SIZE)];
    _placeL.textColor = YJContentLabColor;
    _placeL.text = @"请输入意见反馈...";
    _placeL.font = [UIFont systemFontOfSize:12 *SIZE];
    [_textView addSubview:_placeL];
    
    _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _confirmBtn.frame = CGRectMake(22 *SIZE, 475 *SIZE + NAVIGATION_BAR_HEIGHT, 314 *SIZE, 40 *SIZE);
    _confirmBtn.titleLabel.font = [UIFont systemFontOfSize:14 *sIZE];
    [_confirmBtn addTarget:self action:@selector(ActionConfirmBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_confirmBtn setTitle:@"提交" forState:UIControlStateNormal];
    [_confirmBtn setTitleColor:CH_COLOR_white forState:UIControlStateNormal];
    [_confirmBtn setBackgroundColor:YJBlueBtnColor];
    [self.view addSubview:_confirmBtn];
}

@end
