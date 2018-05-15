//
//  BrokerageDetailVC.m
//  云渠道
//
//  Created by 谷治墙 on 2018/3/29.
//  Copyright © 2018年 xiaoq. All rights reserved.
//

#import "BrokerageDetailVC.h"
#import "BrokerageDetailTableCell.h"
#import "BrokerageDetailTableCell2.h"
#import "BrokerageDetailTableCell3.h"
#import "BrokerageDetailTableCell4.h"
#import "BrokerDetailHeader.h"

@interface BrokerageDetailVC ()<UITableViewDelegate,UITableViewDataSource>
{
    
    BOOL _drop;
    NSDictionary *_data;
    NSArray *_Pace;
}

@property (nonatomic, strong) UITableView *brokerTable;
@property (nonatomic , strong) UIButton *moneybtn;

@end

@implementation BrokerageDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self post];
    
}

-(void)post{
    [BaseRequest GET:PayDetail_URL
          parameters:@{
             @"broker_id":_broker_id
                        }
             success:^(id resposeObject) {
                 if ([resposeObject[@"code"] integerValue] == 200) {
                     _data = resposeObject[@"data"];
                     _Pace = resposeObject[@"data"][@"process"];
                     [_brokerTable reloadData];
                 }
                 
                        }
             failure:^(NSError *error) {
                 [self showContent:@"网络错误"];
                                                }];
    
}


