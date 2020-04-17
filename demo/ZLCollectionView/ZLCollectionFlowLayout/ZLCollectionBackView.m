//
//  ZLCollectionBackView.m
//  ZLCollectionView
//
//  Created by zhaoliang chen on 2020/4/17.
//  Copyright © 2020 zhaoliang chen. All rights reserved.
//

#import "ZLCollectionBackView.h"
#import "ZLCollectionViewBackgroundViewLayoutAttributes.h"

@implementation ZLCollectionBackView

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    //设置背景颜色
    ZLCollectionViewBackgroundViewLayoutAttributes *myLayoutAttributes = (ZLCollectionViewBackgroundViewLayoutAttributes*)layoutAttributes;
    if (myLayoutAttributes.eventName.length > 0) {
        SEL selector = NSSelectorFromString(myLayoutAttributes.eventName);
        IMP imp = [self methodForSelector:selector];
        if ([self respondsToSelector:selector]) {
            if (myLayoutAttributes.parameter) {
                void (*func) (id, SEL, id) = (void *)imp;
                func(self,selector,myLayoutAttributes.parameter);
            } else {
                void (*func) (id, SEL) = (void *)imp;
                func(self,selector);
            }
        }
    }
}

@end
