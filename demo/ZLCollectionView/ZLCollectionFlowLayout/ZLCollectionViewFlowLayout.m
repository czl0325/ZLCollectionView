//
//  ZLCollectionViewFlowLayout.m
//  ZLCollectionView
//
//  Created by zhaoliang chen on 2017/6/22.
//  Copyright © 2017年 zhaoliang chen. All rights reserved.
//

#import "ZLCollectionViewFlowLayout.h"
#import "ZLCollectionViewLayoutAttributes.h"
#import "ZLCellFakeView.h"

typedef NS_ENUM(NSUInteger, LewScrollDirction) {
    LewScrollDirctionStay,
    LewScrollDirctionToTop,
    LewScrollDirctionToEnd,
};

@interface ZLCollectionViewFlowLayout()
<UIGestureRecognizerDelegate>

//每个section的每一列的高度
@property (nonatomic, retain) NSMutableArray *collectionHeightsArray;
//存放每一个cell的属性
@property (nonatomic, retain) NSMutableArray *attributesArray;

//关于拖动的参数
@property (nonatomic, strong) ZLCellFakeView *cellFakeView;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, assign) CGPoint fakeCellCenter;
@property (nonatomic, assign) CGPoint panTranslation;
@property (nonatomic) LewScrollDirction continuousScrollDirection;
@property (nonatomic, strong) CADisplayLink *displayLink;

@end

@implementation ZLCollectionViewFlowLayout

