//
//  CountDownCell.m
//  云渠道
//
//  Created by xiaoq on 2018/3/27.
//  Copyright © 2018年 xiaoq. All rights reserved.
//

#import "CountDownCell.h"

@interface CountDownCell ()
@property (nonatomic , strong) UILabel *dayL;
@property (nonatomic , strong) UILabel *hourL;
@property (nonatomic , strong) UILabel *minL;
@property (nonatomic , strong) UILabel *secL;
@property (nonatomic , assign)  NSInteger day;
@property (nonatomic , assign)  NSInteger hour;
@property (nonatomic , assign)  NSInteger min;
@property (nonatomic , assign)  NSInteger sec;
@property (nonatomic , strong) NSTimer *timer;


@end

@implementation CountDownCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self initUI];
    }
    return self;
}

-(void)initUI
{
    
    _dayL = [[UILabel alloc]init];
    _dayL.textColor = [UIColor whiteColor];
    _dayL.textAlignment = NSTextAlignmentCenter;
    _dayL.font = [UIFont systemFontOfSize:13*SIZE];
    _dayL.backgroundColor = COLOR(255, 165, 29, 1);
    _dayL.layer.masksToBounds = YES;
    _dayL.layer.cornerRadius = 3.3*SIZE;
    [self.contentView addSubview:_dayL];
    [_dayL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(96.7*SIZE);
        make.top.equalTo(self.contentView).offset(30*SIZE);
        make.width.mas_equalTo(33*SIZE);
        make.height.mas_equalTo(30*SIZE);
        make.bottom.equalTo(self.contentView).offset(-15*SIZE);
    }];
    for (int i=0; i<3; i++) {
        UILabel *maohao = [[UILabel alloc]initWithFrame:CGRectMake(132*SIZE+i*44*SIZE, 30*SIZE, 10*SIZE, 30*SIZE)];
        maohao.textColor = COLOR(255, 165, 29, 1);
        maohao.text = @":";
        [self.contentView addSubview:maohao];
    }
    _hourL= [[UILabel alloc]init];
    _hourL.textColor = [UIColor whiteColor];
    _hourL.textAlignment = NSTextAlignmentCenter;
    _hourL.font = [UIFont systemFontOfSize:13*SIZE];
    _hourL.backgroundColor = COLOR(255, 165, 29, 1);
    _hourL.layer.masksToBounds = YES;
    _hourL.layer.cornerRadius = 3.3*SIZE;
    [self.contentView addSubview:_hourL];
    [_hourL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(140.7*SIZE);
        make.top.equalTo(self.contentView).offset(30*SIZE);
        make.width.mas_equalTo(33*SIZE);
        make.height.mas_equalTo(30*SIZE);
        make.bottom.equalTo(self.contentView).offset(-15*SIZE);
    }];
   
    _minL= [[UILabel alloc]init];
    _minL.textColor = [UIColor whiteColor];
    _minL.textAlignment = NSTextAlignmentCenter;
    _minL.font = [UIFont systemFontOfSize:13*SIZE];
    _minL.backgroundColor = COLOR(255, 165, 29, 1);
    _minL.layer.masksToBounds = YES;
    _minL.layer.cornerRadius = 3.3*SIZE;
    [self.contentView addSubview:_minL];
    [_minL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(184.7*SIZE);
        make.top.equalTo(self.contentView).offset(30*SIZE);
        make.width.mas_equalTo(33*SIZE);
        make.height.mas_equalTo(30*SIZE);
        make.bottom.equalTo(self.contentView).offset(-15*SIZE);
    }];
    _secL = [[UILabel alloc]init];
    _secL.textColor = [UIColor whiteColor];
    _secL.textAlignment = NSTextAlignmentCenter;
    _secL.font = [UIFont systemFontOfSize:13*SIZE];
    _secL.backgroundColor = COLOR(255, 165, 29, 1);
    _secL.layer.masksToBounds = YES;
    _secL.layer.cornerRadius = 3.3*SIZE;
    [self.contentView addSubview:_secL];
    [_secL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(228.7*SIZE);
        make.top.equalTo(self.contentView).offset(30*SIZE);
        make.width.mas_equalTo(33*SIZE);
        make.height.mas_equalTo(30*SIZE);
        make.bottom.equalTo(self.contentView).offset(-15*SIZE);
    }];
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(27*SIZE, 0*SIZE, 300*SIZE, 14*SIZE)];
    title.font = [UIFont systemFontOfSize:13.3*SIZE];
    title.textColor = YJContentLabColor;
    title.text = @"失效倒计时：";
    [self.contentView addSubview:title];
}



