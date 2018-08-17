//
//  ZLCollectionViewFlowLayout.h
//  ZLCollectionView
//
//  Created by zhaoliang chen on 2017/6/22.
//  Copyright © 2017年 zhaoliang chen. All rights reserved.

#import <UIKit/UIKit.h>
#import "ZLCollectionReusableView.h"

/**
 *  当前版本 v0.8.0
 *  ------ 由于不能兼容原始布局，去掉了BaseLayout
 **/

typedef enum {
    //BaseLayout      = 1,        //基础布局。     用苹果默认的UICollectionView的布局，不去改变。
    LabelLayout     = 1,        //标签页布局。   一堆label标签的集合
    ClosedLayout    = 2,        //列布局       指定列数，按列数来等分一整行，itemSize的width可以任意写，在布局中会自动帮你计算。可用于瀑布流，普通UITableViewCell
    PercentLayout   = 3,        //百分比布局     需实现percentOfRow的代理，根据设定值来计算每个itemSize的宽度
    FillLayout      = 4,        //填充式布局     将一堆大小不一的view见缝插针的填充到一个平面内，规则为先判断从左到右是否有间隙填充，再从上到下判断。
    AbsoluteLayout  = 5,        //绝对定位布局    需实现rectOfItem的代理，指定每个item的frame
} ZLLayoutType;

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

/******** 设置每个section的背景色 ***********/
//设置每个section的背景色
- (UIColor*)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewFlowLayout *)collectionViewLayout backColorForSection:(NSInteger)section;

//自定义每个section的背景view，需要继承UICollectionReusableView，返回类名
- (NSString*)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewFlowLayout *)collectionViewLayout registerBackView:(NSInteger)section;

//对section背景进行一些操作
- (void)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewFlowLayout *)collectionViewLayout loadView:(NSInteger)section;

//背景是否延伸覆盖到headerView，默认为NO
- (BOOL)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewFlowLayout *)collectionViewLayout attachToTop:(NSInteger)section;

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

/******** 拖动cell的相关代理 ***************************/
- (void)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewFlowLayout*)collectionViewLayout didMoveCell:(NSIndexPath*)atIndexPath toIndexPath:(NSIndexPath*)toIndexPath;

@end

@interface ZLCollectionViewFlowLayout : UICollectionViewFlowLayout

@property (nonatomic,assign) id<ZLCollectionViewFlowLayoutDelegate> delegate;
@property (nonatomic,assign) BOOL isFloor;//宽度是否向下取整，默认YES，用于填充布局，未来加入百分比布局

@property (nonatomic,assign) BOOL canDrag;              //是否允许拖动cell，默认是NO

@property (nonatomic,assign) BOOL header_suspension;    //头部是否悬浮，默认是NO

@end
