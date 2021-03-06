//
//  RoomProjectVC.m
//  云渠道
//
//  Created by 谷治墙 on 2018/4/17.
//  Copyright © 2018年 xiaoq. All rights reserved.
//

#import "RoomProjectVC.h"
#import "BuildingAlbumVC.h"
#import "BuildingInfoVC.h"
#import "HouseTypeDetailVC.h"
#import "DynamicListVC.h"
#import "CustomMatchListVC.h"
#import "DistributVC.h"
#import "DynamicDetailVC.h"
#import "CustomListVC.h"

#import "RoomDetailTableHeader.h"
#import "RoomDetailTableHeader5.h"
#import "RoomDetailTableHeader6.h"
#import "RoomDetailTableCell.h"
#import "RoomDetailTableCell1.h"
#import "RoomDetailTableCell2.h"
#import "RoomDetailTableCell3.h"
#import "RoomDetailTableCell4.h"
#import "RoomDetailTableCell5.h"

#import "CustomMatchModel.h"
#import "RoomDetailModel.h"


#import "YBImageBrowser.h"

#import <BaiduMapAPI_Search/BMKPoiSearchType.h>
#import <BaiduMapAPI_Search/BMKPoiSearchOption.h>
#import <BaiduMapAPI_Search/BMKPoiSearch.h>

@interface RoomProjectVC ()<UITableViewDelegate,UITableViewDataSource,BMKMapViewDelegate,RoomDetailTableCell4Delegate,BMKPoiSearchDelegate,UIGestureRecognizerDelegate,YBImageBrowserDelegate>
{
    CLLocationCoordinate2D _leftBottomPoint;
    CLLocationCoordinate2D _rightBottomPoint;//地图矩形的顶点
    NSMutableDictionary *_dynamicDic;
    NSString *_projectId;
    RoomDetailModel *_model;
    NSMutableDictionary *_focusDic;
    NSString *_dynamicNum;
    NSMutableArray *_imgArr;
    NSMutableArray *_albumArr;
    NSString *_focusId;
    NSMutableArray *_houseArr;
    NSMutableArray *_peopleArr;
    NSMutableDictionary *_buildDic;
    NSString *_phone;
    NSString *_phone_url;
    NSString *_name;
    NSInteger _state;
    NSInteger _selected;
}
@property (nonatomic, strong) SelectWorkerView *selectWorkerView;

@property (nonatomic, strong) UITableView *roomTable;

@property (nonatomic, strong) UIButton *recommendBtn;

@property (nonatomic, strong) UIView *parting;

@property (nonatomic, strong) UIButton *counselBtn;

@property (nonatomic, strong) BMKMapView *mapView;

@property (nonatomic, strong) BMKPoiSearch *poisearch;

@end

@implementation RoomProjectVC

- (instancetype)initWithProjectId:(NSString *)projectId
{
    self = [super init];
    if (self) {
        
        _projectId = projectId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initDataSource];
    [self initUI];
}

- (void)MapViewDismissNoti:(NSNotification *)noti{
    
    self.mapView.delegate = nil;
    [self.mapView removeFromSuperview];
}


- (void)initDataSource{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MapViewDismissNoti:) name:@"mapViewDismiss" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MatchRequest) name:@"matchReload" object:nil];
    
    _dynamicNum = @"";
    _imgArr = [@[] mutableCopy];
    _albumArr = [@[] mutableCopy];
    _focusDic = [@{} mutableCopy];
    _dynamicDic = [@{} mutableCopy];
    _model = [[RoomDetailModel alloc] init];
    _houseArr = [@[] mutableCopy];
    _peopleArr = [@[] mutableCopy];
    _buildDic = [@{} mutableCopy];
    
    dispatch_queue_t queue1 = dispatch_queue_create("com.test.gcg.group", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, queue1, ^{

        [self RequestMethod];
        
    });
    dispatch_group_async(group, queue1, ^{
        
        [self MatchRequest];
        
    });
    
    dispatch_group_async(group, queue1, ^{
        
        [self ImgRequest];
        
    });
    
}

- (void)MatchRequest{
    
    [BaseRequest GET:ProjectMatching_URL parameters:@{@"project_id":_projectId} success:^(id resposeObject) {
        
//        NSLog(@"%@",resposeObject);
        if ([resposeObject[@"code"] integerValue] == 200) {
            
            [self SetMatchPeople:resposeObject[@"data"]];
        }
    } failure:^(NSError *error) {
        
//        NSLog(@"%@",error);
        [self showContent:@"网络错误"];
    }];
}