-(void)setcountdownbyday:(NSInteger)day hours:(NSInteger)hours min:(NSInteger)min sec:(NSInteger)sec
{
    if (!(_day>0 || _hour>0||_min> 0 || _sec> 0)) {
        _day = day;
        _hour = hours;
        _min = min;
        _sec = sec;
        _dayL.text = [NSString stringWithFormat:@"%ld天",day];
        _hourL.text = [NSString stringWithFormat:@"%ld",hours];
        _minL.text = [NSString stringWithFormat:@"%ld",min];
        _secL.text = [NSString stringWithFormat:@"%ld",sec];
        _timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerUpdate) userInfo:nil repeats:YES];
                [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
        [_timer fire];
    }
}

-(void)setcountdownbyendtime:(NSString *)endtime
{
    //获得当前时间
    NSDate *now = [NSDate date];
    NSTimeInterval time=[endtime doubleValue];
    NSTimeInterval oldTime = [now timeIntervalSince1970];
    NSInteger timeDifference = time-oldTime;
    
    if (time - oldTime>0) {
        _day =  (int)timeDifference /86400;
        _hour =(int)timeDifference%86400/3600;
        _min = (int)timeDifference%86400%3600/60;
        _sec = (int)timeDifference%86400%3600%60;
    }
    else{
        _day =  0;
        _hour =0;
        _min = 0;
        _sec = 0;
    }

//     修改倒计时标签及显示内容

    _dayL.text = [NSString stringWithFormat:@"%ld天",_day];
    _hourL.text = [NSString stringWithFormat:@"%ld",_hour];
    _minL.text = [NSString stringWithFormat:@"%ld",_min];
    _secL.text = [NSString stringWithFormat:@"%ld",_sec];
    _timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerUpdate) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    [_timer fire];
    
}



-(void)timerUpdate
{
    if (_sec >0) {
        _sec--;
        _secL.text = [NSString stringWithFormat:@"%ld",_sec];
    }
    else
    {
        if (_min > 0) {
            _min--;
            _minL.text = [NSString stringWithFormat:@"%ld",_min];
            _sec = 59;
            _secL.text = [NSString stringWithFormat:@"%ld",_sec];
        }
        else{
            if (_hour > 0) {
                _hour--;
                _hourL.text = [NSString stringWithFormat:@"%ld",_hour];
                _min = 59;
                _minL.text = [NSString stringWithFormat:@"%ld",_min];
                _sec = 59;
                _secL.text = [NSString stringWithFormat:@"%ld",_sec];
            }
            else
            {
                if (_day > 0) {
                    _day--;
                    _dayL.text = [NSString stringWithFormat:@"%ld天",_day];
                    _hour= 23;
                    _hourL.text = [NSString stringWithFormat:@"%ld",_hour];
                    _min = 59;
                    _minL.text = [NSString stringWithFormat:@"%ld",_min];
                    _sec = 59;
                    _secL.text = [NSString stringWithFormat:@"%ld",_sec];
                }
                else
                {
                    
                    [_timer invalidate];
                    _timer = nil;
                    if (self.countdownblock) {
                        self.countdownblock();
                    }
                    
                }
            }
            
        }
    }
}


@end
