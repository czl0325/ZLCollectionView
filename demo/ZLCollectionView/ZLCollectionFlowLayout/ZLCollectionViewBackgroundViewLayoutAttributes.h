//
//  ZLCollectionViewBackViewLayoutAttributes.h
//  ZLCollectionView
//
//  Created by zhaoliang chen on 2020/4/17.
//  Copyright © 2020 zhaoliang chen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZLCollectionViewBackgroundViewLayoutAttributes : UICollectionViewLayoutAttributes

@property(nonatomic,copy)NSString* eventName;
@property(nonatomic,copy)id parameter;

@end

NS_ASSUME_NONNULL_END