#pragma mark - 初始化属性
- (instancetype)init {
    self = [super init];
    if (self) {
        self.isFloor = YES;
        self.canDrag = NO;
        self.header_suspension = NO;
        [self addObserver:self forKeyPath:@"collectionView" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

#pragma mark - 当尺寸有所变化时，重新刷新
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

+ (Class)layoutAttributesClass {
    return [ZLCollectionViewLayoutAttributes class];
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"collectionView"];
}

- (void)prepareLayout {
    [super prepareLayout];
    
    CGFloat totalWidth = self.collectionView.frame.size.width;
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat headerH = 0;
    CGFloat footerH = 0;
    UIEdgeInsets edgeInsets = UIEdgeInsetsZero;
    CGFloat minimumLineSpacing = 0;
    CGFloat minimumInteritemSpacing = 0.0;
    NSUInteger sectionCount = [self.collectionView numberOfSections];
    _attributesArray = [NSMutableArray new];
    _collectionHeightsArray = [NSMutableArray arrayWithCapacity:sectionCount];
    for (int index= 0; index<sectionCount; index++) {
        NSUInteger itemCount = [self.collectionView numberOfItemsInSection:index];
        if (_delegate && [_delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForHeaderInSection:)]) {
            headerH = [_delegate collectionView:self.collectionView layout:self referenceSizeForHeaderInSection:index].height;
        } else {
            headerH = self.headerReferenceSize.height;
        }
        if (_delegate && [_delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForFooterInSection:)]) {
            footerH = [_delegate collectionView:self.collectionView layout:self referenceSizeForFooterInSection:index].height;
        } else {
            footerH = self.footerReferenceSize.height;
        }
        if (_delegate && [_delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
            edgeInsets = [_delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:index];
        } else {
            edgeInsets = self.sectionInset;
        }
        if (_delegate && [_delegate respondsToSelector:@selector(collectionView:layout:minimumLineSpacingForSectionAtIndex:)]) {
            minimumLineSpacing = [_delegate collectionView:self.collectionView layout:self minimumLineSpacingForSectionAtIndex:index];
        } else {
            minimumLineSpacing = self.minimumLineSpacing;
        }
        if (_delegate && [_delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]) {
            minimumInteritemSpacing = [_delegate collectionView:self.collectionView layout:self minimumInteritemSpacingForSectionAtIndex:index];
        } else {
            minimumInteritemSpacing = self.minimumInteritemSpacing;
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(collectionView:layout:registerBackView:)]) {
            NSString* className = [_delegate collectionView:self.collectionView layout:self registerBackView:index];
            if (className != nil && className.length > 0) {
                NSAssert([[NSClassFromString(className) alloc]init]!=nil, @"代理collectionView:layout:registerBackView:里面必须返回有效的类名!");
                [self registerClass:NSClassFromString(className) forDecorationViewOfKind:className];
            } else {
                [self registerClass:[ZLCollectionReusableView class] forDecorationViewOfKind:@"ZLCollectionReusableView"];
            }
        } else {
            [self registerClass:[ZLCollectionReusableView class] forDecorationViewOfKind:@"ZLCollectionReusableView"];
        }
        x = edgeInsets.left;
        y = [self maxHeightWithSection:index];
        
        // 添加页首属性
        if (headerH > 0) {
            NSIndexPath *headerIndexPath = [NSIndexPath indexPathForItem:0 inSection:index];
            ZLCollectionViewLayoutAttributes* headerAttr = [ZLCollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:headerIndexPath];
            headerAttr.frame = CGRectMake(0, y, self.collectionView.frame.size.width, headerH);
            [_attributesArray addObject:headerAttr];
        }
        
        y += headerH ;
        CGFloat itemStartY = y;
        CGFloat lastY = y;
        
        if (itemCount > 0) {
            y += edgeInsets.top;
            ZLLayoutType layoutType = FillLayout;
            if (_delegate && [_delegate respondsToSelector:@selector(collectionView:layout:typeOfLayout:)]) {
                layoutType = [_delegate collectionView:self.collectionView layout:self typeOfLayout:index];
            }
            NSInteger columnCount = 1;
            if (_delegate && [_delegate respondsToSelector:@selector(collectionView:layout:columnCountOfSection:)]) {
                columnCount = [_delegate collectionView:self.collectionView layout:self columnCountOfSection:index];
            }
            // 定义一个列高数组 记录每一列的总高度
            CGFloat *columnHeight = (CGFloat *) malloc(columnCount * sizeof(CGFloat));
            CGFloat itemWidth = 0.0;
            if (layoutType == ClosedLayout) {
                for (int i=0; i<columnCount; i++) {
                    columnHeight[i] = y;
                }
                itemWidth = (totalWidth - edgeInsets.left - edgeInsets.right - minimumInteritemSpacing * (columnCount - 1)) / columnCount;
            }
            CGFloat maxYOfPercent = y;
            CGFloat maxYOfFill = y;
            NSMutableArray* arrayOfPercent = [NSMutableArray new];  //储存百分比布局的数组
            NSMutableArray* arrayOfFill = [NSMutableArray new];     //储存填充式布局的数组
            NSMutableArray* arrayOfAbsolute = [NSMutableArray new]; //储存绝对定位布局的数组
            for (int i=0; i<itemCount; i++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:index];
                CGSize itemSize = CGSizeZero;
                if (_delegate && [_delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]) {
                    itemSize = [_delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
                } else {
                    itemSize = self.itemSize;
                }
                ZLCollectionViewLayoutAttributes *attributes = [ZLCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                
                NSInteger preRow = _attributesArray.count - 1;
                switch (layoutType) {
                    case LabelLayout: {
                        //找上一个cell
                        if(preRow >= 0){
                            if(i > 0) {
                                ZLCollectionViewLayoutAttributes *preAttr = _attributesArray[preRow];
                                x = preAttr.frame.origin.x + preAttr.frame.size.width + minimumInteritemSpacing;
                                if (x + itemSize.width > totalWidth - edgeInsets.right) {
                                    x = edgeInsets.left;
                                    y += itemSize.height + minimumLineSpacing;
                                }
                            }
                        }
                        attributes.frame = CGRectMake(x, y, itemSize.width, itemSize.height);
                    }
                        break;
                    case ClosedLayout: {
                        CGFloat max = CGFLOAT_MAX;
                        NSInteger column = 0;
                        for (int i = 0; i < columnCount; i++) {
                            if (columnHeight[i] < max) {
                                max = columnHeight[i];
                                column = i;
                            }
                        }
                        CGFloat itemX = edgeInsets.left + (itemWidth+minimumInteritemSpacing)*column;
                        CGFloat itemY = columnHeight[column];
                        attributes.frame = CGRectMake(itemX, itemY, itemWidth, itemSize.height);
                        columnHeight[column] += (itemSize.height + minimumLineSpacing);
                    }
                        break;
                    case PercentLayout: {
                        CGFloat percent = 0.0f;
                        if (_delegate && [_delegate respondsToSelector:@selector(collectionView:layout:percentOfRow:)]) {
                            percent = [_delegate collectionView:self.collectionView layout:self percentOfRow:indexPath];
                        } else {
                            percent = 1;
                        }
                        if (percent > 1 || percent <= 0) {
                            percent = 1;
                        }
                        if (arrayOfPercent.count > 0) {
                            CGFloat totalPercent = 0;
                            for (NSDictionary* dic in arrayOfPercent) {
                                totalPercent += [dic[@"percent"] floatValue];
                            }
                            if ((totalPercent+percent) >= 1.0) {
                                if ((totalPercent+percent) < 1.1) {
                                    //小于1.1就当成一行来计算
                                    //先添加进总的数组
                                    attributes.indexPath = indexPath;
                                    attributes.frame = CGRectMake(0, 0, itemSize.width, itemSize.height);
                                    //再添加进计算比例的数组
                                    [arrayOfPercent addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"item":attributes,@"percent":[NSNumber numberWithFloat:percent],@"indexPath":indexPath}]];
                                    if ((totalPercent+percent) > 1) {
                                        NSMutableDictionary* lastDic = [NSMutableDictionary dictionaryWithDictionary:arrayOfPercent.lastObject];
                                        CGFloat lastPercent = 1.0;
                                        for (NSInteger i=0; i<arrayOfPercent.count-1; i++) {
                                            NSMutableDictionary* dic = arrayOfPercent[i];
                                            lastPercent -= [dic[@"percent"] floatValue];
                                        }
                                        lastDic[@"percent"] = [NSNumber numberWithFloat:lastPercent];
                                        [arrayOfPercent replaceObjectAtIndex:arrayOfPercent.count-1 withObject:lastDic];
                                    }
                                    
                                    CGFloat realWidth = totalWidth - edgeInsets.left - edgeInsets.right - (arrayOfPercent.count-1)*minimumInteritemSpacing;
                                    for (NSInteger i=0; i<arrayOfPercent.count; i++) {
                                        NSDictionary* dic = arrayOfPercent[i];
                                        ZLCollectionViewLayoutAttributes *newAttributes = dic[@"item"];
                                        CGFloat itemX = 0.0f;
                                        if (i==0) {
                                            itemX = edgeInsets.left;
                                        } else {
                                            ZLCollectionViewLayoutAttributes *preAttr = arrayOfPercent[i-1][@"item"];
                                            itemX = preAttr.frame.origin.x + preAttr.frame.size.width + minimumInteritemSpacing;
                                        }
                                        newAttributes.frame = CGRectMake(itemX, maxYOfPercent+minimumLineSpacing, realWidth*[dic[@"percent"] floatValue], newAttributes.frame.size.height);
                                        newAttributes.indexPath = dic[@"indexPath"];
                                        //if (![_attributesArray containsObject:newAttributes]) {
                                        [_attributesArray addObject:newAttributes];
                                        //}
                                    }
                                    for (NSInteger i=0; i<arrayOfPercent.count; i++) {
                                        NSDictionary* dic = arrayOfPercent[i];
                                        ZLCollectionViewLayoutAttributes *item = dic[@"item"];
                                        if ((item.frame.origin.y + item.frame.size.height) > maxYOfPercent) {
                                            maxYOfPercent = (item.frame.origin.y + item.frame.size.height);
                                        }
                                    }
                                    [arrayOfPercent removeAllObjects];
                                } else {
                                    //先添加进总的数组
                                    attributes.indexPath = indexPath;
                                    attributes.frame = CGRectMake(0, maxYOfPercent, itemSize.width, itemSize.height);
                                    //再添加进计算比例的数组
                                    [arrayOfPercent addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"item":attributes,@"percent":[NSNumber numberWithFloat:percent],@"indexPath":indexPath}]];
                                    //如果该行item总比例还是小于1，但是item已经是最后一个
                                    if (i==itemCount-1) {
                                        CGFloat realWidth = totalWidth - edgeInsets.left - edgeInsets.right - (arrayOfPercent.count-1)*minimumInteritemSpacing;
                                        for (NSInteger i=0; i<arrayOfPercent.count; i++) {
                                            NSDictionary* dic = arrayOfPercent[i];
                                            ZLCollectionViewLayoutAttributes *newAttributes = dic[@"item"];
                                            CGFloat itemX = 0.0f;
                                            if (i==0) {
                                                itemX = edgeInsets.left;
                                            } else {
                                                ZLCollectionViewLayoutAttributes *preAttr = arrayOfPercent[i-1][@"item"];
                                                itemX = preAttr.frame.origin.x + preAttr.frame.size.width + minimumInteritemSpacing;
                                            }
                                            newAttributes.frame = CGRectMake(itemX, maxYOfPercent+minimumLineSpacing, realWidth*[dic[@"percent"] floatValue], newAttributes.frame.size.height);
                                            newAttributes.indexPath = dic[@"indexPath"];
                                            [_attributesArray addObject:newAttributes];
                                        }
                                        for (NSInteger i=0; i<arrayOfPercent.count; i++) {
                                            NSDictionary* dic = arrayOfPercent[i];
                                            ZLCollectionViewLayoutAttributes *item = dic[@"item"];
                                            if ((item.frame.origin.y + item.frame.size.height) > maxYOfPercent) {
                                                maxYOfPercent = (item.frame.origin.y + item.frame.size.height);
                                            }
                                        }
                                        [arrayOfPercent removeAllObjects];
                                    }
                                }
                            } else {
                                //先添加进总的数组
                                attributes.indexPath = indexPath;
                                NSDictionary* lastDicForPercent = arrayOfPercent[arrayOfPercent.count-1];
                                ZLCollectionViewLayoutAttributes *lastAttributesForPercent = lastDicForPercent[@"item"];
                                attributes.frame = CGRectMake(lastAttributesForPercent.frame.origin.x+lastAttributesForPercent.frame.size.width+minimumInteritemSpacing, lastAttributesForPercent.frame.origin.y, itemSize.width, itemSize.height);
                                //再添加进计算比例的数组
                                [arrayOfPercent addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"item":attributes,@"percent":[NSNumber numberWithFloat:percent],@"indexPath":indexPath}]];
                                //如果已经是最后一个
                                if (i==itemCount-1) {
                                    CGFloat realWidth = totalWidth - edgeInsets.left - edgeInsets.right - (arrayOfPercent.count-1)*minimumInteritemSpacing;
                                    for (NSInteger i=0; i<arrayOfPercent.count; i++) {
                                        NSDictionary* dic = arrayOfPercent[i];
                                        ZLCollectionViewLayoutAttributes *newAttributes = dic[@"item"];
                                        CGFloat itemX = 0.0f;
                                        if (i==0) {
                                            itemX = edgeInsets.left;
                                        } else {
                                            ZLCollectionViewLayoutAttributes *preAttr = arrayOfPercent[i-1][@"item"];
                                            itemX = preAttr.frame.origin.x + preAttr.frame.size.width + minimumInteritemSpacing;
                                        }
                                        newAttributes.frame = CGRectMake(itemX, maxYOfPercent+minimumLineSpacing, realWidth*[dic[@"percent"] floatValue], newAttributes.frame.size.height);
                                        newAttributes.indexPath = dic[@"indexPath"];
                                        //if (![_attributesArray containsObject:newAttributes]) {
                                        [_attributesArray addObject:newAttributes];
                                        //}
                                    }
                                    for (NSInteger i=0; i<arrayOfPercent.count; i++) {
                                        NSDictionary* dic = arrayOfPercent[i];
                                        ZLCollectionViewLayoutAttributes *item = dic[@"item"];
                                        if ((item.frame.origin.y + item.frame.size.height) > maxYOfPercent) {
                                            maxYOfPercent = (item.frame.origin.y + item.frame.size.height);
                                        }
                                    }
                                    [arrayOfPercent removeAllObjects];
                                }
                            }
                        } else {
                            //先添加进总的数组
                            attributes.indexPath = indexPath;
                            attributes.frame = CGRectMake(edgeInsets.left, maxYOfPercent+minimumLineSpacing, itemSize.width, itemSize.height);
                            //再添加进计算比例的数组
                            [arrayOfPercent addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"item":attributes,@"percent":[NSNumber numberWithFloat:percent],@"indexPath":indexPath}]];
                            //如果已经是最后一个
                            if (i==itemCount-1) {
                                CGFloat realWidth = totalWidth - edgeInsets.left - edgeInsets.right - (arrayOfPercent.count-1)*minimumInteritemSpacing;
                                for (NSInteger i=0; i<arrayOfPercent.count; i++) {
                                    NSDictionary* dic = arrayOfPercent[i];
                                    ZLCollectionViewLayoutAttributes *newAttributes = dic[@"item"];
                                    CGFloat itemX = 0.0f;
                                    if (i==0) {
                                        itemX = edgeInsets.left;
                                    } else {
                                        ZLCollectionViewLayoutAttributes *preAttr = arrayOfPercent[i-1][@"item"];
                                        itemX = preAttr.frame.origin.x + preAttr.frame.size.width + minimumInteritemSpacing;
                                    }
                                    newAttributes.frame = CGRectMake(itemX, maxYOfPercent+minimumLineSpacing, realWidth*[dic[@"percent"] floatValue], newAttributes.frame.size.height);
                                    newAttributes.indexPath = dic[@"indexPath"];
                                    [_attributesArray addObject:newAttributes];
                                }
                                for (NSInteger i=0; i<arrayOfPercent.count; i++) {
                                    NSDictionary* dic = arrayOfPercent[i];
                                    ZLCollectionViewLayoutAttributes *item = dic[@"item"];
                                    if ((item.frame.origin.y + item.frame.size.height) > maxYOfPercent) {
                                        maxYOfPercent = (item.frame.origin.y + item.frame.size.height);
                                    }
                                }
                                [arrayOfPercent removeAllObjects];
                            }
                        }
                    }
                        break;
                    case FillLayout: {
                        if (arrayOfFill.count == 0) {
                            attributes.frame = CGRectMake(edgeInsets.left, maxYOfFill, self.isFloor?floor(itemSize.width):itemSize.width, itemSize.height);
                            [arrayOfFill addObject:attributes];
                        } else {
                            NSMutableArray *arrayXOfFill = [NSMutableArray new];
                            [arrayXOfFill addObject:@(edgeInsets.left)];
                            NSMutableArray *arrayYOfFill = [NSMutableArray new];
                            [arrayYOfFill addObject:@(maxYOfFill)];
                            for (ZLCollectionViewLayoutAttributes* attr in arrayOfFill) {
                                if (![arrayXOfFill containsObject:@(attr.frame.origin.x)]) {
                                    [arrayXOfFill addObject:@(attr.frame.origin.x)];
                                }
                                if (![arrayXOfFill containsObject:@(attr.frame.origin.x+attr.frame.size.width)]) {
                                    [arrayXOfFill addObject:@(attr.frame.origin.x+attr.frame.size.width)];
                                }
                                if (![arrayYOfFill containsObject:@(attr.frame.origin.y)]) {
                                    [arrayYOfFill addObject:@(attr.frame.origin.y)];
                                }
                                if (![arrayYOfFill containsObject:@(attr.frame.origin.y+attr.frame.size.height)]) {
                                    [arrayYOfFill addObject:@(attr.frame.origin.y+attr.frame.size.height)];
                                }
                            }
                            [arrayXOfFill sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                                return [obj1 floatValue] > [obj2 floatValue];
                            }];
                            [arrayYOfFill sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                                return [obj1 floatValue] > [obj2 floatValue];
                            }];
                            BOOL qualified = YES;
                            for (NSNumber* yFill in arrayYOfFill) {
                                for (NSNumber* xFill in arrayXOfFill) {
                                    qualified = YES;
                                    attributes.frame = CGRectMake([xFill floatValue]==edgeInsets.left?[xFill floatValue]:[xFill floatValue]+minimumInteritemSpacing, [yFill floatValue]==maxYOfFill?[yFill floatValue]:[yFill floatValue]+minimumLineSpacing, self.isFloor?floor(itemSize.width):itemSize.width, itemSize.height);
                                    if (attributes.frame.origin.x+attributes.frame.size.width > totalWidth-edgeInsets.right) {
                                        qualified = NO;
                                        break;
                                    }
                                    for (ZLCollectionViewLayoutAttributes* attr in arrayOfFill) {
                                        if (CGRectIntersectsRect(attributes.frame, attr.frame)) {
                                            qualified = NO;
                                            break;
                                        }
                                    }
                                    if (qualified == NO) {
                                        continue;
                                    } else {
                                        CGPoint leftPt = CGPointMake(attributes.frame.origin.x - minimumInteritemSpacing, attributes.frame.origin.y);
                                        CGRect leftRect = CGRectZero;
                                        for (ZLCollectionViewLayoutAttributes* attr in arrayOfFill) {
                                            if (CGRectContainsPoint(attr.frame, leftPt)) {
                                                leftRect = attr.frame;
                                                break;
                                            }
                                        }
                                        if (CGRectEqualToRect(leftRect, CGRectZero)) {
                                            break;
                                        } else {
                                            if (attributes.frame.origin.x - (leftRect.origin.x + leftRect.size.width) == minimumInteritemSpacing) {
                                                break;
                                            } else {
                                                CGRect rc = attributes.frame;
                                                rc.origin.x = leftRect.origin.x + leftRect.size.width + minimumInteritemSpacing;
                                                attributes.frame = rc;
                                                for (ZLCollectionViewLayoutAttributes* attr in arrayOfFill) {
                                                    if (CGRectIntersectsRect(attributes.frame, attr.frame)) {
                                                        qualified = NO;
                                                        break;
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                if (qualified == YES) {
                                    break;
                                }
                            }
                            if (qualified == YES) {
                                //NSLog(@"合格的矩形区域=%@",NSStringFromCGRect(attributes.frame));
                            }
                            [arrayOfFill addObject:attributes];
                        }
                    }
                        break;
                    case AbsoluteLayout: {
                        CGRect itemFrame = CGRectZero;
                        if (_delegate && [_delegate respondsToSelector:@selector(collectionView:layout:rectOfItem:)]) {
                            itemFrame = [_delegate collectionView:self.collectionView layout:self rectOfItem:indexPath];
                        }
                        CGFloat absolute_x = edgeInsets.left+itemFrame.origin.x;
                        CGFloat absolute_y = y+itemFrame.origin.y;
                        CGFloat absolute_w = itemFrame.size.width;
                        if ((absolute_x+absolute_w>self.collectionView.frame.size.width-edgeInsets.right)&&(absolute_x<self.collectionView.frame.size.width-edgeInsets.right)) {
                            absolute_w -= (absolute_x+absolute_w-(self.collectionView.frame.size.width-edgeInsets.right));
                        }
                        CGFloat absolute_h = itemFrame.size.height;
                        attributes.frame = CGRectMake(absolute_x, absolute_y, absolute_w, absolute_h);
                        [arrayOfAbsolute addObject:attributes];
                    }
                        break;
                    default: {
                        NSLog(@"%@",NSStringFromCGRect(attributes.frame));
                    }
                        break;
                }
                if (_delegate && [_delegate respondsToSelector:@selector(collectionView:layout:transformOfItem:)]) {
                    attributes.transform3D = [_delegate collectionView:self.collectionView layout:self transformOfItem:indexPath];
                }
                if (_delegate && [_delegate respondsToSelector:@selector(collectionView:layout:zIndexOfItem:)]) {
                    attributes.zIndex = [_delegate collectionView:self.collectionView layout:self zIndexOfItem:indexPath];
                }
                if (_delegate && [_delegate respondsToSelector:@selector(collectionView:layout:alphaOfItem:)]) {
                    attributes.alpha = [_delegate collectionView:self.collectionView layout:self alphaOfItem:indexPath];
                }
                attributes.indexPath = indexPath;
                if (layoutType != PercentLayout) {
                    //if (![_attributesArray containsObject:attributes]) {
                    [_attributesArray addObject:attributes];
                    //}
                }
                if (layoutType == ClosedLayout) {
                    CGFloat max = 0;
                    for (int i = 0; i < columnCount; i++) {
                        if (columnHeight[i] > max) {
                            max = columnHeight[i];
                        }
                    }
                    lastY = max;
                } else if (layoutType == PercentLayout) {
                    lastY = maxYOfPercent;
                } else if (layoutType == FillLayout) {
                    if (i==itemCount-1) {
                        for (ZLCollectionViewLayoutAttributes* attr in arrayOfFill) {
                            if (maxYOfFill < attr.frame.origin.y+attr.frame.size.height) {
                                maxYOfFill = attr.frame.origin.y+attr.frame.size.height;
                            }
                        }
                    }
                    lastY = maxYOfFill;
                } else if (layoutType == AbsoluteLayout) {
                    if (i==itemCount-1) {
                        for (ZLCollectionViewLayoutAttributes* attr in arrayOfAbsolute) {
                            if (lastY < attr.frame.origin.y+attr.frame.size.height) {
                                lastY = attr.frame.origin.y+attr.frame.size.height;
                            }
                        }
                    }
                } else {
                    lastY = attributes.frame.origin.y + attributes.frame.size.height;
                }
            }
        }
        lastY += edgeInsets.bottom;
        
        if (_delegate && [_delegate respondsToSelector:@selector(collectionView:layout:registerBackView:)]) {
            NSString* className = [_delegate collectionView:self.collectionView layout:self registerBackView:index];
            if (className != nil && className.length > 0) {
                ZLCollectionViewLayoutAttributes *attr = [ZLCollectionViewLayoutAttributes  layoutAttributesForDecorationViewOfKind:className withIndexPath:[NSIndexPath indexPathForRow:0 inSection:index]];
                attr.frame = CGRectMake(0, [self isAttachToTop:index]?itemStartY-headerH:itemStartY, self.collectionView.frame.size.width, lastY-itemStartY+([self isAttachToTop:index]?headerH:0));
                attr.zIndex = -1000;
                [_attributesArray addObject:attr];
                if (_delegate && [_delegate respondsToSelector:@selector(collectionView:layout:loadView:)]) {
                    [_delegate collectionView:self.collectionView layout:self loadView:index];
                }
            } else {
                ZLCollectionViewLayoutAttributes *attr = [ZLCollectionViewLayoutAttributes  layoutAttributesForDecorationViewOfKind:@"ZLCollectionReusableView" withIndexPath:[NSIndexPath indexPathForRow:0 inSection:index]];
                attr.frame = CGRectMake(0, [self isAttachToTop:index]?itemStartY-headerH:itemStartY, self.collectionView.frame.size.width, lastY-itemStartY+([self isAttachToTop:index]?headerH:0));
                attr.color = self.collectionView.backgroundColor;
                if (_delegate && [_delegate respondsToSelector:@selector(collectionView:layout:backColorForSection:)]) {
                    attr.color = [_delegate collectionView:self.collectionView layout:self backColorForSection:index];
                }
                attr.zIndex = -1000;
                [_attributesArray addObject:attr];
            }
        } else {
            ZLCollectionViewLayoutAttributes *attr = [ZLCollectionViewLayoutAttributes  layoutAttributesForDecorationViewOfKind:@"ZLCollectionReusableView" withIndexPath:[NSIndexPath indexPathForRow:0 inSection:index]];
            attr.frame = CGRectMake(0, [self isAttachToTop:index]?itemStartY-headerH:itemStartY, self.collectionView.frame.size.width, lastY-itemStartY+([self isAttachToTop:index]?headerH:0));
            attr.color = self.collectionView.backgroundColor;
            if (_delegate && [_delegate respondsToSelector:@selector(collectionView:layout:backColorForSection:)]) {
                attr.color = [_delegate collectionView:self.collectionView layout:self backColorForSection:index];
            }
            attr.zIndex = -1000;
            [_attributesArray addObject:attr];
        }
        
        // 添加页脚属性
        if (footerH > 0) {
            NSIndexPath *footerIndexPath = [NSIndexPath indexPathForItem:0 inSection:index];
            ZLCollectionViewLayoutAttributes *footerAttr = [ZLCollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:footerIndexPath];
            footerAttr.frame = CGRectMake(0, lastY, self.collectionView.frame.size.width, footerH);
            [_attributesArray addObject:footerAttr];
            lastY += footerH;
        }
        _collectionHeightsArray[index] = [NSNumber numberWithFloat:lastY];
    }
}

