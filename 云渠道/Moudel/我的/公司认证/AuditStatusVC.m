//
//  AuditStatusVC.m
//  云渠道
//
//  Created by 谷治墙 on 2018/4/10.
//  Copyright © 2018年 xiaoq. All rights reserved.
//

#import "AuditStatusVC.h"
#import "InfoDetailCell.h"

@interface AuditStatusVC ()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray *_data;
    NSArray *_titleArr;
    NSDictionary *_dataDic;
}
@property (nonatomic , strong) UITableView *statusTable;

@end

@implementation AuditStatusVC

- (instancetype)initWithData:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        
        _dataDic = data;
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
    
    _data = @[[NSString stringWithFormat:@"姓名：%@",[UserInfoModel defaultModel].name],[NSString stringWithFormat:@"公司名称：%@",_dataDic[@"company_name"]],[NSString stringWithFormat:@"工号：%@",_dataDic[@"work_code"]],[NSString stringWithFormat:@"部门：%@",_dataDic[@"department"]],[NSString stringWithFormat:@"位置：%@",_dataDic[@"position"]]];
    
}

#pragma mark    -----  delegate   ------

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if (section == 3) {
//
//        return 7;
//    }
//    return 3;
    return 5;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *backview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 360*SIZE, 162*SIZE)];
    backview.backgroundColor = [UIColor whiteColor];
    UIView *blueView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_Width, 117 *SIZE)];
    blueView.backgroundColor = YJBlueBtnColor;
    [backview addSubview:blueView];
    
    UILabel *statusL = [[UILabel alloc] initWithFrame:CGRectMake(0, 31 *SIZE, SCREEN_Width, 17 *SIZE)];
    statusL.textColor = CH_COLOR_white;
    statusL.font = [UIFont systemFontOfSize:19 *SIZE];
    statusL.textAlignment = NSTextAlignmentCenter;
    statusL.text = @"审核中";
    [backview addSubview:statusL];
    
    UIView * header = [[UIView alloc]initWithFrame:CGRectMake(10*SIZE , 136*SIZE, 6.7*SIZE, 13.3*SIZE)];
    header.backgroundColor = YJBlueBtnColor;
    [backview addSubview:header];
    UILabel * title = [[UILabel alloc]initWithFrame:CGRectMake(27.3*SIZE, 137*SIZE, 300*SIZE, 16*SIZE)];
    title.font = [UIFont systemFontOfSize:15.3*SIZE];
    title.textColor = YJTitleLabColor;
    title.text = @"申请信息";
    [backview addSubview:title];
    return backview;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 162*SIZE;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"InfoDetailCell";
    InfoDetailCell *cell  = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[InfoDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [cell SetCellContentbystring:_data[indexPath.row]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)initUI{
    
    self.navBackgroundView.hidden = NO;
    self.titleLabel.text = @"审核状态";
    
    
    _statusTable.rowHeight = 150 *SIZE;
    _statusTable.estimatedRowHeight = UITableViewAutomaticDimension;
    
    _statusTable = [[UITableView alloc]initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, 360*SIZE, SCREEN_Height - NAVIGATION_BAR_HEIGHT) style:UITableViewStyleGrouped];
    _statusTable.backgroundColor = YJBackColor;
    _statusTable.delegate = self;
    _statusTable.dataSource = self;
    [_statusTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:_statusTable];

    
}


@end
