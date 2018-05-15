//
//  ApplyProjectVC.m
//  云渠道
//
//  Created by 谷治墙 on 2018/5/15.
//  Copyright © 2018年 xiaoq. All rights reserved.
//

#import "ApplyProjectVC.h"
#import "PeopleCell.h"
#import "RoomListModel.h"

@interface ApplyProjectVC ()<UITableViewDelegate,UITableViewDataSource>
{
    
    NSString *_companyId;
    NSMutableArray *_dataArr;
}

@property (nonatomic , strong) UITableView *MainTableView;

@end

@implementation ApplyProjectVC

- (instancetype)initWithCompanyId:(NSString *)companyId
{
    self = [super init];
    if (self) {
        
        _companyId = companyId;
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = YJBackColor;
    self.navBackgroundView.hidden = NO;
    [self initDateSouce];
    [self initUI];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)initDateSouce
{
    
    _dataArr = [@[] mutableCopy];
    [self RequestMethod];
}



- (void)RequestMethod{

//    if (_page == 1) {
//
//        self.MainTableView.mj_footer.state = MJRefreshStateIdle;
//    }

//    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:@{@"page":@(_page)}];
//    if (_city.length) {
//
//        [dic setObject:_city forKey:@"city"];
//    }
//    if (_district.length) {
//
//        [dic setObject:_district forKey:@"district"];
//    }
//    if (![_price isEqualToString:@"0"] && _price) {
//
//        [dic setObject:[NSString stringWithFormat:@"%@",_price] forKey:@"average_price"];
//    }
//    if (![_type isEqualToString:@"0"] && _type) {
//
//        [dic setObject:[NSString stringWithFormat:@"%@",_type] forKey:@"property_id"];
//    }
//    if (_tag.length) {
//
//        [dic setObject:[NSString stringWithFormat:@"%@",_tag] forKey:@"project_tags"];
//    }
//    if (_houseType.length) {
//
//        [dic setObject:[NSString stringWithFormat:@"%@",_houseType] forKey:@"house_type"];
//    }
    NSDictionary *dic = @{@"company_id":_companyId};

    [BaseRequest GET:GetCompanyProject_URL parameters:dic success:^(id resposeObject) {

//        [self.MainTableView.mj_header endRefreshing];
        NSLog(@"%@",resposeObject);
        [self showContent:resposeObject[@"msg"]];
        if ([resposeObject[@"code"] integerValue] == 200) {

            [self SetData:resposeObject[@"data"]];
        }else{

        }
    } failure:^(NSError *error) {

        [self.MainTableView.mj_header endRefreshing];
        [self showContent:@"网络错误"];
        NSLog(@"%@",error.localizedDescription);
    }];

}
//
//- (void)RequestAddMethod{
//
//    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:@{@"page":@(_page)}];
//    if (_city.length) {
//
//        [dic setObject:_city forKey:@"city"];
//    }
//    if (_district.length) {
//
//        [dic setObject:_district forKey:@"district"];
//    }
//    if (![_price isEqualToString:@"0"] && _price) {
//
//        [dic setObject:[NSString stringWithFormat:@"%@",_price] forKey:@"average_price"];
//    }
//    if (![_type isEqualToString:@"0"] && _type) {
//
//        [dic setObject:[NSString stringWithFormat:@"%@",_type] forKey:@"property_id"];
//    }
//    if (_tag.length) {
//
//        [dic setObject:[NSString stringWithFormat:@"%@",_type] forKey:@"project_tags"];
//    }
//    if (_houseType.length) {
//
//        [dic setObject:[NSString stringWithFormat:@"%@",_houseType] forKey:@"house_type"];
//    }
//
//    [BaseRequest GET:ProjectList_URL parameters:dic success:^(id resposeObject) {
//
//        NSLog(@"%@",resposeObject);
//        [self showContent:resposeObject[@"msg"]];
//        if ([resposeObject[@"code"] integerValue] == 200) {
//
//            if ([resposeObject[@"data"] isKindOfClass:[NSDictionary class]]) {
//
//                if ([resposeObject[@"data"][@"data"] isKindOfClass:[NSArray class]]) {
//
//                    [self SetData:resposeObject[@"data"][@"data"]];
//                    if (_page == [resposeObject[@"data"][@"last_page"] integerValue]) {
//
//                        self.MainTableView.mj_footer.state = MJRefreshStateNoMoreData;
//                    }
//                }else{
//
//                    self.MainTableView.mj_footer.state = MJRefreshStateNoMoreData;
//                }
//            }else{
//
//                [self.MainTableView.mj_footer endRefreshing];
//            }
//        }else{
//
//            [self.MainTableView.mj_footer endRefreshing];
//        }
//    } failure:^(NSError *error) {
//
//        [self showContent:@"网路错误"];
//        [self.MainTableView.mj_footer endRefreshing];
//        NSLog(@"%@",error.localizedDescription);
//    }];
//
//}

//
- (void)SetData:(NSArray *)data{

    for (int i = 0; i < data.count; i++) {

        NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] initWithDictionary:data[i]];
        [tempDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {

            if ([obj isKindOfClass:[NSNull class]]) {

                [tempDic setObject:@"" forKey:key];
            }
        }];

        RoomListModel *model = [[RoomListModel alloc] initWithDictionary:tempDic];

        [_dataArr addObject:model];
    }

    [_MainTableView reloadData];
}


