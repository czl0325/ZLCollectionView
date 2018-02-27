//
//  ZLCollectionViewFlowLayout.h
//  ZLCollectionView
//
//  Created by zhaoliang chen on 2017/6/22.
//  Copyright © 2017年 zhaoliang chen. All rights reserved.
//


/**
 
 *  v0.2.0版本(当前版本)
    增加了填充式布局
 
 *  v0.1.1版本
    修复百分比布局计算错误的bug
 
 *  v0.1.0版本
    新加入了百分比布局,先在typeOfLayout设置布局为PercentLayout百分比布局,在percentOfRow设置百分比，必须为>0且<=1的浮点型数
 
 **/
#import <UIKit/UIKit.h>

typedef enum {
    BaseLayout      = 1,        //基础布局
    LabelLayout     = 2,        //标签页布局
    ClosedLayout    = 3,        //网格布局
    PercentLayout   = 4,        //百分比布局
    FillLayout      = 5,        //填充式布局
}ZLLayoutType;

@class ZLCollectionViewFlowLayout;
@protocol  ZLCollectionViewFlowLayoutDelegate <NSObject>
@optional
//指定是什么布局，如没有指定则为BaseLayout(基础布局)
- (ZLLayoutType)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewFlowLayout *)collectionViewLayout typeOfLayout:(NSInteger)section;

/**通过代理获得每个cell的宽度*/
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewFlowLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewFlowLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section;
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewFlowLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section;
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewFlowLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section;
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewFlowLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;
//在ClosedLayout列布局中指定一行有几列，不指定默认为1列
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewFlowLayout*)collectionViewLayout columnCountOfSection:(NSInteger)section;
//在PercentLayout百分比布局中指定每个item占该行的几分之几，如3.0/4，注意为大于0小于等于1的数字。不指定默认为1
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewFlowLayout*)collectionViewLayout percentOfRow:(NSIndexPath*)indexPath;
@end

@interface ZLCollectionViewFlowLayout : UICollectionViewFlowLayout

@property (nonatomic,assign) id<ZLCollectionViewFlowLayoutDelegate> delegate;

@end
