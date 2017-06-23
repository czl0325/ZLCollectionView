//
//  ZLCollectionViewFlowLayout.m
//  ZLCollectionView
//
//  Created by zhaoliang chen on 2017/6/22.
//  Copyright © 2017年 zhaoliang chen. All rights reserved.
//

#import "ZLCollectionViewFlowLayout.h"

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
        
    }
    return self;
}

#pragma mark - 当尺寸有所变化时，重新刷新
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return NO;
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
        x = edgeInsets.left;
        y = [self maxHeightWithSection:index];

        // 添加页首属性
        if (headerH > 0) {
            NSIndexPath *headerIndexPath = [NSIndexPath indexPathForItem:0 inSection:index];
            UICollectionViewLayoutAttributes* headerAttr = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:headerIndexPath];
            headerAttr.frame = CGRectMake(0, y, self.collectionView.frame.size.width, headerH);
            [_attributesArray addObject:headerAttr];
        }
        
        y += headerH ;
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
            for (int i=0; i<itemCount; i++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:index];
                CGSize itemSize = CGSizeZero;
                if (_delegate && [_delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]) {
                    itemSize = [_delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
                } else {
                    itemSize = self.itemSize;
                }
                UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                
                NSInteger preRow = _attributesArray.count - 1;
                switch (layoutType) {
                    case LabelLayout: {
                        //找上一个cell
                        if(preRow >= 0){
                            if(i > 0) {
                                UICollectionViewLayoutAttributes *preAttr = _attributesArray[preRow];
                                x = preAttr.frame.origin.x + preAttr.frame.size.width + minimumLineSpacing;
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
                    default: {
                        
                    }
                        break;
                }
                attributes.indexPath = [NSIndexPath indexPathForRow:i inSection:index];
                [_attributesArray addObject:attributes];
                if (layoutType == ClosedLayout) {
                    CGFloat max = 0;
                    for (int i = 0; i < columnCount; i++) {
                        if (columnHeight[i] > max) {
                            max = columnHeight[i];
                        }
                    }
                    lastY = max;
                } else {
                    lastY = attributes.frame.origin.y + attributes.frame.size.height;
                }
            }
        }
        lastY += edgeInsets.bottom;
        // 添加页脚属性
        if (footerH > 0) {
            NSIndexPath *footerIndexPath = [NSIndexPath indexPathForItem:0 inSection:index];
            UICollectionViewLayoutAttributes *footerAttr = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:footerIndexPath];
            footerAttr.frame = CGRectMake(0, lastY + edgeInsets.bottom, self.collectionView.frame.size.width, footerH);
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
//    for(UICollectionViewLayoutAttributes *attrs1 in array) {
//        if(attrs1.representedElementCategory == UICollectionElementCategoryCell){
//            for (UICollectionViewLayoutAttributes *attrs2 in _attributesArray) {
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
    return CGSizeMake(self.collectionView.frame.size.width, [_collectionHeightsArray[_collectionHeightsArray.count-1] floatValue]);// + edgeInsets.bottom + footerH);
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
