//
//  YLPhotoCell.m
//  PhotosUsage
//
//  Created by Mr yldany on 16/3/9.
//  Copyright © 2016年 YL. All rights reserved.
//

#import "YLPhotoCell.h"



@interface YLPhotoCell()
@end
@implementation YLPhotoCell
- (void)awakeFromNib {
    self.photoView.contentMode = UIViewContentModeScaleAspectFill;
    self.photoView.clipsToBounds = YES;
}

- (IBAction)selectBtnClick:(UIButton *)sender {
    NSLog(@"%s", __func__);
    sender.selected = !sender.selected;
}

@end