#pragma mark - 所有cell和view的布局属性
//sectionheader sectionfooter decorationview collectionviewcell的属性都会走这个方法
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    if (!_attributesArray) {
        return [super layoutAttributesForElementsInRect:rect];
    } else {
        if (self.header_suspension) {
            for (UICollectionViewLayoutAttributes *attriture in _attributesArray) {
                if (![attriture.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) continue;
                NSInteger section = attriture.indexPath.section;
                CGRect frame = attriture.frame;
                if (section == 0) {
                    if (self.collectionView.contentOffset.y > 0 && self.collectionView.contentOffset.y < [self.collectionHeightsArray[0] floatValue]) {
                        frame.origin.y = self.collectionView.contentOffset.y;
                    }
                } else {
                    if (self.collectionView.contentOffset.y > [self.collectionHeightsArray[section-1] floatValue] && self.collectionView.contentOffset.y < [self.collectionHeightsArray[section] floatValue]) {
                        
                        frame.origin.y = self.collectionView.contentOffset.y;
                    }
                }
                attriture.zIndex = 1000+section;
                attriture.frame = frame;
            }
        }
        return _attributesArray;
    }
}

#pragma mark - CollectionView的滚动范围
- (CGSize)collectionViewContentSize
{
    CGFloat footerH = 0.0f;
    if (_delegate && [_delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForFooterInSection:)]) {
        footerH = [_delegate collectionView:self.collectionView layout:self referenceSizeForFooterInSection:_collectionHeightsArray.count-1].height;
    } else {
        footerH = self.footerReferenceSize.height;
    }
    UIEdgeInsets edgeInsets = UIEdgeInsetsZero;
    if (_delegate && [_delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
        edgeInsets = [_delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:_collectionHeightsArray.count-1];
    } else {
        edgeInsets = self.sectionInset;
    }
    if (_collectionHeightsArray.count > 0) {
        return CGSizeMake(self.collectionView.frame.size.width, [_collectionHeightsArray[_collectionHeightsArray.count-1] floatValue]);// + edgeInsets.bottom + footerH);
    } else {
        return CGSizeMake(self.collectionView.frame.size.width, self.collectionView.frame.size.height);
    }
}

