//
//  ViewController.m
//  ZPInvisibleWatermark
//
//  Created by Justin on 2019/5/17.
//  Copyright © 2019 Justin. All rights reserved.
//

#import "ViewController.h"
#import "InvisibleWatermark.h"
#import <Photos/Photos.h>
#import <MBProgressHUD.h>

@interface ViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    int result = [InvisibleWatermark mixedCalculation:255];
    NSLog(@"result = %d",result);
}

- (IBAction)addWaterMarkBtnClick:(UIButton *)sender {
    __weak __typeof(self) weakSelf = self;
//    @weakify(self);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [InvisibleWatermark addWatermark:self.imageView.image text:@"秦学教育" completion:^(UIImage * _Nonnull image) {
//        @strongify(self);
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            strongSelf.imageView.image = image;
            [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
        }
    }];
}

- (IBAction)showWaterMarkClick:(UIButton *)sender {
    self.imageView.image = [InvisibleWatermark visibleWatermark:self.imageView.image];
}

- (IBAction)selectImageBtnClick:(UIButton *)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [[[UIApplication sharedApplication].delegate window].rootViewController presentViewController:imagePicker animated:YES completion:nil];
}

- (IBAction)exportImageBtnClick:(UIButton *)sender {
    PHAuthorizationStatus lastStatus = [PHPhotoLibrary authorizationStatus];
    __weak __typeof(self)weakSelf = self;
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //用户拒绝
                if(status == PHAuthorizationStatusDenied) {
                    if (lastStatus == PHAuthorizationStatusNotDetermined) {
                        // 保存失败
                        return;
                    }
                    // 请在系统设置中开启访问相册权限
                } else if(status == PHAuthorizationStatusAuthorized) {
                    [ViewController syncSaveImageWithPhotos:self.imageView.image];
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    hud.mode = MBProgressHUDModeText;
                    hud.label.text = @"导出成功";
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [hud hideAnimated:YES];
                    });
                } else if (status == PHAuthorizationStatusRestricted) {
                    // 系统原因，无法访问相册
                }
            });
        }
    }];
}

+ (PHFetchResult<PHAsset *> *)syncSaveImageWithPhotos:(UIImage *)image {
    __block NSString *createdAssetID = nil;
    
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        createdAssetID = [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
    } error:&error];
    
    if (error) {
        return nil;
    }
    
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsWithLocalIdentifiers:@[createdAssetID] options:nil];
    return assets;
}


@end
