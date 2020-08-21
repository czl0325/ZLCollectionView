//
//  ZLCollectionBackView.m
//  ZLCollectionView
//
//  Created by zhaoliang chen on 2020/4/17.
//  Copyright © 2020 zhaoliang chen. All rights reserved.
//

#import "ZLCollectionBaseDecorationView.h"
#import "ZLCollectionViewBackgroundViewLayoutAttributes.h"
#import <objc/runtime.h>

@implementation ZLCollectionBaseDecorationView

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    //设置背景颜色
    ZLCollectionViewBackgroundViewLayoutAttributes *myLayoutAttributes = (ZLCollectionViewBackgroundViewLayoutAttributes*)layoutAttributes;
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList([self class], &methodCount);
    if ([myLayoutAttributes isKindOfClass:[ZLCollectionViewBackgroundViewLayoutAttributes class]] && myLayoutAttributes.eventName != nil && myLayoutAttributes.eventName.length > 0) {
        for(int i = 0; i < methodCount; i++) {
            Method method = methods[i];
            SEL sel = method_getName(method);
            const char *name = sel_getName(sel);
            NSString* methodName = [NSString stringWithUTF8String:name];
            if ([methodName isEqualToString:myLayoutAttributes.eventName]) {
                //object_setClass(self, newClass);
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
               break;
            };
        }
    }
    free(methods);
}

@end
