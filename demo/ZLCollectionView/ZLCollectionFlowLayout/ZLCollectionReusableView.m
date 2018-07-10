//
//  ZLCollectionReusableView.m
//  ZLCollectionView
//
//  Created by zhaoliang chen on 2018/7/9.
//  Copyright © 2018年 zhaoliang chen. All rights reserved.
//

#import "ZLCollectionReusableView.h"
#import "ZLCollectionViewLayoutAttributes.h"

@implementation ZLCollectionReusableView

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    //设置背景颜色
    ZLCollectionViewLayoutAttributes *ecLayoutAttributes = (ZLCollectionViewLayoutAttributes*)layoutAttributes;
    self.backgroundColor = ecLayoutAttributes.color;
}

@end
