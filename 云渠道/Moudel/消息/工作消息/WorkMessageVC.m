//
//  WorkMessageVC.m
//  云渠道
//
//  Created by xiaoq on 2018/3/23.
//  Copyright © 2018年 xiaoq. All rights reserved.
//

#import "WorkMessageVC.h"
#import "WorkMessageCell.h"
#import "InfoDetailVC.h"

@interface WorkMessageVC ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *_data;
    int page;
}

@property (nonatomic , strong) UITableView *systemmsgtable;


-(void)initUI;
-(void)initDateSouce;

@end

@implementation WorkMessageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = YJBackColor;
    self.navBackgroundView.hidden = NO;
    self.titleLabel.text = @"工作消息";
    [self postWithpage:@"1"];
    [self initDateSouce];
    [self initUI];
    
}

-(void)postWithpage:(NSString *)page{
    
    [BaseRequest GET:WorkingInfoList_URL parameters:@{
                                                      @"page":page
                                                      }
             success:^(id resposeObject) {
        if ([resposeObject[@"code"] integerValue]==200) {
            if ([page isEqualToString:@"1"]) {
                _data = resposeObject[@"data"][@"data"];
                [_systemmsgtable reloadData];
                [_systemmsgtable.mj_footer endRefreshing];
                
            }
            else{
                NSArray *arr =resposeObject[@"data"][@"data"];
                if (arr.count ==0) {
                    [_systemmsgtable.mj_footer setState:MJRefreshStateNoMoreData];
                }
                else{
                    [_data addObjectsFromArray:arr];
                    [_systemmsgtable reloadData];
                    [_systemmsgtable.mj_footer endRefreshing];
                    
                }
                
            }
            
            [_systemmsgtable.mj_header endRefreshing];
        }
    } failure:^(NSError *error) {
        [self showContent:@"网络错误"];
        [_systemmsgtable.mj_footer endRefreshing];
        [_systemmsgtable.mj_header endRefreshing];
    }];
}

-(void)initDateSouce
{
    _data = [NSMutableArray arrayWithArray:@[]];
}

-(void)initUI
{
    [self.view addSubview:self.systemmsgtable];
    
}




#pragma mark  ---  delegate   ---

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _data.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 127*SIZE;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WorkMessageCell";
    
    WorkMessageCell *cell  = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[WorkMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if ([_data[indexPath.row][@"attribute"][@"is_read"] integerValue] == 0) {
        
        [cell SetCellbytitle:_data[indexPath.row][@"title"] num:[NSString stringWithFormat:@"推荐编号：%@",_data[indexPath.row][@"client_id"]]  name:[NSString stringWithFormat:@"姓名：%@",_data[indexPath.row][@"name"]] project:[NSString stringWithFormat:@"项目：%@",_data[indexPath.row][@"project_name"]] time: _data[indexPath.row][@"create_time"] messageimg:0];
    }else{
        
        [cell SetCellbytitle:_data[indexPath.row][@"title"] num:[NSString stringWithFormat:@"推荐编号：%@",_data[indexPath.row][@"client_id"]]  name:[NSString stringWithFormat:@"姓名：%@",_data[indexPath.row][@"name"]] project:[NSString stringWithFormat:@"项目：%@",_data[indexPath.row][@"project_name"]] time: _data[indexPath.row][@"create_time"] messageimg:0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    InfoDetailVC * next_vc =[[InfoDetailVC alloc]init];
    [self.navigationController pushViewController:next_vc animated:YES];
}



#pragma mark  ---  懒加载   ---
-(UITableView *)systemmsgtable
{
    if(!_systemmsgtable)
    {
        _systemmsgtable =   [[UITableView alloc]initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, 360*SIZE, SCREEN_Height-NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
        _systemmsgtable.backgroundColor = YJBackColor;
        _systemmsgtable.delegate = self;
        _systemmsgtable.dataSource = self;
        _systemmsgtable.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self postWithpage:@"1"];
        }];
        _systemmsgtable.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            page++;
            [self postWithpage:[NSString stringWithFormat:@"%d",page]];
        }];
        [_systemmsgtable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }
    return _systemmsgtable;
}
@end
