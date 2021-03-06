//
//  PersonalVC.m
//  云渠道
//
//  Created by 谷治墙 on 2018/3/28.
//  Copyright © 2018年 xiaoq. All rights reserved.
//

#import "PersonalVC.h"
#import "PersonalTableCell.h"
#import "ChangePassWordVC.h"
#import "BirthVC.h"
#import "ChangeNameVC.h"
#import "ChangeAddessVC.h"
#import "MyCodeVC.h"

@interface PersonalVC ()<UITableViewDelegate,UITableViewDataSource>
{

    NSArray *_titleArr;
    NSMutableArray *_contentArr;
}
@property (nonatomic, strong) UITableView *personTable;

@property (nonatomic, strong) UIButton *exitBtn;

@end

@implementation PersonalVC

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [self initDataSource];
    [_personTable reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initDataSource];
    [self initUI];
}

- (void)initDataSource{
    
    _titleArr = @[@"云算号",@"我的二维码",@"姓名",@"电话号码",@"性别",@"出生年月",@"住址",@"修改密码"];
    _contentArr = [[NSMutableArray alloc] initWithArray:@[@"云算号",@"",@"姓名",@"电话号码",@"性别",@"出生年月",@"住址",@"******"]];
    if ([UserInfoModel defaultModel].account.length) {
        
        [_contentArr replaceObjectAtIndex:0 withObject:[UserInfoModel defaultModel].account];
    }
    if ([UserInfoModel defaultModel].name.length) {
        
        [_contentArr replaceObjectAtIndex:2 withObject:[UserInfoModel defaultModel].name];
    }
    if ([UserInfoModel defaultModel].tel.length) {
        
        [_contentArr replaceObjectAtIndex:3 withObject:[UserInfoModel defaultModel].tel];
    }
    if ([UserInfoModel defaultModel].sex) {
        
        if ([[UserInfoModel defaultModel].sex integerValue] == 0) {
            
            [_contentArr replaceObjectAtIndex:4 withObject:@"性别"];
        }else if ([[UserInfoModel defaultModel].sex integerValue] == 1){
            
            [_contentArr replaceObjectAtIndex:4 withObject:@"男"];
        }else if ([[UserInfoModel defaultModel].sex integerValue] == 2){
            
            [_contentArr replaceObjectAtIndex:4 withObject:@"女"];
        }
    }
    if ([UserInfoModel defaultModel].birth.length) {
        
        [_contentArr replaceObjectAtIndex:5 withObject:[UserInfoModel defaultModel].birth];
    }
    if ([UserInfoModel defaultModel].province.length && [UserInfoModel defaultModel].city.length && [UserInfoModel defaultModel].district.length) {

        NSData *JSONData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"region" ofType:@"json"]];
        
        NSError *err;
        NSArray *provice = [NSJSONSerialization JSONObjectWithData:JSONData
                                                           options:NSJSONReadingMutableContainers
                                                             error:&err];
        for (int i = 0; i < provice.count; i++) {
            
            if([provice[i][@"code"] integerValue] == [[UserInfoModel defaultModel].province integerValue]){
                
                NSArray *city = provice[i][@"city"];
                for (int j = 0; j < city.count; j++) {
                    
                    if([city[j][@"code"] integerValue] == [[UserInfoModel defaultModel].city integerValue]){
                        
                        NSArray *area = city[j][@"district"];
                        
                        for (int k = 0; k < area.count; k++) {
                            
                            if([area[k][@"code"] integerValue] == [[UserInfoModel defaultModel].district integerValue]){
                                
                                if ([UserInfoModel defaultModel].absolute_address.length) {
                                    
                                    [_contentArr replaceObjectAtIndex:6 withObject:[NSString stringWithFormat:@"%@-%@-%@-%@",provice[i][@"name"],city[0][@"name"],area[k][@"name"],[UserInfoModel defaultModel].absolute_address]];
                                }else{
                                    
                                    [_contentArr replaceObjectAtIndex:6 withObject:[NSString stringWithFormat:@"%@-%@-%@",provice[i][@"name"],city[0][@"name"],area[k][@"name"]]];
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}


#pragma mark -- action

- (void)ActionExitBtn:(UIButton *)btn{
    
    [self alertControllerWithNsstring:@"温馨提示" And:@"你确定要退出当前账号吗？" WithCancelBlack:^{
        
    } WithDefaultBlack:^{
        
        [BaseRequest GET:@"agent/user/logOut" parameters:nil success:^(id resposeObject) {
            
//            NSLog(@"%@",resposeObject);
        } failure:^(NSError *error) {
            
//            NSLog(@"%@",error);
        }];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:LOGINENTIFIER];
        [UserModel defaultModel].Token = @"";
        [UserModelArchiver archive];
        [UserModelArchiver ClearUserInfoModel];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"goLoginVC" object:nil];
    }];
}



#pragma mark -- tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 51 *SIZE;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    PersonalTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PersonalTableCell"];
    if (!cell) {
        
        cell = [[PersonalTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PersonalTableCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.titleL.text = _titleArr[indexPath.row];
    cell.contentL.text = _contentArr[indexPath.row];

    cell.contentL.hidden = NO;
    cell.headImg.hidden = YES;
    
    if (indexPath.row == 0 || indexPath.row == 3) {
        
        cell.rightView.hidden = YES;
    }else{
        
        cell.rightView.hidden = NO;
    }
    
    switch (indexPath.row) {
        case 0:
        {
            if ([UserInfoModel defaultModel].account.length) {
                
                cell.contentL.text = [UserInfoModel defaultModel].account;
                
            }
            break;
        }
        case 1:{
            
            break;
        }
        case 2:
        {
            if ([UserInfoModel defaultModel].name.length) {
                
                cell.contentL.text = [UserInfoModel defaultModel].name;
                
            }
            break;
        }
        case 3:
        {
            if ([UserInfoModel defaultModel].tel.length) {
                
                cell.contentL.text = [UserInfoModel defaultModel].tel;
                
            }
            break;
        }
        case 4:
        {
            if ([UserInfoModel defaultModel].sex) {
                
                if ([[UserInfoModel defaultModel].sex integerValue] == 0) {
                    
                    cell.contentL.text = @"性别";
                }else if ([[UserInfoModel defaultModel].sex integerValue] == 1){
                    
                    cell.contentL.text = @"男";
                }else if ([[UserInfoModel defaultModel].sex integerValue] == 2){
                    
                    cell.contentL.text = @"女";
                }
            }
            break;
        }
        case 5:
        {
            if ([UserInfoModel defaultModel].birth.length) {
                
                cell.contentL.text = [UserInfoModel defaultModel].birth;
                
            }
            break;
        }
        case 6:
        {
//            if ([UserInfoModel defaultModel].tel.length) {
//
//                cell.contentL.text = [UserInfoModel defaultModel].tel;
//
//            }
            if ([UserInfoModel defaultModel].province.length && [UserInfoModel defaultModel].city.length && [UserInfoModel defaultModel].district.length) {
                
                NSData *JSONData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"region" ofType:@"json"]];
                
                NSError *err;
                NSArray *provice = [NSJSONSerialization JSONObjectWithData:JSONData
                                                                   options:NSJSONReadingMutableContainers
                                                                     error:&err];
                for (int i = 0; i < provice.count; i++) {
                    
                    if([provice[i][@"region"] integerValue] == [[UserInfoModel defaultModel].province integerValue]){
                        
                        NSArray *city = provice[i][@"item"];
                        for (int j = 0; j < city.count; j++) {
                            
                            if([city[j][@"region"] integerValue] == [[UserInfoModel defaultModel].city integerValue]){
                                
                                NSArray *area = city[j][@"item"];
                                
                                for (int k = 0; k < area.count; k++) {
                                    
                                    if([area[k][@"region"] integerValue] == [[UserInfoModel defaultModel].district integerValue]){
                                        
                                        cell.contentL.text = [NSString stringWithFormat:@"%@-%@-%@",provice[i][@"name"],city[0][@"name"],area[k][@"name"]];
                                    }
                                }
                            }
                        }
                    }
                }
            }

            break;
        }
        case 7:
        {
//            if ([UserInfoModel defaultModel].tel.length) {
//
//                cell.contentL.text = [UserInfoModel defaultModel].tel;
//
//            }
            break;
        }
        default:
            break;
    }
    
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.row) {
        case 0:
        {
            break;
        }
        case 1:
        {
            MyCodeVC *nextVC = [[MyCodeVC alloc] init];
            [self.navigationController pushViewController:nextVC animated:YES];
            break;
        }
        case 2:
        {
            ChangeNameVC *nextVC = [[ChangeNameVC alloc] initWithName:[UserInfoModel defaultModel].name];
            [self.navigationController pushViewController:nextVC animated:YES];
            break;
        }
        case 3:
        {
            
            break;
        }
        case 4:
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"性别" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertAction *male = [UIAlertAction actionWithTitle:@"男" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                NSDictionary *dic = @{@"sex":@1};
                [BaseRequest POST:UpdatePersonal_URL parameters:dic success:^(id resposeObject) {
                    
//                    NSLog(@"%@",resposeObject);
                  
                    if ([resposeObject[@"code"] integerValue] == 200) {
                        
                        [UserInfoModel defaultModel].sex = @"1";
                        [UserModelArchiver infoArchive];
                        [_personTable reloadData];
                    }        else{
                        [self showContent:resposeObject[@"msg"]];
                    }
                } failure:^(NSError *error) {
                   
//                    NSLog(@"%@",error);
                    [self showContent:@"网络错误"];
                }];
            }];
            
            UIAlertAction *female = [UIAlertAction actionWithTitle:@"女" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                NSDictionary *dic = @{@"sex":@2};
                [BaseRequest POST:UpdatePersonal_URL parameters:dic success:^(id resposeObject) {
                    
//                    NSLog(@"%@",resposeObject);
                  
                    if ([resposeObject[@"code"] integerValue] == 200) {
                        
                        [UserInfoModel defaultModel].sex = @"2";
                        [UserModelArchiver infoArchive];
                        [_personTable reloadData];
                    }else{
                        
                        [self showContent:resposeObject[@"msg"]];
                    }
                } failure:^(NSError *error) {
                    
//                    NSLog(@"%@",error);
                    [self showContent:@"网络错误"];
                }];
            }];
            
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alert addAction:male];
            [alert addAction:female];
            [alert addAction:cancel];
            [self.navigationController presentViewController:alert animated:YES completion:^{
                
            }];
            break;
        }
        case 5:
        {
            BirthVC *nextVC = [[BirthVC alloc] initWithTime:[UserInfoModel defaultModel].birth];
            [self.navigationController pushViewController:nextVC animated:YES];
            break;
        }
        case 6:
        {
            ChangeAddessVC *nextVC = [[ChangeAddessVC alloc] init];
            [self.navigationController pushViewController:nextVC animated:YES];
            break;
        }
        case 7:
        {
            ChangePassWordVC *nextVC = [[ChangePassWordVC alloc] init];
            [self.navigationController pushViewController:nextVC animated:YES];
            break;
        }
        default:
            break;
    }
}

- (void)initUI{
    
    self.navBackgroundView.hidden = NO;
    self.titleLabel.text = @"账户信息";
    
    
    _personTable = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, SCREEN_Width, SCREEN_Height - NAVIGATION_BAR_HEIGHT - 50 *SIZE - TAB_BAR_MORE) style:UITableViewStylePlain];
    _personTable.backgroundColor = self.view.backgroundColor;
    _personTable.delegate = self;
    _personTable.dataSource = self;
    _personTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_personTable];
    
    _exitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _exitBtn.frame = CGRectMake(0, SCREEN_Height - 50 *SIZE - TAB_BAR_MORE, SCREEN_Width, 50 *SIZE + TAB_BAR_MORE);
    _exitBtn.titleLabel.font = [UIFont systemFontOfSize:14 *sIZE];
    [_exitBtn addTarget:self action:@selector(ActionExitBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_exitBtn setTitle:@"退出登录" forState:UIControlStateNormal];
    [_exitBtn setBackgroundColor:YJContentLabColor];
    [_exitBtn setTitleColor:YJTitleLabColor forState:UIControlStateNormal];
    [self.view addSubview:_exitBtn];
}


@end
