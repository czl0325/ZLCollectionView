//
//  ZLCollectionReusableView.m
//  ZLCollectionView
//
//  Created by zhaoliang chen on 2018/7/9.
//  Copyright © 2018年 zhaoliang chen. All rights reserved.
//

#import "ZLCollectionReusableView.h"
#import "ZLCollectionViewLayoutAttributes.h"
#import <objc/runtime.h>
#import "MyTestReusableView2.h"

@implementation ZLCollectionReusableView

- (instancetype)init {
    if (self == [super init]) {
        
    }
    return self;
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    //设置背景颜色
    ZLCollectionViewLayoutAttributes *ecLayoutAttributes = (ZLCollectionViewLayoutAttributes*)layoutAttributes;
    self.backgroundColor = ecLayoutAttributes.color;
    unsigned int methodCount = 0;
    Class newClass = NSClassFromString(ecLayoutAttributes.className);
    Method *methods = class_copyMethodList(newClass, &methodCount);
    if (ecLayoutAttributes.eventName != nil && ecLayoutAttributes.eventName.length > 0) {
        for(int i = 0; i < methodCount; i++) {
            Method method = methods[i];
            SEL sel = method_getName(method);
            const char *name = sel_getName(sel);
            NSString* methodName = [NSString stringWithUTF8String:name];
            if ([methodName isEqualToString:ecLayoutAttributes.eventName]) {
                object_setClass(self, newClass);
                SEL selector = NSSelectorFromString(ecLayoutAttributes.eventName);
                IMP imp = [self methodForSelector:selector];
                if ([self respondsToSelector:selector]) {
                    if (ecLayoutAttributes.parameter) {
                        void (*func) (id, SEL, id) = (void *)imp;
                        func(self,selector,ecLayoutAttributes.parameter);
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