#pragma mark  ---  delegate   ---

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArr.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 120*SIZE;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    static NSString *CellIdentifier = @"PeopleCell";
    
    PeopleCell *cell  = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[PeopleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    RoomListModel *model = _dataArr[indexPath.row];
    [cell SetTitle:model.project_name image:model.img_url contentlab:model.absolute_address statu:model.sale_state];
    
    
    NSMutableArray *tempArr = [@[] mutableCopy];
    for (int i = 0; i < model.property_tags.count; i++) {
        
        [[self getDetailConfigArrByConfigState:PROPERTY_TYPE] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([obj[@"id"] integerValue] == [model.property_tags[i] integerValue]) {
                
                [tempArr addObject:obj[@"param"]];
                *stop = YES;
            }
        }];
    }
    
    NSArray *tempArr1 = [model.project_tags componentsSeparatedByString:@","];
    NSMutableArray *tempArr2 = [@[] mutableCopy];
    for (int i = 0; i < tempArr1.count; i++) {
        
        [[self getDetailConfigArrByConfigState:PROJECT_TAGS_DEFAULT] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([obj[@"id"] integerValue] == [tempArr1[i] integerValue]) {
                
                [tempArr2 addObject:obj[@"param"]];
                *stop = YES;
            }
        }];
    }
    NSArray *tempArr3 = @[tempArr,tempArr2.count == 0 ? @[]:tempArr2];
    [cell settagviewWithdata:tempArr3];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
    //    if (indexPath.row == 1) {
    //        static NSString *CellIdentifier = @"CompanyCell";
    //
    //        CompanyCell *cell  = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //        if (!cell) {
    //            cell = [[CompanyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    //        }
    //        //    [cell setTitle:_namelist[indexPath.row] content:@"123" img:@""];
    //        [cell SetTitle:@"新希望国际" image:@"" contentlab:@"高新区——天府三街" statu:@"在售"];
    //        [cell settagviewWithdata:_arr[indexPath.row]];
    //        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //        return cell;
    //    }else
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.applyProjectVCBlock) {
        
        RoomListModel *model = _dataArr[indexPath.row];
        self.applyProjectVCBlock(model.project_id, model.project_name);
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)initUI
{
    
    self.navBackgroundView.hidden = NO;
    self.titleLabel.text = @"选择项目";
    
    [self.view addSubview:self.MainTableView];
}

#pragma mark  ---  懒加载   ---
-(UITableView *)MainTableView
{
    if(!_MainTableView)
    {
        _MainTableView =   [[UITableView alloc]initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, 360*SIZE, SCREEN_Height - NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
        _MainTableView.backgroundColor = YJBackColor;
        _MainTableView.delegate = self;
        _MainTableView.dataSource = self;
        [_MainTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
//        _MainTableView.mj_header = [GZQGifHeader headerWithRefreshingBlock:^{
//            
////            _page = 1;
////            [self RequestMethod];
//        }];
//        
//        _MainTableView.mj_footer = [GZQGifFooter footerWithRefreshingBlock:^{
//            
////            [self RequestMethod];
//        }];
    }
    return _MainTableView;
}


@end
