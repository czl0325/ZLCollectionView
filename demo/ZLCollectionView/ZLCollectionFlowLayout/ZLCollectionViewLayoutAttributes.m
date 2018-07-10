//
//  ZLCollectionViewLayoutAttributes.m
//  ZLCollectionView
//
//  Created by zhaoliang chen on 2018/7/9.
//  Copyright © 2018年 zhaoliang chen. All rights reserved.
//

#import "ZLCollectionViewLayoutAttributes.h"
#import "ZLCollectionReusableView.h"

@implementation ZLCollectionViewLayoutAttributes

+ (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind withIndexPath:(NSIndexPath *)indexPath {
    ZLCollectionViewLayoutAttributes *layoutAttributes = [super layoutAttributesForDecorationViewOfKind:decorationViewKind withIndexPath:indexPath];
    return layoutAttributes;
}

@end
