//
//  AppealComplaintedVC.m
//  云渠道
//
//  Created by 谷治墙 on 2018/5/17.
//  Copyright © 2018年 xiaoq. All rights reserved.
//

#import "AppealComplaintedVC.h"
#import "CountDownCell.h"
#import "InfoDetailCell.h"
#import "BrokerageDetailTableCell3.h"

@interface AppealComplaintedVC ()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray *_data;
    NSArray *_titleArr;
    NSString *_clientId;
    NSString *_appealId;
    NSMutableDictionary *_dataDic;
    NSString *_endtime;
    NSString *_name;
    NSArray *_Pace;
}
@property (nonatomic , strong) UITableView *completeTable;

@property (nonatomic , strong) UIButton *continueBtn;

@end

@implementation AppealComplaintedVC

- (instancetype)initWithAppealId:(NSString *)appealId
{
    self = [super init];
    if (self) {
        
        _appealId = appealId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initDataSouce];
    [self initUI];
}


-(void)initDataSouce
{
    
    _titleArr = @[@"申诉信息",@"无效信息",@"推荐信息",@"到访信息"];
    [self AppealRequestMethod];
}

- (void)AppealRequestMethod{
    
    [BaseRequest GET:BrokerAppealDetail_URL parameters:@{@"appeal_id":_appealId} success:^(id resposeObject) {
        
        if ([resposeObject[@"code"] integerValue] == 200) {
            
            _dataDic = [NSMutableDictionary dictionaryWithDictionary:resposeObject[@"data"]];
            [_dataDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                
                if ([obj isKindOfClass:[NSNull class]]) {
                    
                    [_dataDic setObject:@"" forKey:key];
                }
            }];
            
            NSString *sex = @"客户性别：";
            if ([_dataDic[@"sex"] integerValue] == 1) {
                sex = @"客户性别：男";
            }
            if([_dataDic[@"sex"] integerValue] == 2)
            {
                sex =@"客户性别：女";
            }
            _name = _dataDic[@"name"];
            NSString *tel = _dataDic[@"tel"];
            NSArray *arr = [tel componentsSeparatedByString:@","];
            if (arr.count>0) {
                tel = [NSString stringWithFormat:@"联系方式：%@",arr[0]];
            }
            else{
                tel = @"联系方式：";
            }
            NSString *adress = _dataDic[@"absolute_address"];
            adress = [NSString stringWithFormat:@"项目地址：%@-%@-%@ %@",_dataDic[@"province_name"],_dataDic[@"city_name"],_dataDic[@"district_name"],adress];
            
            _data = @[@[[NSString stringWithFormat:@"申诉类型：%@",_dataDic[@"type"]],[NSString stringWithFormat:@"申诉描述：%@",_dataDic[@"comment"]],[NSString stringWithFormat:@"处理状态：%@",_dataDic[@"state"]],[NSString stringWithFormat:@"处理结果：%@",_dataDic[@"solve_info"]]],@[[NSString stringWithFormat:@"无效类型：%@",_dataDic[@"disabled_state"]],[NSString stringWithFormat:@"无效描述：%@",_dataDic[@"disabled_reason"]],[NSString stringWithFormat:@"无效时间：%@",_dataDic[@"disabled_time"]]],@[[NSString stringWithFormat:@"推荐编号：%@",_dataDic[@"client_id"]],[NSString stringWithFormat:@"推荐时间：%@",_dataDic[@"recommend_time"]],[NSString stringWithFormat:@"推荐人：%@",_dataDic[@"broker_name"]],[NSString stringWithFormat:@"联系方式：%@",_dataDic[@"broker_tel"]],[NSString stringWithFormat:@"项目名称：%@",_dataDic[@"project_name"]],adress,[NSString stringWithFormat:@"客户姓名：%@",_dataDic[@"name"]],sex,tel],@[[NSString stringWithFormat:@"客户姓名：%@",_dataDic[@"confirm_name"]],[NSString stringWithFormat:@"联系方式：%@",_dataDic[@"confirm_tel"]],[NSString stringWithFormat:@"到访人数：%@人",_dataDic[@"visit_num"]],[NSString stringWithFormat:@"到访时间：%@",_dataDic[@"visit_time"]],[NSString stringWithFormat:@"置业顾问：%@",_dataDic[@"property_advicer_wish"]],[NSString stringWithFormat:@"到访确认人：%@",_dataDic[@"butter_name"]],[NSString stringWithFormat:@"确认人电话：%@",_dataDic[@"butter_tel"]]]];
            
            _endtime = _dataDic[@"timeLimit"];
            _Pace = _dataDic[@"process"];
            
            [_completeTable reloadData];
        }
        else{
            [self showContent:resposeObject[@"msg"]];
        }
    } failure:^(NSError *error) {
        
        [self showContent:@"网络错误"];
    }];
}

- (void)ActionContinueBtn:(UIButton *)btn{
    
    
}

#pragma mark    -----  delegate   ------

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 4) {
        
        return _Pace.count;
    }
    else
    {
        NSArray *arr = _data[section];
        return arr.count;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *backview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 360*SIZE, 53*SIZE)];
    backview.backgroundColor = [UIColor whiteColor];
    UIView * header = [[UIView alloc]initWithFrame:CGRectMake(10*SIZE , 19*SIZE, 6.7*SIZE, 13.3*SIZE)];
    header.backgroundColor = YJBlueBtnColor;
    
    UILabel * title = [[UILabel alloc]initWithFrame:CGRectMake(27.3*SIZE, 19*SIZE, 300*SIZE, 16*SIZE)];
    title.font = [UIFont systemFontOfSize:15.3*SIZE];
    title.textColor = YJTitleLabColor;
    if (section < 4) {
        
        title.text = _titleArr[section];
        [backview addSubview:header];
        [backview addSubview:title];
    }
    return backview;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    if (section < 4) {
        
        return 53*SIZE;
    }
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return _data.count ? _Pace.count?_data.count + 1:_data.count:0;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    if (indexPath.section == 4) {
        
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
        if (indexPath.row == _Pace.count - 1) {
            
            cell.downLine.hidden = YES;
        }else{
            
            cell.downLine.hidden = NO;
        }
        return cell;
        
    }else{
        
        static NSString *CellIdentifier = @"InfoDetailCell";
        InfoDetailCell *cell  = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[InfoDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        [cell SetCellContentbystring:_data[indexPath.section][indexPath.row]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (void)initUI{
    
    self.navBackgroundView.hidden = NO;
    self.titleLabel.text = @"申诉详情";
    
    
    _completeTable = [[UITableView alloc]initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, 360*SIZE, SCREEN_Height - NAVIGATION_BAR_HEIGHT) style:UITableViewStyleGrouped];
    _completeTable.rowHeight = UITableViewAutomaticDimension;
    _completeTable.estimatedRowHeight = 150 *SIZE;
    _completeTable.backgroundColor = YJBackColor;
    _completeTable.delegate = self;
    _completeTable.dataSource = self;
    [_completeTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:_completeTable];
    
}

@end
