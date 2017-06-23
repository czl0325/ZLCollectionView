//
//  SEMyRecordHeaderView.h
//  Seven
//
//  Created by zhaoliang chen on 2017/6/13.
//  Copyright © 2017年 zhaoliang chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SEMyRecordHeaderView : UICollectionReusableView

@property(nonatomic,strong)UILabel* labelMyRecord;
@property(nonatomic,strong)UIButton* btnModifyRecord;
@property(nonatomic,copy)void (^onMyRecordModify)();

+ (NSString *)headerViewIdentifier;

+ (instancetype)headerViewWithCollectionView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath;

@end
