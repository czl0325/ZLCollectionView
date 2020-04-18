//
//  ZLCollectionReusableView.m
//  ZLCollectionView
//
//  Created by zhaoliang chen on 2018/7/9.
//  Copyright © 2018年 zhaoliang chen. All rights reserved.
//

#import "ZLCollectionReusableView.h"
#import "ZLCollectionViewLayoutAttributes.h"

@interface ZLCollectionReusableView ()

@property(nonatomic,strong)UIImageView* ivBackground;

@end

@implementation ZLCollectionReusableView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.ivBackground];
        self.ivBackground.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:@[
            [NSLayoutConstraint constraintWithItem:self.ivBackground attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0],
            [NSLayoutConstraint constraintWithItem:self.ivBackground attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant: 0.0],
            [NSLayoutConstraint constraintWithItem:self.ivBackground attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant: 0.0],
            [NSLayoutConstraint constraintWithItem:self.ivBackground attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant: 0.0]
            ]];
    }
    return self;
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    //设置背景颜色
    ZLCollectionViewLayoutAttributes *ecLayoutAttributes = (ZLCollectionViewLayoutAttributes*)layoutAttributes;
    if (ecLayoutAttributes.color) {
        self.backgroundColor = ecLayoutAttributes.color;
    }
    if (ecLayoutAttributes.image) {
        self.ivBackground.image = ecLayoutAttributes.image;
    }
}


- (UIImageView*)ivBackground {
    if (!_ivBackground) {
        _ivBackground = [[UIImageView alloc]init];
        _ivBackground.contentMode = UIViewContentModeScaleAspectFill;
        _ivBackground.backgroundColor = [UIColor clearColor];
    }
    return _ivBackground;
}

@end
