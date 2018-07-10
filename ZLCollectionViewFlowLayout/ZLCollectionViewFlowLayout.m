//
//  ZLCollectionViewFlowLayout.m
//  ZLCollectionView
//
//  Created by zhaoliang chen on 2017/6/22.
//  Copyright © 2017年 zhaoliang chen. All rights reserved.
//

#import "ZLCollectionViewFlowLayout.h"
#import "ZLCollectionViewLayoutAttributes.h"
#import "ZLCollectionReusableView.h"

@interface ZLCollectionViewFlowLayout()
//每个section的每一列的高度
@property (nonatomic, retain) NSMutableArray *collectionHeightsArray;
//存放每一个cell的属性
@property (nonatomic, retain) NSMutableArray *attributesArray;

@end

@implementation ZLCollectionViewFlowLayout

#pragma mark - 初始化属性
- (instancetype)init {
    self = [super init];
    if (self) {
        self.isFloor = YES;
    }
    return self;
}

#pragma mark - 当尺寸有所变化时，重新刷新
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return NO;
}

+ (Class)layoutAttributesClass {
    return [ZLCollectionViewLayoutAttributes class];
}

- (void)prepareLayout {
    [super prepareLayout];
    
    [self registerClass:[ZLCollectionReusableView class] forDecorationViewOfKind:@"ZLCollectionReusableView"];
    
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
            ZLLayoutType layoutType = BaseLayout;
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
        
        ZLCollectionViewLayoutAttributes *attr = [ZLCollectionViewLayoutAttributes  layoutAttributesForDecorationViewOfKind:@"ZLCollectionReusableView" withIndexPath:[NSIndexPath indexPathForRow:0 inSection:index]];
        attr.frame = CGRectMake(0, itemStartY, self.collectionView.frame.size.width, lastY-itemStartY);
        attr.color = self.collectionView.backgroundColor;
        if (_delegate && [_delegate respondsToSelector:@selector(collectionView:layout:backColorForSection:)]) {
            attr.color = [_delegate collectionView:self.collectionView layout:self backColorForSection:index];
        }
        attr.zIndex = -1000;
        
//        attr.backgroudColor = [delegate collectionView:self.collectionView layout:self colorForSectionAtIndex:section];
        [_attributesArray addObject:attr];
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
        return _attributesArray;
    }
    //    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    //    for(ZLCollectionViewLayoutAttributes *attrs1 in array) {
    //        if(attrs1.representedElementCategory == UICollectionElementCategoryCell){
    //            for (ZLCollectionViewLayoutAttributes *attrs2 in _attributesArray) {
    //                if (attrs1.indexPath.section == attrs2.indexPath.section && attrs1.indexPath.row == attrs2.indexPath.row) {
    //                    attrs1.frame = attrs2.frame;
    //                    break;
    //                }
    //            }
    //        }
    //    }
    //    return array;
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


@end

