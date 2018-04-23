//
//  RoomProjectVC.m
//  云渠道
//
//  Created by 谷治墙 on 2018/4/17.
//  Copyright © 2018年 xiaoq. All rights reserved.
//

#import "RoomProjectVC.h"
#import "RoomDetailTableHeader.h"
#import "RoomDetailTableHeader5.h"
#import "RoomDetailTableHeader6.h"
#import "RoomDetailTableCell.h"
#import "RoomDetailTableCell1.h"
#import "RoomDetailTableCell2.h"
#import "RoomDetailTableCell3.h"
#import "RoomDetailTableCell4.h"
#import "RoomDetailTableCell5.h"
#import "BuildingInfoVC.h"
#import "HouseTypeDetailVC.h"
#import "DynamicListVC.h"
#import "CustomMatchListVC.h"
#import "DistributVC.h"
#import "RoomDetailModel.h"
#import "BuildingAlbumVC.h"
#import <BaiduMapAPI_Search/BMKPoiSearchType.h>
#import <BaiduMapAPI_Search/BMKPoiSearchOption.h>
#import <BaiduMapAPI_Search/BMKPoiSearch.h>

@interface RoomProjectVC ()<UITableViewDelegate,UITableViewDataSource,BMKMapViewDelegate,RoomDetailTableCell4Delegate,BMKPoiSearchDelegate>
{
    CLLocationCoordinate2D _leftBottomPoint;
    CLLocationCoordinate2D _rightBottomPoint;//地图矩形的顶点
    
    NSMutableDictionary *_dynamicDic;
    NSString *_projectId;
    RoomDetailModel *_model;
    NSMutableDictionary *_focusDic;
    NSString *_dynamicNum;
    NSMutableArray *_imgArr;
    NSString *_focusId;
}

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

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    self.mapView.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    self.mapView.delegate = nil;
    [self.mapView removeFromSuperview];
}


- (void)initDataSource{
    
    _dynamicNum = @"";
    _imgArr = [@[] mutableCopy];
    _focusDic = [@{} mutableCopy];
    _dynamicDic = [@{} mutableCopy];
    _model = [[RoomDetailModel alloc] init];
    [self RequestMethod];
}

- (void)RequestMethod{
    
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:_projectId forKey:@"project_id"];
    if ([UserModel defaultModel].Token) {
        
        [dic setObject:@1 forKey:@"is_agent"];
    }else{
        
        [dic setObject:@0 forKey:@"is_agent"];
    }
    [BaseRequest GET:ProjectDetail_URL parameters:dic success:^(id resposeObject) {
        
        NSLog(@"%@",resposeObject);
        if ([resposeObject[@"code"] integerValue] == 200) {
            
            if ([resposeObject[@"data"] isKindOfClass:[NSDictionary class]]) {
                
                [self SetData:resposeObject[@"data"]];
                
            }else{
                
                [self showContent:@"暂时没有数据"];
            }
        }
    } failure:^(NSError *error) {
       
        NSLog(@"%@",error);
        [self showContent:@"网络错误"];
    }];
}

- (void)SetData:(NSDictionary *)data{
    

    if ([data[@"project_basic_info"] isKindOfClass:[NSDictionary class]]) {
        
        NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] initWithDictionary:data[@"project_basic_info"]];
        [tempDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
           
            if ([obj isKindOfClass:[NSNull class]]) {
                
                [tempDic setObject:@"" forKey:key];
            }
        }];
        _model = [[RoomDetailModel alloc] initWithDictionary:tempDic];
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
    
    if ([data[@"focus"] isKindOfClass:[NSDictionary class]]) {
        
        _focusDic = [NSMutableDictionary dictionaryWithDictionary:data[@"focus"]];
    }
    
    [_roomTable reloadData];
}

- (void)ActionMoreBtn:(UIButton *)btn{
    
    NSLog(@"%ld",btn.tag);
    if (btn.tag == 1) {
        BuildingInfoVC *next_vc = [[BuildingInfoVC alloc]init];
        [self.navigationController pushViewController:next_vc animated:YES];
    }
    
    if (btn.tag == 2) {
        
        DynamicListVC *next_vc = [[DynamicListVC alloc]init];
        [self.navigationController pushViewController:next_vc animated:YES];
    }
    
}

#pragma mark -- BMKMap

- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation{
    
    
}


#pragma mark -- delegate

- (void)Cell4collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
}


