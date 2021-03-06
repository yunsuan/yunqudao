//
//  CustomRequireModel.h
//  云渠道
//
//  Created by 谷治墙 on 2018/4/11.
//  Copyright © 2018年 xiaoq. All rights reserved.
//

#import "BaseModel.h"

@interface CustomRequireModel : BaseModel

@property (nonatomic, strong) NSString *agent_id;

@property (nonatomic, strong) NSString *area;

@property (nonatomic, strong) NSString *buy_purpose;

@property (nonatomic, strong) NSString *client_id;

@property (nonatomic, strong) NSString *comment;

@property (nonatomic, strong) NSString *create_time;

@property (nonatomic, strong) NSString *decorate;

@property (nonatomic, strong) NSString *floor_max;

@property (nonatomic, strong) NSString *floor_min;

@property (nonatomic, strong) NSString *house_type;

@property (nonatomic, strong) NSString *intent;

@property (nonatomic, strong) NSString *ladder_ratio;

@property (nonatomic, strong) NSString *need_id;

@property (nonatomic, strong) NSString *need_tags;

@property (nonatomic, strong) NSString *orientation;

@property (nonatomic, strong) NSString *pay_type;

@property (nonatomic, strong) NSString *property_type;

@property (nonatomic, strong) NSMutableArray *region;

@property (nonatomic, strong) NSString *state;

@property (nonatomic, strong) NSString *total_price;

@property (nonatomic, strong) NSString *update_time;

@property (nonatomic, strong) NSString *urgency;

@end
