//
//  YLPhotoCell.h
//  PhotosUsage
//
//  Created by Mr yldany on 16/3/9.
//  Copyright © 2016年 YL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YLPhotoCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingConstraint;

@property (weak, nonatomic) IBOutlet UIImageView *photoView;

@end
