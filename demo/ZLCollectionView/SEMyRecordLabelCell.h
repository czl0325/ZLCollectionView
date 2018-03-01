//
//  SEMyRecordLabelCell.h
//  Seven
//
//  Created by zhaoliang chen on 2017/6/13.
//  Copyright © 2017年 zhaoliang chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SEMyRecordLabelCell : UICollectionViewCell

@property(nonatomic,strong)UIImageView* backImageView;
@property(nonatomic,strong)UILabel* labelRecord;

+ (NSString *)cellIdentifier;

+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath;

@end
