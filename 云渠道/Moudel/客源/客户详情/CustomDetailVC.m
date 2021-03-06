//
//  CustomDetailVC.m
//  云渠道
//
//  Created by 谷治墙 on 2018/3/22.
//  Copyright © 2018年 xiaoq. All rights reserved.
//

#import "CustomDetailVC.h"
#import "CustomDetailTableCell.h"
#import "CustomDetailTableCell2.h"
#import "CustomDetailTableCell3.h"
#import "CustomDetailTableCell4.h"
#import "CustomDetailTableCell5.h"
#import "CustomTableHeader.h"
#import "CustomTableHeader2.h"
#import "CustomTableHeader3.h"
#import "CustomTableHeader4.h"
#import "AddRequireMentVC.h"
#import "FollowRecordVC.h"
#import "AddCustomerVC.h"
#import "RoomMatchListVC.h"
#import "QuickRoomVC.h"
#import "AddTagVC.h"
#import "RecommendedStatusVC.h"
#import "CustomSearchVC.h"
#import "CustomerVC.h"

@interface CustomDetailVC ()<UITableViewDelegate,UITableViewDataSource,CustomTableHeaderDelegate,CustomTableHeader2Delegate,CustomTableHeader3Delegate>
{
    NSArray *_arr;
    NSInteger _item;
    NSString *_clientId;
    
    CustomerModel *_customModel;//客户信息
    NSMutableArray *_dataArr;//需求信息
    NSMutableArray *_FollowArr;
    NSMutableArray *_projectArr;
    NSMutableArray *_statusArr;
    NSArray *_tagsArr;
    NSArray *_propertyArr;
    NSInteger _state;
    NSInteger _selected;
}
@property (nonatomic, strong) UITableView *customDetailTable;

@property (nonatomic, strong) SelectWorkerView *selectWorkerView;

@end

@implementation CustomDetailVC

- (instancetype)initWithClientId:(NSString *)clientId
{
    self = [super init];
    if (self) {
        
        _clientId = clientId;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    dispatch_queue_t queue1 = dispatch_queue_create("com.test.gcg.group", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, queue1, ^{
        
        [self RequestMethod];
        
    });
    dispatch_group_async(group, queue1, ^{
        
        [self GetFollowRequestMethod];
        
    });
    dispatch_group_async(group, queue1, ^{
        
        [self MatchRequest];
        
    });
    [self.navigationController setNavigationBarHidden:YES animated:YES]; //设置隐藏
}



- (void)ActionMaskBtn:(UIButton *)btn{
    
    for (UIViewController *vc in self.navigationController.viewControllers) {
        
        if ([vc isKindOfClass:[CustomSearchVC class]]) {
            
            [self.navigationController setNavigationBarHidden:NO animated:YES];
            [self.navigationController popToViewController:vc animated:YES];
        }else{
            
            if ([vc isKindOfClass:[CustomerVC class]]) {
                
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initDataSource];
    [self initUI];

}

- (void)initDataSource{
    
    _customModel = [[CustomerModel alloc] init];
    _dataArr = [@[] mutableCopy];
    _FollowArr = [@[] mutableCopy];
    _projectArr = [@[] mutableCopy];
    _statusArr = [@[] mutableCopy];
    _tagsArr = [self getDetailConfigArrByConfigState:PROJECT_TAGS_DEFAULT];
    _propertyArr = [self getDetailConfigArrByConfigState:PROPERTY_TYPE];
}

- (void)RecommendRequest:(NSDictionary *)dic projectName:(NSString *)projectName{
    
    [BaseRequest POST:RecommendClient_URL parameters:dic success:^(id resposeObject) {
        
        if ([resposeObject[@"code"] integerValue] == 200) {
            
            ReportCustomSuccessView *reportCustomSuccessView = [[ReportCustomSuccessView alloc] initWithFrame:self.view.frame];
            NSDictionary *tempDic = @{@"project":projectName,
                                      @"sex":self.model.sex,
                                      @"tel":self.model.tel,
                                      @"name":self.model.name
                                      };
            reportCustomSuccessView.state = _state;
            reportCustomSuccessView.dataDic = [NSMutableDictionary dictionaryWithDictionary:tempDic];
            reportCustomSuccessView.reportCustomSuccessViewBlock = ^{
                
                
            };
            [self.view addSubview:reportCustomSuccessView];
        }
        else{
            [self alertControllerWithNsstring:@"温馨提示" And:resposeObject[@"msg"]];
        }
    } failure:^(NSError *error) {
        
        [self showContent:@"网络错误"];
    }];
}


- (void)MatchRequest{
    
    [BaseRequest GET:ClientMatching_URL parameters:@{@"client_id":_clientId} success:^(id resposeObject) {
        
       
//        NSLog(@"%@",resposeObject);
    
        if ([resposeObject[@"code"] integerValue] == 200) {
            
            if ([resposeObject[@"data"] isKindOfClass:[NSDictionary class]]) {
                
                [self SetProjectList:resposeObject[@"data"][@"list"]];
                _statusArr = [NSMutableArray arrayWithArray:resposeObject[@"data"][@"recommend_project"]];
            }
        }
        else{
            [self showContent:resposeObject[@"msg"]];
        }
    } failure:^(NSError *error) {
        
//        NSLog(@"%@",error);
    }];
}

- (void)SetProjectList:(NSArray *)data{
    
    [_projectArr removeAllObjects];
    for (int i = 0; i < data.count; i++) {
        
        NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] initWithDictionary:data[i]];
        [tempDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
           
            if ([key isEqualToString:@"property_tags"]) {
                
                if (![obj isKindOfClass:[NSArray class]]) {
                    
                    [tempDic setObject:@[] forKey:key];
                }
            }else{
                
                if ([obj isKindOfClass:[NSNull class]]) {
                    
                    [tempDic setObject:@"" forKey:key];
                }
            }
        }];
        
        [_projectArr addObject:tempDic];
    }
    [_customDetailTable reloadData];
}

