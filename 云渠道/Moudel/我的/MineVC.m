//
//  MineVC.m
//  云渠道
//
//  Created by xiaoq on 2018/3/13.
//  Copyright © 2018年 xiaoq. All rights reserved.
//

#import "MineVC.h"
#import "MineCell.h"
#import "MyBrokerageVC.h"
#import "AuthenticationVC.h"
#import "PersonalVC.h"
#import "MyAttentionVC.h"
#import "FeedbackVC.h"
#import "ExperienceVC.h"


@interface MineVC ()<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIImagePickerController *_imagePickerController; /**< 相册拾取器 */
    NSArray *_namelist;
    NSArray *_imageList;
    NSArray *_contentList;
    
}
@property (nonatomic, strong) UIImageView *headImg;

@property (nonatomic, strong) UILabel *nameL;

@property (nonatomic, strong) UIImageView *codeImg;

@property (nonatomic, strong) UIButton *codeBtn;

@property (nonatomic , strong) UITableView *Mytableview;
@end

@implementation MineVC


- (void)viewDidLoad {
    [super viewDidLoad];
    [self InitDataSouce];
    [self InitUI];
    
}

-(void)InitUI{
    
    UIView *backview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 360*SIZE, STATUS_BAR_HEIGHT+114*SIZE)];
    backview.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:backview];
    
    _headImg = [[UIImageView alloc] initWithFrame:CGRectMake(14 *SIZE, STATUS_BAR_HEIGHT+24 *SIZE, 60 *SIZE, 60 *SIZE)];
    _headImg.layer.masksToBounds = YES;
    _headImg.layer.cornerRadius = 30 *SIZE;
    _headImg.image = [UIImage imageNamed:@"def_head"];
    [self.view addSubview:_headImg];
    
    _nameL = [[UILabel alloc] initWithFrame:CGRectMake(91 *SIZE, STATUS_BAR_HEIGHT+48.7 *SIZE, 160 *SIZE, 12 *SIZE)];
    _nameL.textColor = YJContentLabColor;
    _nameL.font = [UIFont systemFontOfSize:13 *SIZE];
    _nameL.text = @"56318754125623";
    [self.view addSubview:_nameL];
//
//    _codeImg = [[UIImageView alloc] initWithFrame:CGRectMake(288 *SIZE, 48 *SIZE, 38 *SIZE, 38 *SIZE)];
//    _codeImg.backgroundColor = YJGreenColor;
//    [self.view addSubview:_codeImg];
    
//    UIImageView *rightView = [[UIImageView alloc] initWithFrame:CGRectMake(344 *SIZE, STATUS_BAR_HEIGHT+42.7 *SIZE, 6.7 *SIZE, 12.3 *SIZE)];
//    rightView.image = [UIImage imageNamed:@"rightarrow"];
//    [self.view addSubview:rightView];
    
    _codeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _codeBtn.frame = CGRectMake(9 *SIZE, STATUS_BAR_HEIGHT+19 *SIZE, 70 *SIZE, 70*SIZE);
    [_codeBtn addTarget:self action:@selector(ActionCodeBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_codeBtn];
    
    [self.view addSubview:self.Mytableview];
}

-(void)InitDataSouce
{
    _namelist = @[@[@"个人资料",@"公司认证",@"工作经历"],@[@"我的佣金",@"我的关注"],@[@"意见反馈",@"关于易家",@"操作指南"]];
    _imageList = @[@[@"",@"certification",@"work"],@[@"commission",@"focus"],@[@"opinion",@"about",@"operation"]];
    _contentList= @[@[@"",@"云算科技公司",@""],@[@"",@""],@[@" ",@"V1.0",@""]];
    _imagePickerController = [[UIImagePickerController alloc] init];
    _imagePickerController.delegate = self;
}

- (void)ActionCodeBtn:(UIButton *)btn{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"上传头像"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    // 相册选择
    [alertController addAction:[UIAlertAction actionWithTitle:@"照片" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self selectPhotoAlbumPhotos];
    }]];
    // 拍照
    [alertController addAction:[UIAlertAction actionWithTitle:@"拍摄" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self takingPictures];
    }]];
    // 取消
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];
    // 推送
    [self presentViewController:alertController animated:YES completion:^{
    }];
}

#pragma mark -- 选择头像