/**
 每个区的初始Y坐标
 @param section 区索引
 @return Y坐标
 */
- (CGFloat)maxHeightWithSection:(NSInteger)section {
    if (section>0) {
        return [_collectionHeightsArray[section-1] floatValue];
    } else {
        return 0;
    }
}

- (BOOL)isAttachToTop:(NSInteger)section {
    if (_delegate && [_delegate respondsToSelector:@selector(collectionView:layout:attachToTop:)]) {
        return [_delegate collectionView:self.collectionView layout:self attachToTop:section];
    }
    return NO;
}

#pragma mark 以下是拖动排序的代码
- (void)setCanDrag:(BOOL)canDrag {
    _canDrag = canDrag;
    if (canDrag) {
        if (self.longPress == nil && self.panGesture == nil) {
            [self setUpGestureRecognizers];
        }
    } else {
        [self.collectionView removeGestureRecognizer:self.longPress];
        self.longPress.delegate = nil;
        self.longPress = nil;
        [self.collectionView removeGestureRecognizer:self.panGesture];
        self.panGesture.delegate = nil;
        self.panGesture = nil;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"collectionView"]) {
        if (self.canDrag) {
            [self setUpGestureRecognizers];
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)setUpGestureRecognizers{
    if (self.collectionView == nil) {
        return;
    }
    self.longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
    self.panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanGesture:)];
    self.longPress.delegate = self;
    self.panGesture.delegate = self;
    self.panGesture.maximumNumberOfTouches = 1;
    NSArray *gestures = [self.collectionView gestureRecognizers];
    [gestures enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UILongPressGestureRecognizer class]]) {
            [(UILongPressGestureRecognizer *)obj requireGestureRecognizerToFail:self.longPress];
        }
    }];
    [self.collectionView addGestureRecognizer:self.longPress];
    [self.collectionView addGestureRecognizer:self.panGesture];
}

