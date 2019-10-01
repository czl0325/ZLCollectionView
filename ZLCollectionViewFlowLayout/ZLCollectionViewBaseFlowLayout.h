//
//  ZLCollectionViewBaseFlowLayout.h
//  ZLCollectionView
//
//  Created by zhaoliang chen on 2019/1/25.
//  Copyright © 2019 zhaoliang chen. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 版本：1.1.6
 */

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    LabelHorizontalLayout   = 1,        //标签横向
    LabelVerticalLayout     = 2,        //标签纵向
    LabelLayout             = LabelHorizontalLayout,        //标签页布局。   一堆label标签的集合
    ClosedLayout            = 3,
    ColumnLayout            = ClosedLayout, //列布局       指定列数，按列数来等分一整行，itemSize的width可以任意写，在布局中会自动帮你计算。可用于瀑布流，普通UITableViewCell
    PercentLayout           = 4,        //百分比布局     需实现percentOfRow的代理，根据设定值来计算每个itemSize的宽度
    FillLayout              = 5,        //填充式布局     将一堆大小不一的view见缝插针的填充到一个平面内，规则为先判断从左到右是否有间隙填充，再从上到下判断。
    AbsoluteLayout          = 6,        //绝对定位布局    需实现rectOfItem的代理，指定每个item的frame
} ZLLayoutType;

@class ZLCollectionViewBaseFlowLayout;
@protocol  ZLCollectionViewBaseFlowLayoutDelegate <NSObject, UICollectionViewDelegateFlowLayout>
@optional
//指定是什么布局，如没有指定则为BaseLayout(基础布局)
- (ZLLayoutType)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout typeOfLayout:(NSInteger)section;

/******** 设置每个section的背景色 ***********/
//设置每个section的背景色
- (UIColor*)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout backColorForSection:(NSInteger)section;

//自定义每个section的背景view，需要继承UICollectionReusableView，返回类名
- (NSString*)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout registerBackView:(NSInteger)section;

//对section背景进行一些操作
- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout loadView:(NSInteger)section;

//背景是否延伸覆盖到headerView，默认为NO
- (BOOL)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout attachToTop:(NSInteger)section;

////没有效果
//- (ZLCollectionReusableView*)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewBaseFlowLayout *)collectionViewLayout registerBackView2:(NSInteger)section;
//
////没有效果
//- (void)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewBaseFlowLayout *)collectionViewLayout newLoadView:(ZLCollectionReusableView*)backView section:(NSInteger)section;

/******** 提取出UICollectionViewLayoutAttributes的一些属性 ***********/
//设置每个item的zIndex，不指定默认为0
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout zIndexOfItem:(NSIndexPath*)indexPath;
//设置每个item的CATransform3D，不指定默认为CATransform3DIdentity
- (CATransform3D)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout transformOfItem:(NSIndexPath*)indexPath;
//设置每个item的alpha，不指定默认为1
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout alphaOfItem:(NSIndexPath*)indexPath;

/******** ClosedLayout列布局需要的代理 ***********/
//在ClosedLayout列布局中指定一行有几列，不指定默认为1列
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout*)collectionViewLayout columnCountOfSection:(NSInteger)section;

/******** PercentLayout百分比布局需要的代理 ***********/
//在PercentLayout百分比布局中指定每个item占该行的几分之几，如3.0/4，注意为大于0小于等于1的数字。不指定默认为1
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout*)collectionViewLayout percentOfRow:(NSIndexPath*)indexPath;

/******** AbsoluteLayout绝对定位布局需要的代理 ***********/
//在AbsoluteLayout绝对定位布局中指定每个item的frame，不指定默认为CGRectZero
- (CGRect)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout*)collectionViewLayout rectOfItem:(NSIndexPath*)indexPath;

/******** 拖动cell的相关代理 ***************************/
//- (BOOL)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout*)collectionViewLayout shouldMoveCell:(NSIndexPath*)indexPath;

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout*)collectionViewLayout didMoveCell:(NSIndexPath*)atIndexPath toIndexPath:(NSIndexPath*)toIndexPath;

@end


/***
 此类是基类，不要调用。
 
 纵向布局请调用 #import "ZLCollectionViewVerticalLayout.h"
 横向布局请调用 #import "ZLCollectionViewHorzontalLayout.h"
 ***/
@interface ZLCollectionViewBaseFlowLayout : UICollectionViewFlowLayout

@property (nonatomic,weak) id<ZLCollectionViewBaseFlowLayoutDelegate> delegate;

@property (nonatomic,assign) BOOL isFloor;//宽度是否向下取整，默认YES，用于填充布局，未来加入百分比布局

@property (nonatomic,assign) BOOL canDrag;              //是否允许拖动cell，默认是NO

@property (nonatomic,assign) BOOL header_suspension;    //头部是否悬浮，默认是NO

@property (nonatomic,assign) ZLLayoutType layoutType;   //指定layout的类型，也可以在代理里设置

@property (nonatomic,assign) NSInteger columnCount;     //指定列数


//每个section的每一列的高度
@property (nonatomic, strong) NSMutableArray *collectionHeightsArray;
//存放每一个cell的属性
@property (nonatomic, strong) NSMutableArray *attributesArray;

@end

NS_ASSUME_NONNULL_END