-(void)GetCustomRequestMethod
{
    
    [BaseRequest GET:GetStateList_URL parameters:@{@"client_id":[UserModelArchiver unarchive].agent_id} success:^(id resposeObject) {
        
//        NSLog(@"%@",resposeObject);
    } failure:^(NSError *error) {
        
//        NSLog(@"%@",error);
    }];

}

- (void)GetFollowRequestMethod{
    
    [BaseRequest GET:GetRecord_URL parameters:@{@"client_id":_clientId} success:^(id resposeObject) {
        
//        NSLog(@"%@",resposeObject);
      
        if ([resposeObject[@"code"] integerValue] == 200) {
            
            _FollowArr = [NSMutableArray arrayWithArray:resposeObject[@"data"][@"data"]];
            [_customDetailTable reloadData];
        }else{
            [self showContent:resposeObject[@"msg"]];
        }
    } failure:^(NSError *error) {
       
//        NSLog(@"%@",error);
        [self showContent:@"网络错误"];
    }];
}

- (void)RequestMethod{
    
    [BaseRequest GET:GetCliendInfo_URL parameters:@{@"client_id":_clientId} success:^(id resposeObject) {
        
//        NSLog(@"%@",resposeObject);
      
        if ([resposeObject[@"code"] integerValue] == 200) {
            
            if ([resposeObject[@"data"] isKindOfClass:[NSDictionary class]]) {
                
                if ([resposeObject[@"data"][@"basic"] isKindOfClass:[NSDictionary class]]) {
                    
                    [self setCustomModel:resposeObject[@"data"][@"basic"]];
                }
                if ([resposeObject[@"data"][@"need_info"] isKindOfClass:[NSArray class]]) {
                    
                    [self setData:resposeObject[@"data"][@"need_info"]];
                }
                [_customDetailTable reloadData];
            }else{
                
//                [self showContent:@"暂无客户信息"];
            }
        }        else{
            [self showContent:resposeObject[@"msg"]];
        }
    } failure:^(NSError *error) {
       
//        NSLog(@"%@",error);
        [self showContent:@"网络错误"];
    }];
}

- (void)setCustomModel:(NSDictionary *)dic{
    
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    [tempDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
       
        if ([obj isKindOfClass:[NSNull class]]) {
            
            [tempDic setObject:@"" forKey:key];
            
        }
        
    }];
    _customModel = [[CustomerModel alloc] initWithDictionary:tempDic];
}

- (void)setData:(NSArray *)data{
    
    [_dataArr removeAllObjects];
    for (int i = 0; i < data.count; i++) {
        if ([data[i] isKindOfClass:[NSDictionary class]]) {
            
            NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithDictionary:data[i]];
            [tempDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                
                if ([key isEqualToString:@"region"]) {
                    
                    if ([obj isKindOfClass:[NSArray class]]) {
                        
                        
                    }else{
                        
                        [tempDic setObject:@[] forKey:key];
                    }
                }else{
                    
                    if ([obj isKindOfClass:[NSNull class]]) {
                        
                        [tempDic setObject:@"" forKey:key];
                    }
                }
            }];
            
            CustomRequireModel *model = [[CustomRequireModel alloc] initWithDictionary:tempDic];
            [_dataArr addObject:model];
        }
    }
}


