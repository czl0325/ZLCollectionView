//
//  ZLCollectionViewBackViewLayoutAttributes.h
//  ZLCollectionView
//
//  Created by zhaoliang chen on 2020/4/17.
//  Copyright © 2020 zhaoliang chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLBaseEventModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZLCollectionViewBackgroundViewLayoutAttributes : UICollectionViewLayoutAttributes

//此属性只是header会单独设置，其他均直接返回其frame属性
@property(nonatomic,assign,readonly)CGRect headerFrame;
@property(nonatomic,assign,readonly)CGRect footerFrame;

@property(nonatomic,copy)NSString* eventName;
@property(nonatomic,copy)id parameter;

- (void)callMethod:(ZLBaseEventModel*)eventModel;

@end

NS_ASSUME_NONNULL_END
