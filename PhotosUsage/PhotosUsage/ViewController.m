//
//  ViewController.m
//  PhotosUsage
//
//  Created by Mr yldany on 16/3/6.
//  Copyright © 2016年 YL. All rights reserved.
//

#import "ViewController.h"

#import "UIImage+saveToCustomAlbum.h"
#import <SVProgressHUD.h>

#import "YLPhotoCell.h"



static CGFloat const MinConstValue = 27;
static CGFloat const Photo_leading_trailing_margin = 2;

static NSString *const ID = @"photoCell";
static NSString *const supID = @"photoCellSupView";

@interface ViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

/** 相册中的图片 */
@property (nonatomic, strong) NSMutableArray *assets;

@property (weak, nonatomic) IBOutlet UICollectionView *albumView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://img3.imgtn.bdimg.com/it/u=2389827058,1634333351&fm=21&gp=0.jpg"]];
//    UIImage *image = [UIImage imageWithData:imageData];
//    self.imageView.image = [UIImage imageNamed:@"1"];
    [self.albumView registerNib:[UINib nibWithNibName:NSStringFromClass([YLPhotoCell class]) bundle:nil] forCellWithReuseIdentifier:ID];
    
//    [self scanPhotoesFromAlbum];
}



#pragma mark - 懒加载

- (NSMutableArray *)assets {
    if (_assets == nil) {
        _assets = [NSMutableArray array];
    }
    return _assets;
}


#pragma mark - 事件监听
/**
 *  保存图片至自定义的相册（先保存至相册胶卷，再添加至自定义相册）
 */
- (IBAction)saveImageToCameraRoll {
    [self.imageView.image yl_saveToCustomAlbumWithCompletionBlock:^(BOOL success, NSError *error) {
        if (success) {
            [SVProgressHUD showSuccessWithStatus:@"保存图片成功"];
        }else {
            [SVProgressHUD showErrorWithStatus:@"保存图片失败"];
        }
    }];
}


- (IBAction)selectImageFromAlbum {
    
    // 选取单张图片
    /*
    UIImagePickerController *ipc =[[UIImagePickerController alloc] init];
    ipc.delegate = self;
    [self presentViewController:ipc animated:YES completion:nil];
     */
    
    // 选取多张图片
    [self scanPhotoesFromAlbum];
}

/**
 *  浏览相册中的图片
 */
- (void)scanPhotoesFromAlbum {
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        [self.assets removeAllObjects];
        // 过滤策略
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
        option.fetchLimit = 10;
        
        // 遍历找出指定的相册
        PHFetchResult *results = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:option];
        PHAssetCollection *album = results.lastObject;
        
        
        
        // 根据相册遍历获取其中的前50张图片
        PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:album options:nil];
        CGSize imageSize = CGSizeMake(200, 100);
        PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
        requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        
        //    requestOptions.synchronous = YES;
        NSLog(@"相册名字：%@", album.localizedTitle);
        NSInteger count = 50;
        NSInteger maxCount = assets.count;
        __block NSInteger index = 0;
        for (PHAsset *asset in assets) {
            // 过滤非图片
            if (asset.mediaType != PHAssetMediaTypeImage) continue;
            
            [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFit options:requestOptions resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
                index++;
                
                if (index <= count) {
                   
                    [self.assets addObject:image];
                    if (index == count || index == maxCount){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [self.albumView reloadData];
                            
                            
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                [self handleVisableCellsInCollectionView:self.albumView];
                            });
            
                        });
                        return;
                    }
                }
                
            }];
        }
        
        
    });
    
//    [self.albumView reloadData];
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    self.imageView.image = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YLPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    cell.photoView.image = self.assets[indexPath.item];
    return cell;
}


#pragma mark - UICollectionViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    UICollectionView *albumView = (UICollectionView *)scrollView;
    [self handleVisableCellsInCollectionView:albumView];
}


/**
 *  处理cell的约束值
 */
- (void)handleVisableCellsInCollectionView:(UICollectionView *)collectionView {
    
    
    // 获取可见cell
    NSArray *indexs = [collectionView indexPathsForVisibleItems];
    
//    372623326
//    if (indexs.count <= 0) {
//        return;
//    }
    
    indexs = [indexs sortedArrayUsingComparator:^NSComparisonResult(NSIndexPath *obj1, NSIndexPath *obj2) {
        return obj1.item > obj2.item;
    }];
    

    
    // 处理非最后一个cell的约束（约束值为间距大小）
    for (int i = 0; i < indexs.count - 1; i++) {
        YLPhotoCell *photoCell = (YLPhotoCell *)[collectionView cellForItemAtIndexPath:indexs[i]];
        photoCell.trailingConstraint.constant = Photo_leading_trailing_margin;
    }
    // 处理最后一个cell的约束
    NSIndexPath *lastIndex = indexs.lastObject;
    YLPhotoCell *lastCell = (YLPhotoCell *)[collectionView cellForItemAtIndexPath:lastIndex];
    
    // 计算最后一个cell的尺寸
    CGFloat maxBound_X = CGRectGetMaxX(collectionView.bounds);
    CGFloat cell_X = lastCell.frame.origin.x;
    CGFloat cell_W = lastCell.frame.size.width;
    CGFloat delatX = maxBound_X - cell_X;
    
    // 修改约束值
    if (delatX > MinConstValue && delatX < cell_W - Photo_leading_trailing_margin) {
        // 交集部分的宽度介于 【按钮宽度 + 间距】 与 【cell宽度 - 间距】之间时，约束值为 【cell宽度 - 公共部分的宽度】
        lastCell.trailingConstraint.constant = cell_W - delatX;
    }else if (delatX >= cell_W - Photo_leading_trailing_margin){
        // cell完全显示时，约束值为 【间距】-> 停靠在最右边
        lastCell.trailingConstraint.constant = Photo_leading_trailing_margin;
    }else {
        // 其他情况，约束值为 【cell宽度 - 间距】-> 停靠在最左边
        lastCell.trailingConstraint.constant = cell_W - MinConstValue;
    }
    
//    [self.view layoutIfNeeded];
}


@end