#pragma mark -- Tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 2) {
            return _Pace.count+1;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (section == 2) {
        
        return 50 *SIZE;
    }
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 6 *SIZE;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (section == 2) {
        
        BrokerDetailHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"BrokerDetailHeader"];
        if (!header) {
            
            header = [[BrokerDetailHeader alloc] initWithFrame:CGRectMake(0, 0, SCREEN_Width, 50 *SIZE)];
        }
        header.titleL.text = @"当前项目进度";
        header.dropBtnBlock = ^{

        };
        
        return header;
    }
    return [[UIView alloc] init];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        
        BrokerageDetailTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BrokerageDetailTableCell"];
        if (!cell) {
            
            cell = [[BrokerageDetailTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BrokerageDetailTableCell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.titleL.text = @"推荐客户";
        cell.nameL.text = [NSString stringWithFormat:@"姓名：%@",_data[@"name"]];
        NSString *sex = @"性别：无";
        if ([_data[@"sex"] integerValue] == 1) {
            sex = @"性别：男";
        }
        if([_data[@"sex"]  integerValue] == 2)
        {
            sex =@"性别：女";
        }
        cell.genderL.text =sex;
        cell.phoneL.text = [NSString stringWithFormat:@"电话：%@",_data[@"tel"]];
        return cell;
    }else{
        
        if (indexPath.section == 1) {
            
            BrokerageDetailTableCell2 *cell = [tableView dequeueReusableCellWithIdentifier:@"BrokerageDetailTableCell2"];
            if (!cell) {
                
                cell = [[BrokerageDetailTableCell2 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BrokerageDetailTableCell2"];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.titleL.text = @"推荐项目";
            cell.codeL.text = [NSString stringWithFormat:@"推荐编号：%@",_data[@"client_id"]];
            cell.nameL.text = [NSString stringWithFormat:@"项目名称：%@",_data[@"project_name"]];
            cell.houseTypeL.text = [NSString stringWithFormat:@"物业类型：%@",_data[@"property"]];
            cell.addressL.text = [NSString stringWithFormat:@"项目地址：%@",_data[@"absolute_address"]];
            
            cell.brokerTypeL.text = [NSString stringWithFormat:@"佣金类型：%@",_data[@"broker_type"]];
            cell.priceL.text =  [NSString stringWithFormat:@"佣金金额：%@元",_data[@"broker_num"]];
            cell.timeL.text = [NSString stringWithFormat:@"产生时间：%@",_data[@"visit_time"]];
            if ([_type isEqualToString:@"1"]) {
                cell.endTimeL.text = [NSString stringWithFormat:@"结佣时间：%@",_data[@"pay_time"]];
                cell.statusImg.image = [UIImage imageNamed:@"seal_knot"];
            }
            else
            {
                cell.endTimeL.text =@"";
                cell.statusImg.image = [UIImage imageNamed:@"nocommission"];
            }
            
            
            return cell;
        }else{
            
            if (indexPath.row == _Pace.count) {
                
                BrokerageDetailTableCell4 *cell = [tableView dequeueReusableCellWithIdentifier:@"BrokerageDetailTableCell4"];
                if (!cell) {
                    
                    cell = [[BrokerageDetailTableCell4 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BrokerageDetailTableCell4"];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }else{
                
                BrokerageDetailTableCell3 *cell = [tableView dequeueReusableCellWithIdentifier:@"BrokerageDetailTableCell3"];
                if (!cell) {
                    
                    cell = [[BrokerageDetailTableCell3 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BrokerageDetailTableCell3"];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                cell.titleL.text = [NSString stringWithFormat:@"%@时间：%@",_Pace[indexPath.row][@"process_name"],_Pace[indexPath.row][@"time"]];
                if (indexPath.row == 0) {
                    
                    cell.upLine.hidden = YES;
                }else{
                    
                    cell.upLine.hidden = NO;
                }
                if (indexPath.row == _Pace.count-1) {
                    
                    cell.downLine.hidden = YES;
                }else{
                    
                    cell.downLine.hidden = NO;
                }
                return cell;
            }
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_Width, 6 *SIZE)];
}

- (void)initUI{
    
    self.navBackgroundView.hidden = NO;
    if ([_type isEqualToString:@"1"]) {
        self.titleLabel.text = @"已结佣金详情";
    }
    else
    {
        self.titleLabel.text = @"未结佣金详情";
    }
    
    _brokerTable.rowHeight = 397 *SIZE;
    _brokerTable.estimatedRowHeight = UITableViewAutomaticDimension;
    if ([_type isEqualToString:@"1"]) {
            _brokerTable = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, SCREEN_Width, SCREEN_Height - NAVIGATION_BAR_HEIGHT) style:UITableViewStyleGrouped];
    }else{
        _brokerTable = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, SCREEN_Width, SCREEN_Height - NAVIGATION_BAR_HEIGHT-TAB_BAR_HEIGHT) style:UITableViewStyleGrouped];
        if ([_is_urge integerValue] ==1) {
            [_moneybtn setTitle:@"已结佣" forState:UIControlStateNormal];
            _moneybtn.userInteractionEnabled = YES;
        }
        [self.view addSubview:self.moneybtn];
    }

    _brokerTable.backgroundColor = self.view.backgroundColor;
    _brokerTable.delegate = self;
    _brokerTable.dataSource = self;
    _brokerTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_brokerTable];
}

-(UIButton *)moneybtn
{
    if (!_moneybtn) {
        _moneybtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _moneybtn.frame = CGRectMake(0, SCREEN_Height-TAB_BAR_HEIGHT, 360*SIZE, TAB_BAR_HEIGHT);
        [_moneybtn setTitle:@"催佣" forState:UIControlStateNormal];
        _moneybtn.titleLabel.font = [UIFont systemFontOfSize:15*SIZE];
        [_moneybtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_moneybtn addTarget:self action:@selector(action_urge) forControlEvents:UIControlEventTouchUpInside];
        _moneybtn.backgroundColor = YJBlueBtnColor;
    }
    return _moneybtn;
}

-(void)action_urge
{
    [BaseRequest POST:Urge_URL parameters:@{
                                            @"broker_id":_broker_id
                                            }
              success:^(id resposeObject) {
                  NSLog(@"%@",resposeObject);
                  if ([resposeObject[@"code"] integerValue]==200) {
                      [_moneybtn setTitle:@"已催佣" forState:UIControlStateNormal];
                      _moneybtn.userInteractionEnabled = NO;
                  }
                  else
                  {
                      [self showContent:resposeObject[@"msg"]];
                  }
              }
              failure:^(NSError *error) {
                  NSLog(@"%@",error.description);
              }];
}

@end
