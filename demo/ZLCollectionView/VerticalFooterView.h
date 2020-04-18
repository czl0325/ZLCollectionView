//
//  VerticalFooterView.h
//  ZLCollectionView
//
//  Created by hqtech on 2020/4/18.
//  Copyright © 2020 zhaoliang chen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VerticalFooterView : UICollectionReusableView

+ (NSString *)footerViewIdentifier;

+ (instancetype)footerViewWithCollectionView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