- (void)SetMatchPeople:(NSArray *)data{
    
    [_peopleArr removeAllObjects];
    for (int i = 0 ; i < data.count; i++) {
        
        NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] initWithDictionary:data[i]];
        
        [tempDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
           
            if ([obj isKindOfClass:[NSNull class]]) {
                
                [tempDic setObject:@"" forKey:key];
            }
        }];
        
        CustomMatchModel *model = [[CustomMatchModel alloc] initWithDictionary:tempDic];
        [_peopleArr addObject:model];
    }
    [_roomTable reloadData];
}

- (void)ImgRequest{
    
    [BaseRequest GET:GetImg_URL parameters:@{@"project_id":_projectId} success:^(id resposeObject) {
        
        if ([resposeObject[@"code"] integerValue] == 200) {
            
            if (![resposeObject[@"data"] isKindOfClass:[NSNull class]]) {
                
                [self SetImg:resposeObject[@"data"]];
            }else{
                
            }
        }
    } failure:^(NSError *error) {
        
        NSLog(@"%@",error);
    }];
}

- (void)SetImg:(NSArray *)data{
    
    [_albumArr removeAllObjects];
    for ( int i = 0; i < data.count; i++) {
        
        if ([data[i] isKindOfClass:[NSDictionary class]]) {
            
            NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] initWithDictionary:data[i]];
            
            [_albumArr addObject:tempDic];
        }
    }
}

- (void)RequestMethod{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:_projectId forKey:@"project_id"];
     [dic setObject:[UserModelArchiver unarchive].agent_id forKey:@"agent_id"];
//    [dic setObject:@"1" forKey:@"agent_id"];
    [BaseRequest GET:ProjectDetail_URL parameters:dic success:^(id resposeObject) {
//        NSLog(@"%@",resposeObject);
        if ([resposeObject[@"code"] integerValue] == 200) {
            
            if ([resposeObject[@"data"] isKindOfClass:[NSDictionary class]]) {
                
                [self SetData:resposeObject[@"data"]];
                
            }else{
                
                [self showContent:@"暂时没有数据"];
            }
        }
    } failure:^(NSError *error) {
       
//        NSLog(@"%@",error);
        [self showContent:@"网络错误"];
    }];
}

- (void)SetData:(NSDictionary *)data{
    if (data[@"total_float_url_phone"]) {
        _phone_url =  [NSString stringWithFormat:@"%@",data[@"total_float_url_phone"]];
    }
    
    if (data[@"butter_tel"]) {
        
        _phone = [NSString stringWithFormat:@"%@",data[@"butter_tel"]];
    }
    
    if ([data[@"build_info"] isKindOfClass:[NSDictionary class]]) {
        
        _buildDic = [NSMutableDictionary dictionaryWithDictionary:data[@"build_info"]];
    }
    
    if ([data[@"dynamic"] isKindOfClass:[NSDictionary class]]) {
        
        if (![data[@"dynamic"][@"count"] isKindOfClass:[NSNull class]]) {
            
            _dynamicNum = data[@"dynamic"][@"count"];
        }
        
        if ([data[@"dynamic"][@"first"] isKindOfClass:[NSDictionary class]]) {
            
            _dynamicDic = [[NSMutableDictionary alloc] initWithDictionary:data[@"dynamic"][@"first"]];
            [_dynamicDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
               
                if ([obj isKindOfClass:[NSNull class]]) {
                    
                    [_dynamicDic setObject:@"" forKey:key];
                }
            }];
        }
    }
    
    if ([data[@"focus"] isKindOfClass:[NSDictionary class]]) {
        
        _focusDic = [NSMutableDictionary dictionaryWithDictionary:data[@"focus"]];
    }
    
    if ([data[@"house_type"] isKindOfClass:[NSArray class]]) {
        
        _houseArr = [NSMutableArray arrayWithArray:data[@"house_type"]];
    }
    
    if ([data[@"project_basic_info"] isKindOfClass:[NSDictionary class]]) {
        
        NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] initWithDictionary:data[@"project_basic_info"]];
        [tempDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            
            if ([obj isKindOfClass:[NSNull class]]) {
                
                [tempDic setObject:@"" forKey:key];
            }
        }];
        _model = [[RoomDetailModel alloc] initWithDictionary:tempDic];
    }
    
    if ([data[@"project_img"] isKindOfClass:[NSDictionary class]]) {
        
        if ([data[@"project_img"][@"url"] isKindOfClass:[NSArray class]]) {
            
            _imgArr = [[NSMutableArray alloc] initWithArray:data[@"project_img"][@"url"]];
            
            [_imgArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    
                    if ([obj[@"img_url"] isKindOfClass:[NSNull class]]) {
                        
                        [_imgArr replaceObjectAtIndex:idx withObject:@{@"img_url":@""}];
                    }
                }else{
                    
                    [_imgArr replaceObjectAtIndex:idx withObject:@{@"img_url":@""}];
                }
            }];
        }
    }

    
    [_roomTable reloadData];
}