#pragma mark -- TableDelegate
- (void)head1collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    _item = indexPath.item;
    [_customDetailTable reloadData];
    if (_item == 1) {
        
        if (_FollowArr.count) {
            
            [_customDetailTable reloadData];
        }else{
            
            [self GetFollowRequestMethod];
        }
    }
    if (_item == 2) {
        
        if (_projectArr.count) {
            
            [_customDetailTable reloadData];
        }else{
            
            [self MatchRequest];
        }
    }
//    NSLog(@"%@",indexPath);
}

- (void)head2collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    _item = indexPath.item;
    [_customDetailTable reloadData];
    _item = indexPath.item;
    [_customDetailTable reloadData];
    if (_item == 1) {
        
        if (_FollowArr.count) {
            
            [_customDetailTable reloadData];
        }else{
            
            [self GetFollowRequestMethod];
        }
    }
    if (_item == 2) {
        
        if (_projectArr.count) {
            
            [_customDetailTable reloadData];
        }else{
            
            [self MatchRequest];
        }
    }
    
//    NSLog(@"%@",indexPath);
}

- (void)DGActionAddBtn:(UIButton *)btn{
    
    AddRequireMentVC *nextVC = [[AddRequireMentVC alloc] init];
    [self.navigationController pushViewController:nextVC animated:YES];
}

- (void)DG2ActionAddBtn:(UIButton *)btn{
    
    FollowRecordVC *nextVC = [[FollowRecordVC alloc] init];
    nextVC.customername = _customModel.name;
    nextVC.clint_id =_customModel.client_id;
    CustomRequireModel *model = _dataArr[0];
    nextVC.intent = model.intent;
    nextVC.urgency = model.urgency;

    [self.navigationController pushViewController:nextVC animated:YES];
}

- (void)DGActionEditBtn:(UIButton *)btn{
    
//    NSLog(@"%ld",_item);

    AddCustomerVC *nextVC = [[AddCustomerVC alloc] initWithModel:_customModel];
    [self.navigationController pushViewController:nextVC animated:YES];
}

- (void)ActionRightBtn:(UIButton *)btn{
    
    if (_dataArr.count) {
        QuickRoomVC  *nextVC = [[QuickRoomVC alloc] initWithModel:_dataArr[0]];
        nextVC.customerTableModel = self.model;
        [self.navigationController pushViewController:nextVC animated:YES];
    }
}


