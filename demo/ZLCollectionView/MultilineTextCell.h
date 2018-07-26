//
//  MultilineTextCell.h
//  ZLCollectionView
//
//  Created by zhaoliang chen on 2018/7/26.
//  Copyright © 2018年 zhaoliang chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MultilineTextCell : UICollectionViewCell

@property(nonatomic,strong)UILabel* label;

+ (NSString *)cellIdentifier;

+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath;

@end