#pragma mark -- Method --

- (void)RequestRecommend:(NSDictionary *)dic model:(CustomMatchModel *)model{
    
    [BaseRequest POST:RecommendClient_URL parameters:dic success:^(id resposeObject) {
        
        NSLog(@"%@",resposeObject);
        
        if ([resposeObject[@"code"] integerValue] == 200) {
            
            ReportCustomSuccessView *reportCustomSuccessView = [[ReportCustomSuccessView alloc] initWithFrame:self.view.frame];
            NSDictionary *tempDic = @{@"project":_model.project_name,
                                      @"sex":model.sex,
                                      @"tel":model.tel,
                                      @"name":model.name
                                      };
            reportCustomSuccessView.state = _state;
            reportCustomSuccessView.dataDic = [NSMutableDictionary dictionaryWithDictionary:tempDic];
            reportCustomSuccessView.reportCustomSuccessViewBlock = ^{
                
                [self MatchRequest];
            };
            [self.view addSubview:reportCustomSuccessView];
        }else if ([resposeObject[@"code"] integerValue] == 401){
            
            [self alertControllerWithNsstring:@"温馨提示" And:resposeObject[@"msg"]];
        }
        else{
            
            [self alertControllerWithNsstring:@"温馨提示" And:resposeObject[@"msg"]];
        }
    } failure:^(NSError *error) {
        
        NSLog(@"%@",error);
        [self showContent:@"网络错误"];
    }];
}

- (void)ActionMoreBtn:(UIButton *)btn{
    
//    NSLog(@"%ld",btn.tag);
    if (btn.tag == 1) {
        BuildingInfoVC *next_vc = [[BuildingInfoVC alloc]initWithProjectId:_projectId];
        [self.navigationController pushViewController:next_vc animated:YES];
    }
    
    if (btn.tag == 2) {
        
        DynamicListVC *next_vc = [[DynamicListVC alloc]initWithProjectId:_projectId];
        [self.navigationController pushViewController:next_vc animated:YES];
    }
    
}

- (void)ActionRecommendBtn:(UIButton *)btn{
    
    CustomListVC *nextVC = [[CustomListVC alloc] initWithProjectId:_projectId];
    nextVC.model = _model;
    [self.navigationController pushViewController:nextVC animated:YES];
}

- (void)ActionCounselBtn:(UIButton *)btn{
    
    if (_phone.length) {
        
        //获取目标号码字符串,转换成URL
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",_phone]];
        //调用系统方法拨号
        [[UIApplication sharedApplication] openURL:url];
    }else{
        
        [self alertControllerWithNsstring:@"温馨提示" And:@"暂时未获取到联系电话"];
    }
}

#pragma mark -- BMKMap

- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation{
    
    
}


#pragma mark -- delegate

- (void)Cell4collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSArray * namearr = @[@"教育",@"公交站点",@"医院",@"购物",@"餐饮"];
    [self beginSearchWithname:namearr[indexPath.row]];
}


