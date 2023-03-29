//
//  ZLCollectionViewBaseFlowLayout.h
//  ZLCollectionView
//
//  Created by zhaoliang chen on 2019/1/25.
//  Copyright © 2019 zhaoliang chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLBaseEventModel.h"

/**
 版本：1.4.9
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

typedef enum {
    minHeight               = 1,        // 按最小高度
    Sequence                = 2,        // 按顺序
} ZLColumnSortType;

@class ZLCollectionViewBaseFlowLayout;
@protocol  ZLCollectionViewBaseFlowLayoutDelegate <NSObject, UICollectionViewDelegateFlowLayout>
@optional
//指定是什么布局，如没有指定则为FillLayout(填充式布局)
- (ZLLayoutType)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout typeOfLayout:(NSInteger)section;

/******** 设置每个section的背景色 ***********/
//设置每个section的背景色
- (UIColor*)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout backColorForSection:(NSInteger)section;

//设置每个section的背景图
- (UIImage*)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout backImageForSection:(NSInteger)section;

//自定义每个section的背景view，需要继承UICollectionReusableView(如要调用方法传递参数需要继承ZLCollectionBaseDecorationView)，返回类名
- (NSString*)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout registerBackView:(NSInteger)section;

//向每个section自定义背景view传递自定义方法 eventName:方法名（注意带参数的方法名必须末尾加:）,parameter:参数
- (ZLBaseEventModel*)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout backgroundViewMethodForSection:(NSInteger)section;

//背景是否延伸覆盖到headerView，默认为NO
- (BOOL)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout attachToTop:(NSInteger)section;

//背景是否延伸覆盖到footerView，默认为NO
- (BOOL)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout attachToBottom:(NSInteger)section;

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

//在ClosedLayout列布局中指定哪列哪行可以是单行布局，不指定以上个方法为准
- (BOOL)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout*)collectionViewLayout singleColumnCountOfIndexPath:(NSIndexPath*)indexPath;

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

@property (nonatomic,assign) BOOL isFloor; // 宽度是否向下取整，默认YES，用于填充布局，未来加入百分比布局

@property (nonatomic,assign) BOOL canDrag;              //是否允许拖动cell，默认是NO

@property (nonatomic,assign) BOOL header_suspension;    //头部是否悬浮，默认是NO

@property (nonatomic,assign) ZLLayoutType layoutType;   //指定layout的类型，也可以在代理里设置

@property (nonatomic,assign) NSInteger columnCount;     //指定列数

@property (nonatomic,assign) ZLColumnSortType columnSortType;   // 瀑布流列排序的方式

@property (nonatomic,assign) CGFloat fixTop;            //header偏移量

@property (nonatomic,assign) CGFloat xBeyond;           //x轴允许超出的偏移量（仅填充布局，默认3px）

//每个section的每一列的高度
@property (nonatomic, strong) NSMutableArray *collectionHeightsArray;
//存放每一个cell的属性
@property (nonatomic, strong) NSMutableArray *attributesArray;
//存放header属性, 外部不要干预
@property (nonatomic, strong, readonly) NSMutableArray *headerAttributesArray;

//是否需要重新计算所有布局
//内部控制，一般情况外部无需干预(内部会在外部调用reloadData,insertSections,insertItems,deleteItems...等方法调用时将此属性自动置为YES)
@property (nonatomic, assign, readonly) BOOL isNeedReCalculateAllLayout;

//提供一个方法来设置isNeedReCalculateAllLayout (之所以提供是因为特殊情况下外部可能需要强制重新计算布局)
//比如需要强制刷新布局时，可以先调用此函数设置为YES, 一般情况外部无需干预
- (void)forceSetIsNeedReCalculateAllLayout:(BOOL)isNeedReCalculateAllLayout;

// 注册所有的背景view(传入类名)
- (void)registerDecorationView:(NSArray<NSString*>*)classNames;

@end

NS_ASSUME_NONNULL_END
