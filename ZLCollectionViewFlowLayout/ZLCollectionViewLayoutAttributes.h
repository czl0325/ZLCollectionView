//
//  ZLCollectionViewLayoutAttributes.h
//  ZLCollectionView
//
//  Created by zhaoliang chen on 2018/7/9.
//  Copyright © 2018年 zhaoliang chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZLCollectionViewLayoutAttributes : UICollectionViewLayoutAttributes

@property(nonatomic,copy)UIColor* color;
@property(nonatomic,copy)UIImage* image;

//此属性只是header会单独设置，其他均直接返回其frame属性
@property(nonatomic,assign,readonly)CGRect orginalFrame;



@end