#pragma mark -- tableview

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 7;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 6) {
        
        return _peopleArr.count > 2? 2:_peopleArr.count;
    }else{
        
        if (section == 0 || section == 1) {
            
            return 0;
        }else{
            
            if (section == 2) {
                
                if (_dynamicDic.count) {
                    
                    return 1;
                }else{
                    
                    return 0;
                }
            }else{
                
                return 1;
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (!section) {
        
        return 368 *SIZE;
    }else{
        
        if (section == 6) {
            
            return 33 *SIZE;
        }else{
            
            return 6 *SIZE;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (!section) {
        
        RoomDetailTableHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"RoomDetailTableHeader"];
        if (!header) {
            
            header = [[RoomDetailTableHeader alloc] initWithFrame:CGRectMake(0, 0, SCREEN_Width, 383 *SIZE)];
        }
        
        header.model = _model;
        header.imgArr = _imgArr;
        header.moreBtn.tag = 1;
        [header.moreBtn addTarget:self action:@selector(ActionMoreBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        if (_focusDic.count) {
            
            header.attentL.text = [NSString stringWithFormat:@"关注人数:%@",_focusDic[@"num"]];
            if ([_focusDic[@"is_focus"] integerValue]) {
                
                [header.attentBtn setImage:[UIImage imageNamed:@"Focus_selected"] forState:UIControlStateNormal];
            }else{
                
                [header.attentBtn setImage:[UIImage imageNamed:@"Focus"] forState:UIControlStateNormal];
            }
        }else{
            
            [header.attentBtn setImage:[UIImage imageNamed:@"Focus"] forState:UIControlStateNormal];
        }
        header.imgBtnBlock = ^(NSInteger num, NSArray *imgArr) {
            
            NSMutableArray *tempArr = [NSMutableArray array];
            [imgArr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {

                YBImageBrowserModel *model = [YBImageBrowserModel new];
                model.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",TestBase_Net,obj[@"img_url"]]];
                [tempArr addObject:model];
            }];
            if (_albumArr.count) {
//
//                NSMutableArray *tempArr = [NSMutableArray array];
//                for (int i = 0; i < _albumArr.count; i++) {
//
//                    NSArray *arr = _albumArr[i][@"data"];
//                    for (int j = 0; j < arr.count; j++) {
//
//                        YBImageBrowserModel *model = [YBImageBrowserModel new];
//                        model.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",TestBase_Net,arr[j][@"img_url"]]];
//                        [tempArr addObject:model];
//                    }
//                }
            
//                [_albumArr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//
//                    YBImageBrowserModel *model = [YBImageBrowserModel new];
//                    model.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",TestBase_Net,obj[@"img_url"]]];
//                    [tempArr addObject:model];
//                }];
                
                YBImageBrowser *browser = [YBImageBrowser new];
                browser.delegate = self;
                browser.dataArray = tempArr;
                browser.albumArr = _albumArr;
                browser.projectId = _projectId;
                browser.currentIndex = num;
                [browser show];
            }else{
                
                [BaseRequest GET:GetImg_URL parameters:@{@"project_id":_projectId} success:^(id resposeObject) {
                    
                    if ([resposeObject[@"code"] integerValue] == 200) {
                        
                        if (![resposeObject[@"data"] isKindOfClass:[NSNull class]]) {
                            
                            [_albumArr removeAllObjects];
                            for ( int i = 0; i < [resposeObject[@"data"] count]; i++) {
                                
                                if ([resposeObject[@"data"][i] isKindOfClass:[NSDictionary class]]) {
                                    
                                    NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] initWithDictionary:resposeObject[@"data"][i]];
                                    
                                    [_albumArr addObject:tempDic];
                                    
//                                    NSMutableArray *tempArr = [NSMutableArray array];
//                                    for (int i = 0; i < _albumArr.count; i++) {
//
//                                        NSArray *arr = _albumArr[i][@"data"];
//                                        for (int j = 0; j < arr.count; j++) {
//
//                                            YBImageBrowserModel *model = [YBImageBrowserModel new];
//                                            model.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",TestBase_Net,arr[j][@"img_url"]]];
//                                            [tempArr addObject:model];
//                                        }
//                                    }
                                    
                                    YBImageBrowser *browser = [YBImageBrowser new];
                                    browser.delegate = self;
                                    browser.albumArr = _albumArr;
                                    browser.dataArray = tempArr;
                                    browser.projectId = _projectId;
                                    browser.currentIndex = num;
                                    [browser show];
                                }
                            }
                        }else{
                            
                        }
                    }
                } failure:^(NSError *error) {
                    
                    NSLog(@"%@",error);
                }];
            }
        };
        
        header.attentBtnBlock = ^{
            
            if (_focusDic.count) {
                
                if ([_focusDic[@"is_focus"] integerValue]) {
                    
                    [BaseRequest GET:CancelFocusProject_URL parameters:@{@"project_id":_model.project_id} success:^(id resposeObject) {
                        
                       
                        NSLog(@"%@",resposeObject);
                        if ([resposeObject[@"code"] integerValue] == 200) {
                            
                            [self RequestMethod];
                        }else if([resposeObject[@"code"] integerValue] == 400){
                            
                        }
                        else{
                            [self showContent:resposeObject[@"msg"]];
                        }
                    } failure:^(NSError *error) {
                        
                        NSLog(@"%@",error);
                        [self showContent:@"网络错误"];
                    }];
                }else{
                    
                    [BaseRequest GET:FocusProject_URL parameters:@{@"project_id":_model.project_id} success:^(id resposeObject) {
                        
                        NSLog(@"%@",resposeObject);
                       
                        if ([resposeObject[@"code"] integerValue] == 200) {
                            
                            [self RequestMethod];
                        }else if([resposeObject[@"code"] integerValue] == 400){
                            
                        }
                        else{
                            [self showContent:resposeObject[@"msg"]];
                        }
                        [self RequestMethod];
                    } failure:^(NSError *error) {
                        
                        NSLog(@"%@",error);
                        [self showContent:@"网络错误"];
                    }];
                }
            }
        };

        return header;
        
    }else{
        
        if (section == 6) {
              
            RoomDetailTableHeader5 *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"RoomDetailTableHeader5"];
            if (!header) {
                  
                header = [[RoomDetailTableHeader5 alloc] initWithFrame:CGRectMake(0, 0, SCREEN_Width, 383 *SIZE)];
            }
            header.numL.text = [NSString stringWithFormat:@"匹配的客户(%ld)",_peopleArr.count];
            if (_peopleArr.count == 0) {
                
                header.moreBtn.hidden = YES;
            }else{
                
                header.moreBtn.hidden = NO;
            }
            header.moreBtnBlock = ^{
                  
                CustomMatchListVC *nextVC = [[CustomMatchListVC alloc] initWithDataArr:_peopleArr projectId:_projectId];
                nextVC.model = _model;
                [self.navigationController pushViewController:nextVC animated:YES];
            };
            return header;
        }else{
              
            return [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_Width, 6 *SIZE)];
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    return [[UIView alloc] init];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.section) {
        case 0:
        case 1:
        case 2:
        {

            RoomDetailTableCell1 *cell = [tableView dequeueReusableCellWithIdentifier:@"RoomDetailTableCell1"];
            if (!cell) {

                cell = [[RoomDetailTableCell1 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RoomDetailTableCell1"];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            if (_dynamicDic) {
                
                cell.numL.text = [NSString stringWithFormat: @"（共%@条）",_dynamicNum];
                cell.titleL.text = _dynamicDic[@"title"];
                cell.timeL.text = _dynamicDic[@"update_time"];
                cell.contentL.text = _dynamicDic[@"abstract"];
            }
            
            cell.moreBtn.tag = indexPath.section;
            [cell.moreBtn addTarget:self action:@selector(ActionMoreBtn:) forControlEvents:UIControlEventTouchUpInside];
            return cell;
            break;
        }
        case 3:
        {

            RoomDetailTableCell2 *cell = [tableView dequeueReusableCellWithIdentifier:@"RoomDetailTableCell2"];
            if (!cell) {

                cell = [[RoomDetailTableCell2 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RoomDetailTableCell2"];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.bigImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",TestBase_Net,_model.total_float_url]] placeholderImage:[UIImage imageNamed:@"banner_default_2"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
               
                if (error) {
                    
                    [UIImage imageNamed:@"banner_default_2"];
                }
            }];
            
            return cell;
            break;
        }
        case 4:
        {

            RoomDetailTableCell3 *cell = [tableView dequeueReusableCellWithIdentifier:@"RoomDetailTableCell3"];
            if (!cell) {
                cell = [[RoomDetailTableCell3 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RoomDetailTableCell3"];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if (_houseArr.count) {
                
               cell.num = _houseArr.count;
            }else{
                
                cell.num = 3;
            }
            if (_houseArr.count) {
                
                cell.dataArr = [NSMutableArray arrayWithArray:_houseArr];
                [cell.cellColl reloadData];
            }else{
                
                [cell.cellColl reloadData];
            }
            
            cell.collCellBlock = ^(NSInteger index) {

                if (_houseArr.count) {
                    
                    HouseTypeDetailVC *nextVC = [[HouseTypeDetailVC alloc] initWithHouseTypeId:[NSString stringWithFormat:@"%@",_houseArr[index][@"id"]] index:index dataArr:_houseArr projectId:_projectId];
                    nextVC.model = _model;
                    [self.navigationController pushViewController:nextVC animated:YES];
                }
            };

            return cell;
            break;
        }
        case 5:
        {

            RoomDetailTableCell4 *cell = [tableView dequeueReusableCellWithIdentifier:@"RoomDetailTableCell4"];
            if (!cell) {

                cell = [[RoomDetailTableCell4 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RoomDetailTableCell4"];
                cell.delegate = self;
                [cell.contentView addSubview:self.mapView];
                UIGestureRecognizer *gestur = [[UIGestureRecognizer alloc]init];
                gestur.delegate=self;
                [_roomTable addGestureRecognizer:gestur];
                
                UIGestureRecognizer *gestur1 = [[UIGestureRecognizer alloc]init];
                gestur1.delegate=self;
                [_mapView addGestureRecognizer:gestur1];
                
                
                [_mapView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(cell.contentView).offset(0);
                    make.top.equalTo(cell.contentView).offset(33 *SIZE);
                    make.right.equalTo(cell.contentView).offset(0);
                    make.width.equalTo(@(360 *SIZE));
                    make.height.equalTo(@(187 *SIZE));
                    make.bottom.equalTo(cell.contentView).offset(-59 *SIZE);
                }];
            }
            CLLocationCoordinate2D cllocation = CLLocationCoordinate2DMake([_model.latitude floatValue] , [_model.longitude floatValue]);
            [_mapView setCenterCoordinate:cllocation animated:YES];
            BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
            annotation.coordinate = cllocation;
            annotation.title = _model.project_name;
            [_mapView addAnnotation:annotation];
            cell.delegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            return cell;
            break;
        }

        case 6:
        {


            RoomDetailTableCell5 *cell = [tableView dequeueReusableCellWithIdentifier:@"RoomDetailTableCell5"];
            if (!cell) {

                cell = [[RoomDetailTableCell5 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RoomDetailTableCell5"];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.model = _peopleArr[indexPath.row];
            cell.recommendBtn.tag = indexPath.row;
            cell.recommendBtnBlock5 = ^(NSInteger index) {
                
                CustomMatchModel *model = _peopleArr[index];
                self.selectWorkerView = [[SelectWorkerView alloc] initWithFrame:self.view.bounds];
                SS(strongSelf);
                WS(weakSelf);
                self.selectWorkerView.selectWorkerRecommendBlock = ^{
                    
                    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{@"project_id":strongSelf->_projectId,@"client_need_id":model.need_id,@"client_id":model.client_id}];
                    if (weakSelf.selectWorkerView.nameL.text) {
                        
                        [dic setObject:weakSelf.selectWorkerView.ID forKey:@"consultant_advicer_id"];
                    }
                    
                    ReportCustomConfirmView *reportCustomConfirmView = [[ReportCustomConfirmView alloc] initWithFrame:weakSelf.view.frame];
                    NSDictionary *tempDic = @{@"project":strongSelf->_model.project_name,
                                              @"sex":model.sex,
                                              @"tel":model.tel,
                                              @"name":model.name
                                              };
                    reportCustomConfirmView.state = strongSelf->_state;
                    reportCustomConfirmView.dataDic = [NSMutableDictionary dictionaryWithDictionary:tempDic];
                    reportCustomConfirmView.reportCustomConfirmViewBlock = ^{
                        
                        [BaseRequest POST:RecommendClient_URL parameters:dic success:^(id resposeObject) {
                            
                            NSLog(@"%@",resposeObject);
                            
                            if ([resposeObject[@"code"] integerValue] == 200) {
                                
                                ReportCustomSuccessView *reportCustomSuccessView = [[ReportCustomSuccessView alloc] initWithFrame:weakSelf.view.frame];
                                NSDictionary *tempDic = @{@"project":strongSelf->_model.project_name,
                                                          @"sex":model.sex,
                                                          @"tel":model.tel,
                                                          @"name":model.name
                                                          };
                                reportCustomSuccessView.state = strongSelf->_state;
                                reportCustomSuccessView.dataDic = [NSMutableDictionary dictionaryWithDictionary:tempDic];
                                reportCustomSuccessView.reportCustomSuccessViewBlock = ^{
                                    
                                    [weakSelf MatchRequest];
                                };
                                [weakSelf.view addSubview:reportCustomSuccessView];
                            }else if ([resposeObject[@"code"] integerValue] == 401){
                                
                                [weakSelf alertControllerWithNsstring:@"温馨提示" And:resposeObject[@"msg"]];
                            }
                            else{
                                
                                [weakSelf alertControllerWithNsstring:@"温馨提示" And:resposeObject[@"msg"]];
                            }
                        } failure:^(NSError *error) {
                            
                            NSLog(@"%@",error);
                            [weakSelf showContent:@"网络错误"];
                        }];
                    };
                    [weakSelf.view addSubview:reportCustomConfirmView];
                };
                [BaseRequest GET:ProjectAdvicer_URL parameters:@{@"project_id":strongSelf->_model.project_id} success:^(id resposeObject) {
                    
                    if ([resposeObject[@"code"] integerValue] == 200) {
                        
                        if ([resposeObject[@"data"][@"rows"] count]) {
                            
                            weakSelf.selectWorkerView.dataArr = [NSMutableArray arrayWithArray:resposeObject[@"data"][@"rows"]];
                            _state = [resposeObject[@"data"][@"tel_complete_state"] integerValue];
                            _selected = [resposeObject[@"data"][@"advicer_selected"] integerValue];
                            weakSelf.selectWorkerView.advicerSelect = _selected;
                            [self.view addSubview:weakSelf.selectWorkerView];
                        }else{
                            
                            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{@"project_id":strongSelf->_projectId,@"client_need_id":model.need_id,@"client_id":model.client_id}];
                            
                            ReportCustomConfirmView *reportCustomConfirmView = [[ReportCustomConfirmView alloc] initWithFrame:weakSelf.view.frame];
                            NSDictionary *tempDic = @{@"project":_model.project_name,
                                                      @"sex":model.sex,
                                                      @"tel":model.tel,
                                                      @"name":model.name
                                                      };
                            reportCustomConfirmView.state = strongSelf->_state;
                            reportCustomConfirmView.dataDic = [NSMutableDictionary dictionaryWithDictionary:tempDic];
                            reportCustomConfirmView.reportCustomConfirmViewBlock = ^{
                                
                                [weakSelf RequestRecommend:dic model:model];
                            };
                            [weakSelf.view addSubview:reportCustomConfirmView];
                        }
                    }else{
                        
                        [self showContent:resposeObject[@"msg"]];
                    }
                } failure:^(NSError *error) {
                    
                    [self showContent:@"网络错误"];
                }];
            };
            return cell;
            break;
        }
        default:{
            RoomDetailTableCell5 *cell = [tableView dequeueReusableCellWithIdentifier:@"RoomDetailTableCell5"];
            if (!cell) {

                cell = [[RoomDetailTableCell5 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RoomDetailTableCell5"];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            break;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 3) {
        
        DistributVC *nextVC = [[DistributVC alloc] init];
        nextVC.urlfor3d = _model.total_float_url_panorama;
        nextVC.img_name = _model.total_float_url_phone;
        nextVC.projiect_id = _projectId;
        [self.navigationController pushViewController:nextVC animated:YES];
    }
    if (indexPath.section == 2) {
        
        DynamicDetailVC *nextVC = [[DynamicDetailVC alloc] initWithStr:_dynamicDic[@"url"] titleStr:@"动态详情"];
        [self.navigationController pushViewController:nextVC animated:YES];
    }
}


-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    if ([gestureRecognizer.view isKindOfClass:[BMKMapView class]]) {
        _roomTable.scrollEnabled=NO;
        
    }else{
        _roomTable.scrollEnabled=YES;

    }
    
    return NO;
}


- (void)initUI{
    

    _roomTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_Width, self.view.frame.size.height - NAVIGATION_BAR_HEIGHT - 47 *SIZE - TAB_BAR_MORE) style:UITableViewStyleGrouped];
    _roomTable.rowHeight = UITableViewAutomaticDimension;
    _roomTable.estimatedRowHeight = 360 *SIZE;
    _roomTable.backgroundColor = self.view.backgroundColor;
    _roomTable.delegate = self;
    _roomTable.dataSource = self;
    _roomTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_roomTable];
    
    _counselBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _counselBtn.frame = CGRectMake(0, self.view.frame.size.height - NAVIGATION_BAR_HEIGHT - 47 *SIZE - TAB_BAR_MORE, 119 *SIZE, 47 *SIZE + TAB_BAR_MORE);
    _counselBtn.titleLabel.font = [UIFont systemFontOfSize:14 *sIZE];
    [_counselBtn addTarget:self action:@selector(ActionCounselBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_counselBtn setTitle:@"电话咨询" forState:UIControlStateNormal];
    [_counselBtn setBackgroundColor:COLOR(255, 188, 88, 1)];
    [_counselBtn setTitleColor:CH_COLOR_white forState:UIControlStateNormal];
    if ([[UserModel defaultModel].agent_identity integerValue] == 2) {
        _counselBtn.frame = CGRectMake(0, self.view.frame.size.height - NAVIGATION_BAR_HEIGHT - 47 *SIZE - TAB_BAR_MORE, SCREEN_Width, 47 *SIZE + TAB_BAR_MORE);
    }
    [self.view addSubview:_counselBtn];

    _recommendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _recommendBtn.frame = CGRectMake(120 *SIZE, self.view.frame.size.height - NAVIGATION_BAR_HEIGHT - 47 *SIZE - TAB_BAR_MORE, 240 *SIZE, 47 *SIZE + TAB_BAR_MORE);
    _recommendBtn.titleLabel.font = [UIFont systemFontOfSize:14 *sIZE];
    [_recommendBtn addTarget:self action:@selector(ActionRecommendBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_recommendBtn setTitle:@"快速推荐" forState:UIControlStateNormal];
    [_recommendBtn setBackgroundColor:YJBlueBtnColor];
    if ([[UserModel defaultModel].agent_identity integerValue] == 1) {
        
        [self.view addSubview:_recommendBtn];
    }
    
}


- (BMKMapView *)mapView{
    
    if (!_mapView) {
        
        _mapView = [[BMKMapView alloc] init];
        _mapView.delegate = self;
        _mapView.zoomLevel = 15;
        _mapView.isSelectedAnnotationViewFront = YES;
    }
    return _mapView;
}

- (void)mapViewDidFinishLoading:(BMKMapView *)mapView
{
    _leftBottomPoint = [_mapView convertPoint:CGPointMake(0,_mapView.frame.size.height) toCoordinateFromView:mapView];  // //西南角（左下角） 屏幕坐标转地理经纬度
    _rightBottomPoint = [_mapView convertPoint:CGPointMake(_mapView.frame.size.width,0) toCoordinateFromView:mapView];  //东北角（右上角）同上
    //开始搜索
}

- (void)beginSearchWithname:(NSString *)name{
    _name = name;
    _poisearch = [self poisearch];
    BMKBoundSearchOption *boundSearchOption = [[BMKBoundSearchOption alloc]init];
    boundSearchOption.pageIndex = 0;
    boundSearchOption.pageCapacity = 20;
    boundSearchOption.keyword = name;
    boundSearchOption.leftBottom =_leftBottomPoint;
    boundSearchOption.rightTop =_rightBottomPoint;
    
    BOOL flag = [_poisearch poiSearchInbounds:boundSearchOption];
    if(flag)
    {
        NSLog(@"范围内检索发送成功");
    }
    else
    {
        NSLog(@"范围内检索发送失败");
    }
    
}

#pragma mark implement BMKSearchDelegate
- (void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPoiResult*)result errorCode:(BMKSearchErrorCode)error
{
    if (error == BMK_SEARCH_NO_ERROR) {
        NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
        [_mapView removeAnnotations:array];
        array = [NSArray arrayWithArray:_mapView.overlays];
        [_mapView removeOverlays:array];
        //在此处理正常结果
        for (int i = 0; i < result.poiInfoList.count; i++)
        {
            BMKPoiInfo* poi = [result.poiInfoList objectAtIndex:i];
            [self addAnimatedAnnotationWithName:poi.name withAddress:poi.pt];
        }
        
        CLLocationCoordinate2D cllocation = CLLocationCoordinate2DMake([_model.latitude floatValue] , [_model.longitude floatValue]);
        [_mapView setCenterCoordinate:cllocation animated:YES];
        BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
        annotation.coordinate = cllocation;
        annotation.title = _model.project_name;
        [_mapView addAnnotation:annotation];
        
    } else if (error == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR){
        NSLog(@"起始点有歧义");
    } else {
        // 各种情况的判断。。。
    }
}
// 添加动画Annotation
- (void)addAnimatedAnnotationWithName:(NSString *)name withAddress:(CLLocationCoordinate2D)coor {
    BMKPointAnnotation*animatedAnnotation = [[BMKPointAnnotation alloc]init];
    animatedAnnotation.coordinate = coor;
    animatedAnnotation.title = name;
    [_mapView addAnnotation:animatedAnnotation];
}
-(BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        newAnnotationView.pinColor = BMKPinAnnotationColorRed;
        newAnnotationView.animatesDrop = YES;// 设置该标注点动画显示
        if ([annotation.title isEqualToString:_model.project_name]) {
            newAnnotationView.image = [UIImage imageNamed:@"coordinates"];
        }
        else
        {
               NSArray *arr= @[@"教育",@"公交站点",@"医院",@"购物",@"餐饮"];
            if ([_name isEqualToString:arr[0]]) {
                 newAnnotationView.image = [UIImage imageNamed:@"education"];
            }
            else if ([_name isEqualToString:arr[1]]) {
                newAnnotationView.image = [UIImage imageNamed:@"traffic"];
            }
            else if ([_name isEqualToString:arr[2]]) {
                newAnnotationView.image = [UIImage imageNamed:@"hospital"];
            }
            else if ([_name isEqualToString:arr[3]]) {
                newAnnotationView.image = [UIImage imageNamed:@"shopping"];
            }
            else
            {
                newAnnotationView.image = [UIImage imageNamed:@"caterin"];
            }
           
        }
        
        return newAnnotationView;
    }
    return nil;
    
}



- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
    _leftBottomPoint = [_mapView convertPoint:CGPointMake(0,_mapView.frame.size.height) toCoordinateFromView:mapView];  // //西南角（左下角） 屏幕坐标转地理经纬度
    _rightBottomPoint = [_mapView convertPoint:CGPointMake(_mapView.frame.size.width,0) toCoordinateFromView:mapView];  //东北角（右上角）同上
}

-(BMKPoiSearch *)poisearch
{
    if (!_poisearch) {
        _poisearch =[[BMKPoiSearch alloc]init];
        _poisearch.delegate = self;
    }
    return _poisearch;
}

@end