#pragma mark - gesture
- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress {
    CGPoint location = [longPress locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
    
    if (_cellFakeView != nil) {
        indexPath = self.cellFakeView.indexPath;
    }
    
    if (indexPath == nil) {
        return;
    }
    
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan:{
            // will begin drag item
            self.collectionView.scrollsToTop = NO;
            
            UICollectionViewCell *currentCell = [self.collectionView cellForItemAtIndexPath:indexPath];
            
            self.cellFakeView = [[ZLCellFakeView alloc]initWithCell:currentCell];
            self.cellFakeView.indexPath = indexPath;
            self.cellFakeView.originalCenter = currentCell.center;
            self.cellFakeView.cellFrame = [self layoutAttributesForItemAtIndexPath:indexPath].frame;
            [self.collectionView addSubview:self.cellFakeView];
            
            self.fakeCellCenter = self.cellFakeView.center;
            
            [self invalidateLayout];
            
            [self.cellFakeView pushFowardView];
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
            [self cancelDrag:indexPath];
        default:
            break;
    }
}

// pan gesture
- (void)handlePanGesture:(UIPanGestureRecognizer *)pan {
    _panTranslation = [pan translationInView:self.collectionView];
    if (_cellFakeView != nil) {
        switch (pan.state) {
            case UIGestureRecognizerStateChanged:{
                CGPoint center = _cellFakeView.center;
                center.x = self.fakeCellCenter.x + self.panTranslation.x;
                center.y = self.fakeCellCenter.y + self.panTranslation.y;
                self.cellFakeView.center = center;
                
                [self beginScrollIfNeeded];
                [self moveItemIfNeeded];
            }
                break;
            case UIGestureRecognizerStateCancelled:
            case UIGestureRecognizerStateEnded:
                [self invalidateDisplayLink];
            default:
                break;
        }
    }
}

// gesture recognize delegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    // allow move item
    CGPoint location = [gestureRecognizer locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
    if (!indexPath) {
        return NO;
    }
    
    if ([gestureRecognizer isEqual:self.longPress]){
        return (self.collectionView.panGestureRecognizer.state == UIGestureRecognizerStatePossible || self.collectionView.panGestureRecognizer.state == UIGestureRecognizerStateFailed);
    } else if ([gestureRecognizer isEqual:self.panGesture]){
        return (self.longPress.state != UIGestureRecognizerStatePossible && self.longPress.state != UIGestureRecognizerStateFailed);
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([self.panGesture isEqual:gestureRecognizer]) {
        return [self.longPress isEqual:otherGestureRecognizer];
    } else if ([self.collectionView.panGestureRecognizer isEqual:gestureRecognizer]) {
        return (self.longPress.state != UIGestureRecognizerStatePossible && self.longPress.state != UIGestureRecognizerStateFailed);
    }
    return YES;
}

- (void)cancelDrag:(NSIndexPath *)toIndexPath {
    if (self.cellFakeView == nil) {
        return;
    }
    self.collectionView.scrollsToTop = YES;
    self.fakeCellCenter = CGPointZero;
    [self invalidateDisplayLink];
    [self.cellFakeView pushBackView:^{
        [self.cellFakeView removeFromSuperview];
        self.cellFakeView = nil;
        [self invalidateLayout];
    }];
}

- (void)beginScrollIfNeeded{
    if (self.cellFakeView == nil) {
        return;
    }
    CGFloat offset = self.collectionView.contentOffset.y;
    CGFloat trigerInsetTop = self.collectionView.contentInset.top;
    CGFloat trigerInsetEnd = self.collectionView.contentInset.bottom;
    CGFloat paddingTop = 0;
    CGFloat paddingEnd = 0;
    CGFloat length = self.collectionView.frame.size.height;
    CGFloat fakeCellTopEdge = CGRectGetMinY(self.cellFakeView.frame);
    CGFloat fakeCellEndEdge = CGRectGetMaxY(self.cellFakeView.frame);

    if(fakeCellTopEdge <= offset + paddingTop + trigerInsetTop){
        self.continuousScrollDirection = LewScrollDirctionToTop;
        [self setUpDisplayLink];
    }else if(fakeCellEndEdge >= offset + length - paddingEnd - trigerInsetEnd) {
        self.continuousScrollDirection = LewScrollDirctionToEnd;
        [self setUpDisplayLink];
    }else {
        [self invalidateDisplayLink];
    }
}

// move item
- (void)moveItemIfNeeded {
    NSIndexPath *atIndexPath = nil;
    NSIndexPath *toIndexPath = nil;
    if (self.cellFakeView) {
        atIndexPath = _cellFakeView.indexPath;
        toIndexPath = [self.collectionView indexPathForItemAtPoint:_cellFakeView.center];
    }
    
    if (atIndexPath.section != toIndexPath.section) {
        return;
    }
    
    if (atIndexPath == nil || toIndexPath == nil) {
        return;
    }
    
    if ([atIndexPath isEqual:toIndexPath]) {
        return;
    }
    
    UICollectionViewLayoutAttributes *attribute = nil;//[self layoutAttributesForItemAtIndexPath:toIndexPath];
    for (ZLCollectionViewLayoutAttributes* attr in self.attributesArray) {
        if (attr.indexPath.section == toIndexPath.section && attr.indexPath.item == toIndexPath.item &&
            attr.representedElementKind != UICollectionElementKindSectionHeader &&
            attr.representedElementKind != UICollectionElementKindSectionFooter) {
            attribute = attr;
            break;
        }
    }
    if (attribute != nil) {
        [self.collectionView performBatchUpdates:^{
            self.cellFakeView.indexPath = toIndexPath;
            self.cellFakeView.cellFrame = attribute.frame;
            [self.cellFakeView changeBoundsIfNeeded:attribute.bounds];
            [self.collectionView moveItemAtIndexPath:atIndexPath toIndexPath:toIndexPath];
            if ([_delegate respondsToSelector:@selector(collectionView:layout:didMoveCell:toIndexPath:)]) {
                [_delegate collectionView:self.collectionView layout:self didMoveCell:atIndexPath toIndexPath:toIndexPath];
            }
        } completion:nil];
    }
}

- (void)setUpDisplayLink{
    if (_displayLink) {
        return;
    }
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(continuousScroll)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)invalidateDisplayLink{
    _continuousScrollDirection = LewScrollDirctionStay;
    [_displayLink invalidate];
    _displayLink = nil;
}

- (void)continuousScroll{
    if (_cellFakeView == nil) {
        return;
    }
    
    CGFloat percentage = [self calcTrigerPercentage];
    CGFloat scrollRate = [self scrollValueWithSpeed:10 andPercentage:percentage];
    
    CGFloat offset = 0;
    CGFloat insetTop = 0;
    CGFloat insetEnd = 0;
    CGFloat length = self.collectionView.frame.size.height;
    CGFloat contentLength = self.collectionView.contentSize.height;
    
    if (contentLength + insetTop + insetEnd <= length) {
        return;
    }
    
    if (offset + scrollRate <= -insetTop) {
        scrollRate = -insetTop - offset;
    } else if (offset + scrollRate >= contentLength + insetEnd - length) {
        scrollRate = contentLength + insetEnd - length - offset;
    }
    
    [self.collectionView performBatchUpdates:^{
        if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
            _fakeCellCenter.y += scrollRate;
            CGPoint center = _cellFakeView.center;
            center.y = self.fakeCellCenter.y + self.panTranslation.y;
            _cellFakeView.center = center;
            CGPoint contentOffset = self.collectionView.contentOffset;
            contentOffset.y += scrollRate;
            self.collectionView.contentOffset = contentOffset;
        }else{
            _fakeCellCenter.x += scrollRate;
            CGPoint center = _cellFakeView.center;
            center.x = self.fakeCellCenter.x + self.panTranslation.x;
            _cellFakeView.center = center;
            CGPoint contentOffset = self.collectionView.contentOffset;
            contentOffset.x += scrollRate;
            self.collectionView.contentOffset = contentOffset;
        }
    } completion:nil];
    
    [self moveItemIfNeeded];
}

- (CGFloat)calcTrigerPercentage{
    if (_cellFakeView == nil) {
        return 0;
    }
    CGFloat offset = 0;
    CGFloat offsetEnd = 0 + self.collectionView.frame.size.height;
    CGFloat insetTop = 0;
    CGFloat trigerInsetTop = 0;
    CGFloat trigerInsetEnd = 0;
    CGFloat paddingTop = 0;
    CGFloat paddingEnd = 0;
    
    CGFloat percentage = 0.0;
    
    if (self.continuousScrollDirection == LewScrollDirctionToTop) {
        if (self.cellFakeView) {
            percentage = 1.0 - ((self.cellFakeView.frame.origin.y - (offset + paddingTop)) / trigerInsetTop);
        }
    } else if (self.continuousScrollDirection == LewScrollDirctionToEnd){
        if (self.cellFakeView) {
            percentage = 1.0 - (((insetTop + offsetEnd - paddingEnd) - (self.cellFakeView.frame.origin.y + self.cellFakeView.frame.size.height + insetTop)) / trigerInsetEnd);
        }
    }
    percentage = fmin(1.0f, percentage);
    percentage = fmax(0.0f, percentage);
    return percentage;
}

#pragma mark - getter
- (CGFloat)scrollValueWithSpeed:(CGFloat)speed andPercentage:(CGFloat)percentage{
    CGFloat value = 0.0f;
    switch (_continuousScrollDirection) {
        case LewScrollDirctionStay: {
            return 0.0f;
            break;
        }
        case LewScrollDirctionToTop: {
            value = -speed;
            break;
        }
        case LewScrollDirctionToEnd: {
            value = speed;
            break;
        }
        default: {
            return 0.0f;
        }
    }
    
    CGFloat proofedPercentage = fmax(fmin(1.0f, percentage), 0.0f);
    return value * proofedPercentage;
}

@end