#pragma mark -- tableview

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 7;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 6) {
        
        return 2;
    }else{
        
        if (section == 0) {
            
            return 0;
        }else{
            
            return 1;
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
            
            BuildingAlbumVC *nextVC = [[BuildingAlbumVC alloc] initWithNum:num imgArr:imgArr];
            [self.navigationController pushViewController:nextVC animated:YES];
        };
        
        header.attentBtnBlock = ^{
            
            if (_focusDic.count) {
                
                if ([_focusDic[@"is_focus"] integerValue]) {
                    
//                    [BaseRequest GET:FocusProject_URL parameters:<#(NSDictionary *)#> success:<#^(id resposeObject)success#> failure:<#^(NSError *error)failure#>]
                }else{
                    
                    [BaseRequest GET:FocusProject_URL parameters:@{@"project_id":_model} success:^(id resposeObject) {
                        
                        NSLog(@"%@",resposeObject);
                        if ([resposeObject[@"code"] integerValue] == 200) {
                            
                            
                        }else{
                            
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
              header.numL.text = @"匹配的客户(23)";
              header.moreBtnBlock = ^{
                  
                  CustomMatchListVC *nextVC = [[CustomMatchListVC alloc] init];
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
        {
            
            RoomDetailTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RoomDetailTableCell"];
            if (!cell) {
                
                cell = [[RoomDetailTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RoomDetailTableCell"];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.developL.text = @"阳光物业公司";
            cell.openL.text = @"2017年02月20日";
            cell.payL.text = @"2019年02月";
            cell.timeL.text = @"70年";
            cell.moreBtn.tag = indexPath.section;
            [cell.moreBtn addTarget:self action:@selector(ActionMoreBtn:) forControlEvents:UIControlEventTouchUpInside];
            return cell;
            break;
        }
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
                cell.contentL.text = _dynamicDic[@"content"];
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
            cell.num = 10;
            cell.collCellBlock = ^(NSInteger index) {

                //                HouseTypeDetailVC *nextVC = [[HouseTypeDetailVC alloc] init];
                //                [self.navigationController pushViewController:nextVC animated:YES];
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
                [_mapView mas_makeConstraints:^(MASConstraintMaker *make) {

                    make.left.equalTo(cell.contentView).offset(0);
                    make.top.equalTo(cell.contentView).offset(33 *SIZE);
                    make.right.equalTo(cell.contentView).offset(0);
                    make.width.equalTo(@(360 *SIZE));
                    make.height.equalTo(@(187 *SIZE));
                    make.bottom.equalTo(cell.contentView).offset(-59 *SIZE);
                }];
            }
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
            cell.nameL.text = @"张三";
            cell.priceL.text = @"80 - 100";
            cell.typeL.text = @"三室一厅";
            cell.areaL.text = @"郫都区-德源大道";
            cell.intentionRateL.text = @"23";
            cell.urgentRateL.text = @"43";
            cell.matchRateL.text = @"83";
            cell.phoneL.text = @"13438339177";
            return cell;
            break;
        }
        default:{
            RoomDetailTableCell5 *cell = [tableView dequeueReusableCellWithIdentifier:@"RoomDetailTableCell5"];
            if (!cell) {

                cell = [[RoomDetailTableCell5 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RoomDetailTableCell5"];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.nameL.text = @"张三";
            cell.priceL.text = @"80 - 100";
            cell.typeL.text = @"三室一厅";
            cell.areaL.text = @"郫都区-德源大道";
            cell.intentionRateL.text = @"23";
            cell.urgentRateL.text = @"43";
            cell.matchRateL.text = @"83";
            cell.phoneL.text = @"13438339177";
            return cell;
            break;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 10) {
        
//        DistributVC *nextVC = [[DistributVC alloc] init];
//        [self.navigationController pushViewController:nextVC animated:YES];
        
    }
}



- (void)initUI{
    
    
    _roomTable.rowHeight = 360 *SIZE;
    _roomTable.estimatedRowHeight = UITableViewAutomaticDimension;
    _roomTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_Width, self.view.frame.size.height - NAVIGATION_BAR_HEIGHT - 47 *SIZE - TAB_BAR_MORE) style:UITableViewStyleGrouped];
    _roomTable.backgroundColor = self.view.backgroundColor;
    _roomTable.delegate = self;
    _roomTable.dataSource = self;
    _roomTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_roomTable];
    
    _counselBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _counselBtn.frame = CGRectMake(0, self.view.frame.size.height - NAVIGATION_BAR_HEIGHT - 47 *SIZE - TAB_BAR_MORE, SCREEN_Width, 47 *SIZE + TAB_BAR_MORE);
    _counselBtn.titleLabel.font = [UIFont systemFontOfSize:14 *sIZE];
    //    [_counselBtn addTarget:self action:@selector(<#selector#>) forControlEvents:UIControlEventTouchUpInside];
    [_counselBtn setTitle:@"电话咨询" forState:UIControlStateNormal];
    [_counselBtn setBackgroundColor:COLOR(255, 188, 88, 1)];
    [_counselBtn setTitleColor:CH_COLOR_white forState:UIControlStateNormal];
    [self.view addSubview:_counselBtn];

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
    
    _poisearch = [[BMKPoiSearch alloc]init];
    _poisearch.delegate = self;
    
    BMKBoundSearchOption *boundSearchOption = [[BMKBoundSearchOption alloc]init];
    boundSearchOption.pageIndex = 0;
    boundSearchOption.pageCapacity = 40;
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
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
    _leftBottomPoint = [_mapView convertPoint:CGPointMake(0,_mapView.frame.size.height) toCoordinateFromView:mapView];  // //西南角（左下角） 屏幕坐标转地理经纬度
    _rightBottomPoint = [_mapView convertPoint:CGPointMake(_mapView.frame.size.width,0) toCoordinateFromView:mapView];  //东北角（右上角）同上
}

@end