- (void)head3collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    _item = indexPath.item;
    [_customDetailTable reloadData];
    _item = indexPath.item;
    [_customDetailTable reloadData];
    if (_item == 1) {
        
        if (_FollowArr.count) {
            
            [_customDetailTable reloadData];
        }else{
            
            [self GetFollowRequestMethod];
        }
    }
    if (_item == 2) {
        
        if (_FollowArr.count) {
            
            [_customDetailTable reloadData];
        }else{
            
            [self MatchRequest];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    if (_item == 0) {
        
        return 3;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (_item == 0) {
        
        return _dataArr.count;
    }else if (_item == 1){
        
        return _FollowArr.count;
    }else{
        
        return _projectArr.count < 3? _projectArr.count : 3;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (!_item) {
        
        if (section == 0) {
            
            return 367 *SIZE;
        }else{
            
            if (section == 1) {
                
                return 5 *SIZE;
            }else{
                
                return 36 *SIZE;
            }
        }
    }else{
        
        if (_item == 1) {
            
            return 407 *SIZE;
        }else{

            return 435 *SIZE;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    return [[UIView alloc] init];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (!_item) {

        if (section == 0) {
            CustomTableHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"CustomTableHeader"];
            if (!header) {
                
                header = [[CustomTableHeader alloc] initWithFrame:CGRectMake(0, 0, SCREEN_Width, 368 *SIZE)];
                header.delegate = self;
                [header.headerColl selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
            }
            header.model = _customModel;
            
            return header;
        }else{
            
            if (section == 1) {
                
                return [[UIView alloc] init];
            }else{
                
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_Width, 36 *SIZE)];
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(28 *SIZE, 12 *SIZE, 100 *SIZE, 12 *SIZE)];
                label.textColor = YJContentLabColor;
                label.font = [UIFont systemFontOfSize:13 *SIZE];
                label.text = @"其他要求";
                [view addSubview:label];
                return view;
            }
        }
    }else{
        
        if (_item == 1) {
            
            CustomTableHeader2 *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"CustomTableHeader2"];
            if (!header) {
                
                header = [[CustomTableHeader2 alloc] initWithFrame:CGRectMake(0, 0, SCREEN_Width, 408 *SIZE)];
                header.delegate = self;
                [header.headerColl selectItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
            }

            header.model = _customModel;
            
            return header;
        }else{
            
            CustomTableHeader3 *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"CustomTableHeader3"];
            if (!header) {
                
                header = [[CustomTableHeader3 alloc] initWithFrame:CGRectMake(0, 0, SCREEN_Width, 485 *SIZE)];
                header.delegate = self;
                [header.headerColl selectItemAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
            }

            header.model = _customModel;
            
            header.numListL.text = [NSString stringWithFormat:@"匹配项目列表(%ld)",_projectArr.count];
            header.recommendListL.text = [NSString stringWithFormat:@"已推荐项目数(%ld)",_statusArr.count];
            if (_projectArr.count == 0) {
                
                header.moreBtn.hidden = YES;
            }else{
                
                header.moreBtn.hidden = NO;
            }
            header.moreBtnBlock = ^{
                
//                RoomMatchListVC *nextVC = [[RoomMatchListVC alloc] initWithClientId:_clientId];
                CustomRequireModel *model = _dataArr[0];
                RoomMatchListVC *nextVC = [[RoomMatchListVC alloc] initWithClientId:_clientId dataArr:_projectArr model:model];
                nextVC.customerTableModel = self.model;
                [self.navigationController pushViewController:nextVC animated:YES];
            };
            
            header.editBtnBlock = ^{
                
                AddCustomerVC *nextVC = [[AddCustomerVC alloc] initWithModel:_customModel];
                [self.navigationController pushViewController:nextVC animated:YES];
            };
            header.addBtnBlock = ^{
                
                QuickRoomVC  *nextVC = [[QuickRoomVC alloc] initWithModel:_dataArr[0]];
                [self.navigationController pushViewController:nextVC animated:YES];
            };
            header.statusBtnBlock = ^{
                
                RecommendedStatusVC *nextVC = [[RecommendedStatusVC alloc] initWithData:_statusArr];
                [self.navigationController pushViewController:nextVC animated:YES];
            };
            return header;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_item == 0) {
        
        if (indexPath.section == 0) {
            
            NSString * Identifier = @"CustomDetailTableCell";
            CustomDetailTableCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
            if (!cell) {
                
                cell = [[CustomDetailTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.editBlock = ^(NSInteger index) {
                
                
                AddRequireMentVC *nextVC = [[AddRequireMentVC alloc] initWithCustomRequireModel:_dataArr[index]];
                [self.navigationController pushViewController:nextVC animated:YES];
            };
            cell.model = _dataArr[indexPath.row];
            
            return cell;
        }else{
            
            if (indexPath.section == 1) {
                
                CustomDetailTableCell4 *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomDetailTableCell4"];
                if (!cell) {
                    
                    cell = [[CustomDetailTableCell4 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CustomDetailTableCell4"];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.addBtn.hidden = YES;
                [cell.tagView removeFromSuperview];

                CustomRequireModel *model = _dataArr[indexPath.row];
                NSArray *arr =  [model.need_tags componentsSeparatedByString:@","];
                UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
                layout.itemSize = CGSizeMake(77 *SIZE, 30 *SIZE);
                layout.minimumInteritemSpacing = 11 *SIZE;
                layout.sectionInset = UIEdgeInsetsMake(0, 28 *SIZE, 0, 0);
                layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

            
                NSMutableArray *tagArr1 = [[NSMutableArray alloc] init];
                for (int i = 0; i < arr.count; i++) {
                    [_tagsArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([obj[@"id"] integerValue] == [arr[i] integerValue]) {
                            [tagArr1 addObject:obj[@"param"]];
                            *stop = YES;
                        }
                    }];
                }
                cell.tagView = [[TagView2 alloc] initWithFrame:CGRectMake(0, 49 *SIZE, SCREEN_Width, 30 *SIZE) DataSouce:tagArr1 type:@"0" flowLayout:layout];
                [cell.contentView addSubview:cell.tagView];
                [cell.tagView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(cell.contentView).offset(0);
                    make.top.equalTo(cell.contentView).offset(49 *SIZE);
                    make.height.equalTo(@(30 *SIZE));
                    make.right.equalTo(cell.contentView).offset(0);
                    make.bottom.equalTo(cell.contentView).offset(-39 *SIZE);
                }];
                return cell;
            }else{
                CustomDetailTableCell5 *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomDetailTableCell5"];
                if (!cell) {
                    cell = [[CustomDetailTableCell5 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CustomDetailTableCell5"];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                CustomRequireModel *model = _dataArr[0];
                cell.contentL.text = model.comment;
                return cell;
            }
        }
    }else{
        
        if (_item == 1) {
            
            NSString * Identifier = @"CustomDetailTableCell2";
            CustomDetailTableCell2 *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
            if (!cell) {
                
                cell = [[CustomDetailTableCell2 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            NSArray *arr = [self getDetailConfigArrByConfigState:FOLLOW_TYPE];
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if ([_FollowArr[indexPath.row][@"follow_type"] integerValue] == [obj[@"id"] integerValue]) {
                    
                    cell.wayL.text = [NSString stringWithFormat:@"跟进方式:%@",obj[@"param"]];
                    *stop = YES;
                }
            }];
            
            cell.intentionL.text = [NSString stringWithFormat:@"购买意向度:%@",_FollowArr[indexPath.row][@"intent"]];
            cell.urgentL.text = [NSString stringWithFormat:@"购买紧迫度:%@",_FollowArr[indexPath.row][@"urgency"]];
            cell.contentL.text = _FollowArr[indexPath.row][@"comment"];
            cell.timeL.text = [NSString stringWithFormat:@"跟进时间:%@",_FollowArr[indexPath.row][@"follow_time"]];
            
            return cell;
        }else{
            
            NSString * Identifier = @"CustomDetailTableCell3";
            CustomDetailTableCell3 *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
            if (!cell) {
                
                cell = [[CustomDetailTableCell3 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.tag = indexPath.row;
            [cell setDataDic:_projectArr[indexPath.row]];
            
            NSMutableArray *tempArr = [@[] mutableCopy];
            for (int i = 0; i < [_projectArr[indexPath.row][@"property_tags"] count]; i++) {
                
                [_propertyArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    if ([obj[@"id"] integerValue] == [_projectArr[indexPath.row][@"property_tags"][i] integerValue]) {
                        
                        [tempArr addObject:obj[@"param"]];
                        *stop = YES;
                    }
                }];
            }
            
            NSArray *tempArr1 = [_projectArr[indexPath.row][@"project_tags"]  componentsSeparatedByString:@","];
            NSMutableArray *tempArr2 = [@[] mutableCopy];
            for (int i = 0; i < tempArr1.count; i++) {
                
                [_tagsArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    if ([obj[@"id"] integerValue] == [tempArr1[i] integerValue]) {
                        
                        [tempArr2 addObject:obj[@"param"]];
                        *stop = YES;
                    }
                }];
            }
            NSArray *tempArr3 = @[tempArr,tempArr2.count == 0 ? @[]:tempArr2];
            [cell settagviewWithdata:tempArr3];
            
            cell.recommendBtnBlock3 = ^(NSInteger index) {
                
                if (_dataArr.count) {
                    
                    self.selectWorkerView = [[SelectWorkerView alloc] initWithFrame:self.view.bounds];
                    SS(strongSelf);
                    WS(weakSelf);
                    CustomRequireModel *model = _dataArr[0];
                    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{@"project_id":_projectArr[index][@"project_id"],@"client_need_id":model.need_id,@"client_id":model.client_id}];
                    self.selectWorkerView.selectWorkerRecommendBlock = ^{
                        
                        if (weakSelf.selectWorkerView.nameL.text) {
                            
                            [dic setObject:weakSelf.selectWorkerView.ID forKey:@"consultant_advicer_id"];
                        }
                        
                        ReportCustomConfirmView *reportCustomConfirmView = [[ReportCustomConfirmView alloc] initWithFrame:weakSelf.view.frame];
                        NSDictionary *tempDic = @{@"project":strongSelf->_projectArr[index][@"project_name"],
                                                  @"sex":weakSelf.model.sex,
                                                  @"tel":weakSelf.model.tel,
                                                  @"name":weakSelf.model.name
                                                  };
                        reportCustomConfirmView.state = strongSelf->_state;
                        reportCustomConfirmView.dataDic = [NSMutableDictionary dictionaryWithDictionary:tempDic];
                        reportCustomConfirmView.reportCustomConfirmViewBlock = ^{
                            
                            [BaseRequest POST:RecommendClient_URL parameters:dic success:^(id resposeObject) {
                                
                                if ([resposeObject[@"code"] integerValue] == 200) {
                                    
                                    ReportCustomSuccessView *reportCustomSuccessView = [[ReportCustomSuccessView alloc] initWithFrame:weakSelf.view.frame];
                                    NSDictionary *tempDic = @{@"project":strongSelf->_projectArr[index][@"project_name"],
                                                              @"sex":weakSelf.model.sex,
                                                              @"tel":weakSelf.model.tel,
                                                              @"name":weakSelf.model.name
                                                              };
                                    reportCustomSuccessView.state = strongSelf->_state;
                                    reportCustomSuccessView.dataDic = [NSMutableDictionary dictionaryWithDictionary:tempDic];
                                    reportCustomSuccessView.reportCustomSuccessViewBlock = ^{
                                        
                                        
                                    };
                                    [weakSelf.view addSubview:reportCustomSuccessView];
                                }else{
                                    
                                    [weakSelf alertControllerWithNsstring:@"温馨提示" And:resposeObject[@"msg"]];
                                }
                            } failure:^(NSError *error) {
                                
                                [weakSelf showContent:@"网络错误"];
                            }];
                        };
                        [weakSelf.view addSubview:reportCustomConfirmView];
                    };
                    [BaseRequest GET:ProjectAdvicer_URL parameters:@{@"project_id":_projectArr[index][@"project_id"]} success:^(id resposeObject) {
                        
                        if ([resposeObject[@"code"] integerValue] == 200) {
                            
                            if ([resposeObject[@"data"][@"rows"] count]) {
                                weakSelf.selectWorkerView.dataArr = [NSMutableArray arrayWithArray:resposeObject[@"data"][@"rows"]];
                                _state = [resposeObject[@"data"][@"tel_complete_state"] integerValue];
                                _selected = [resposeObject[@"data"][@"advicer_selected"] integerValue];
                                weakSelf.selectWorkerView.advicerSelect = _selected;
                                [weakSelf.view addSubview:weakSelf.selectWorkerView];
                            }else{
                                
                                ReportCustomConfirmView *reportCustomConfirmView = [[ReportCustomConfirmView alloc] initWithFrame:weakSelf.view.frame];
                                NSDictionary *tempDic = @{@"project":_projectArr[index][@"project_name"],
                                                          @"sex":self.model.sex,
                                                          @"tel":self.model.tel,
                                                          @"name":self.model.name
                                                          };
                                reportCustomConfirmView.state = strongSelf->_state;
                                reportCustomConfirmView.dataDic = [NSMutableDictionary dictionaryWithDictionary:tempDic];
                                reportCustomConfirmView.reportCustomConfirmViewBlock = ^{
                                    
                                    [weakSelf RecommendRequest:dic projectName:_projectArr[index][@"project_name"]];
                                };
                                [weakSelf.view addSubview:reportCustomConfirmView];
                            }
                        }else{
                            
                            [self showContent:resposeObject[@"msg"]];
                        }
                    } failure:^(NSError *error) {
                        
                        [self showContent:@"网络错误"];
                    }];
                    
                }
            };
            
            return cell;
        }
    }
}


- (void)initUI{
    
    self.navBackgroundView.hidden = NO;
    self.titleLabel.text = @"客户详情";

    self.rightBtn.hidden = NO;
    [self.rightBtn setImage:[UIImage imageNamed:@"add_3"] forState:UIControlStateNormal];
    [self.rightBtn addTarget:self action:@selector(ActionRightBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    
    _customDetailTable = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, SCREEN_Width, SCREEN_Height - NAVIGATION_BAR_HEIGHT - TAB_BAR_MORE) style:UITableViewStyleGrouped];
    _customDetailTable.estimatedRowHeight = 367 *SIZE;
    _customDetailTable.rowHeight = UITableViewAutomaticDimension;
    _customDetailTable.backgroundColor = YJBackColor;
    _customDetailTable.delegate = self;
    _customDetailTable.dataSource = self;
    _customDetailTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_customDetailTable];
}


@end
