//
//  HouseTypeDetailVC.h
//  云渠道
//
//  Created by 谷治墙 on 2018/4/4.
//  Copyright © 2018年 xiaoq. All rights reserved.
//

#import "BaseViewController.h"

#import "RoomDetailModel.h"

@interface HouseTypeDetailVC : BaseViewController

@property (nonatomic, strong) RoomDetailModel *model;

@property (nonatomic, strong) NSMutableArray *dataArr;

- (instancetype)initWithHouseTypeId:(NSString *)houseTypeId index:(NSInteger )index dataArr:(NSArray *)dataArr projectId:(NSString *)projectId;

@end
