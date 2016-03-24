//
//  UIImage+saveToCustomAlbum.h
//  PhotosUsage
//
//  Created by Mr yldany on 16/3/6.
//  Copyright © 2016年 YL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface UIImage (saveToCustomAlbum)

/**
 *  保存图片至与APP同名的相册
 *
 *  @param completionBlock 保存完成后回调（可能保存成功，也可能保存失败）
 */
- (void)yl_saveToCustomAlbumWithCompletionBlock:(void(^)(BOOL success, NSError *error))completionBlock;


@end
