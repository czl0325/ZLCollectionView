//
//  ZLCollectionViewFlowLayout.h
//  ZLCollectionView
//
//  Created by zhaoliang chen on 2017/6/22.
//  Copyright © 2017年 zhaoliang chen. All rights reserved.
//


/**
 *  v0.3.1版本(当前版本)
    将一些代理提取出来
 
 *  v0.3.0版本
    增加了绝对定位布局，可用于电影选座的开发
 
 *  v0.2.0版本
    增加了填充式布局
 
 *  v0.1.1版本
    修复百分比布局计算错误的bug
 
 *  v0.1.0版本
    新加入了百分比布局,先在typeOfLayout设置布局为PercentLayout百分比布局,在percentOfRow设置百分比，必须为>0且<=1的浮点型数
 
 **/
#import <UIKit/UIKit.h>

typedef enum {
    BaseLayout      = 1,        //基础布局。     用苹果默认的UICollectionView的布局，不去改变。
    LabelLayout     = 2,        //标签页布局。   一堆label标签的集合
    ClosedLayout    = 3,        //列布局       指定列数，按列数来等分一整行，itemSize的width可以任意写，在布局中会自动帮你计算。可用于瀑布流，普通UITableViewCell
    PercentLayout   = 4,        //百分比布局     需实现percentOfRow的代理，根据设定值来计算每个itemSize的宽度
    FillLayout      = 5,        //填充式布局     将一堆大小不一的view见缝插针的填充到一个平面内，规则为先判断从左到右是否有间隙填充，再从上到下判断。
    AbsoluteLayout  = 6,        //绝对定位布局    需实现rectOfItem的代理，指定每个item的frame
}ZLLayoutType;

@class ZLCollectionViewFlowLayout;
@protocol  ZLCollectionViewFlowLayoutDelegate <NSObject>
@optional
//指定是什么布局，如没有指定则为BaseLayout(基础布局)
- (ZLLayoutType)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewFlowLayout *)collectionViewLayout typeOfLayout:(NSInteger)section;

/**同基础UICollectionView的代理设置**/
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewFlowLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewFlowLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section;
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewFlowLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section;
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewFlowLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section;
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewFlowLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;

/******** 提取出UICollectionViewLayoutAttributes的一些属性 ***********/
//设置每个item的zIndex，不指定默认为0
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewFlowLayout *)collectionViewLayout zIndexOfItem:(NSIndexPath*)indexPath;
//设置每个item的CATransform3D，不指定默认为CATransform3DIdentity
- (CATransform3D)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewFlowLayout *)collectionViewLayout transformOfItem:(NSIndexPath*)indexPath;
//设置每个item的alpha，不指定默认为1
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewFlowLayout *)collectionViewLayout alphaOfItem:(NSIndexPath*)indexPath;

/******** ClosedLayout列布局需要的代理 ***********/
//在ClosedLayout列布局中指定一行有几列，不指定默认为1列
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewFlowLayout*)collectionViewLayout columnCountOfSection:(NSInteger)section;

/******** PercentLayout百分比布局需要的代理 ***********/
//在PercentLayout百分比布局中指定每个item占该行的几分之几，如3.0/4，注意为大于0小于等于1的数字。不指定默认为1
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewFlowLayout*)collectionViewLayout percentOfRow:(NSIndexPath*)indexPath;

/******** AbsoluteLayout绝对定位布局需要的代理 ***********/
//在AbsoluteLayout绝对定位布局中指定每个item的frame，不指定默认为CGRectZero
- (CGRect)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewFlowLayout*)collectionViewLayout rectOfItem:(NSIndexPath*)indexPath;


@end

@interface ZLCollectionViewFlowLayout : UICollectionViewFlowLayout

@property (nonatomic,assign) id<ZLCollectionViewFlowLayoutDelegate> delegate;

@end