- (void)selectPhotoAlbumPhotos {
    // 获取支持的媒体格式
    NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    // 判断是否支持需要设置的sourceType
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        // 1、设置图片拾取器上的sourceType
        _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        // 2、设置支持的媒体格式
        _imagePickerController.mediaTypes = @[mediaTypes[0]];
        // 3、其他设置
        _imagePickerController.allowsEditing = YES; // 如果设置为NO，当用户选择了图片之后不会进入图像编辑界面。
        // 4、推送图片拾取器控制器
        [self presentViewController:_imagePickerController animated:YES completion:nil];
    }
}

// 拍照
- (void)takingPictures {
    // 获取支持的媒体格式
    NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    
    // 判断是否支持需要设置的sourceType
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        // 1、设置图片拾取器上的sourceType
        _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        // 2、设置支持的媒体格式
        _imagePickerController.mediaTypes = @[mediaTypes[0]];
        // 3、其他设置
        // 设置相机模式
        _imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        // 设置摄像头：前置/后置
        _imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        // 设置闪光模式
        _imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
        
        
        // 4、推送图片拾取器控制器
        [self presentViewController:_imagePickerController animated:YES completion:nil];
        
    } else {
        NSLog(@"当前设备不支持拍照");
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"温馨提示"
                                                                                  message:@"当前设备不支持拍照"
                                                                           preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              //                                                              _uploadButton.hidden = NO;
                                                          }]];
        [self presentViewController:alertController
                           animated:YES
                         completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        if ([info[UIImagePickerControllerMediaType] isEqualToString:@"public.image"]) {
            UIImage *originalImage = [self fixOrientation:info[UIImagePickerControllerOriginalImage]];
            [self updateheadimgbyimg:originalImage];
        }
    }else if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary){
        UIImage *originalImage = [self fixOrientation:info[UIImagePickerControllerEditedImage]];
        [self updateheadimgbyimg:originalImage];
        
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)updateheadimgbyimg:(UIImage *)img
{
    NSData *data = [self resetSizeOfImageData:img maxSize:150];
    
    [BaseRequest Updateimg:UploadFile_URL parameters:@{@"file_name":@"headimg"
                                                    }
          constructionBody:^(id<AFMultipartFormData> formData) {
              [formData appendPartWithFileData:data name:@"headimg" fileName:@"headimg.jpg" mimeType:@"image/jpg"];
    } success:^(id resposeObject) {
        NSLog(@"%@",resposeObject);
        _headImg.image = img;
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

// 用户点击了取消按钮
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark  ---  delegate  ---
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        return 2;
    }
    else
        return 3;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   
    return 3;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 43.3*SIZE;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (!section) {
        
        return 2 *SIZE;
    }
    return 7 *SIZE;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 360*SIZE, 10*SIZE)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MineCell";
    
    MineCell *cell  = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[MineCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [cell SetTitle:_namelist[indexPath.section][indexPath.row] icon:_imageList[indexPath.section][indexPath.row] contentlab:_contentList[indexPath.section][indexPath.row]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.section == 0)
    {
        if (indexPath.row == 0) {
            
            PersonalVC *nextVC = [[PersonalVC alloc] init];
            nextVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:nextVC animated:YES];
        }else if (indexPath.row == 1) {
            
            AuthenticationVC *nextVC = [[AuthenticationVC alloc] init];
            nextVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:nextVC animated:YES];
        }else{
            
            ExperienceVC *nextVC = [[ExperienceVC alloc] init];
            nextVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:nextVC animated:YES];
        }
    }
    else if (indexPath.section ==1)
    {
        
        if (indexPath.row == 0) {
            
            MyBrokerageVC *nextVC = [[MyBrokerageVC alloc] init];
            nextVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:nextVC animated:YES];
        }else{
            
            if (indexPath.row == 1) {
                
                MyAttentionVC *nextVC = [[MyAttentionVC alloc] init];
                nextVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:nextVC animated:YES];
            }
        }
    }else
    {
        if (indexPath.row == 0) {
            
            FeedbackVC *nextVC = [[FeedbackVC alloc] init];
            nextVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:nextVC animated:YES];
        }
        else if(indexPath.row ==1)
        {
            
        }else{
            
            
        }
        
    }
}

#pragma mark  ---  懒加载   ---

-(UITableView *)Mytableview
{
    if(!_Mytableview)
    {
        _Mytableview =   [[UITableView alloc]initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT+115*SIZE, 360*SIZE, SCREEN_Height-STATUS_BAR_HEIGHT-115*SIZE) style:UITableViewStylePlain];
        _Mytableview.backgroundColor = YJBackColor;
        _Mytableview.delegate = self;
        _Mytableview.dataSource = self;
        [_Mytableview setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }
    return _Mytableview;
}


@end
