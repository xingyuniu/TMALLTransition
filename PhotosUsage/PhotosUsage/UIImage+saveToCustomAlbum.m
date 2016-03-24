//
//  UIImage+saveToCustomAlbum.m
//  PhotosUsage
//
//  Created by Mr yldany on 16/3/6.
//  Copyright © 2016年 YL. All rights reserved.
//

#import "UIImage+saveToCustomAlbum.h"


@implementation UIImage (saveToCustomAlbum)

#pragma mark - album

- (void)yl_saveToCustomAlbumWithCompletionBlock:(void (^)(BOOL, NSError *))completionBlock{
    // 1.获取到当前应用的相册
    PHAssetCollection *album = [self yl_getCustomAlbum];
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        
        // 2.保存图片到相册胶卷，并获取到照片对象的占位对象
        PHObjectPlaceholder *assetPlcaeholder = [PHAssetChangeRequest creationRequestForAssetFromImage:self].placeholderForCreatedAsset;
        
        // 3.创建一个【相册修改请求对象】
        PHAssetCollectionChangeRequest *albumChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:album];
        
        // 4.将照片的占位对象 添加至 【相册修改请求对象】
        //        [albumChangeRequest addAssets:@[assetPlcaeholder]]; // 将相片放置到相册最后一张
        [albumChangeRequest insertAssets:@[assetPlcaeholder] atIndexes:[NSIndexSet indexSetWithIndex:0]];// 将照片插入到相册的第一张
        
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (completionBlock) {
            completionBlock(success, error);
        }
    }];

}

/**
 *  获取跟APP同名的相册（如果不存在，则创建一个）
 */
- (PHAssetCollection *)yl_getCustomAlbum {
    // 1.查询所有相册， 找出自定义相册(与APP同名的相册)
    PHFetchResult *fetchedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    // 2.根据APP的名称获取对应的相册名(相册名即为APP的名称),如果有，返回该相册
    NSString *albumTitle = [NSBundle mainBundle].infoDictionary[@"CFBundleName"];
    // 遍历查询到的相册  找出需要的自定义相册(通过相册的 localizedTitle 属性)
    for (PHAssetCollection *album in fetchedAlbums) {
        if ([album.localizedTitle isEqualToString:albumTitle])
            return album;
    }
    
    // 3.能来到此处，尚未创建于APP同名的相册, 创建相册(与APP同名的相册)
    __block NSString *albumID = NSInvalidArgumentException;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        // 创建相册,并保存该相册的localIdentifier
        albumID = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:albumTitle].placeholderForCreatedAssetCollection.localIdentifier;
        
    } error:nil];
    
    // 根据相册的 localIdentifier 去获取该相册并返回
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[albumID] options:nil].firstObject;
}




@end
