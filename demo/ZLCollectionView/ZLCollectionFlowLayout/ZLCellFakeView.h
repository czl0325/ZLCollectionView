//
//  ZLCellFakeView.h
//  ZLCollectionView
//
//  Created by zhaoliang chen on 2018/7/25.
//  Copyright © 2018年 zhaoliang chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZLCellFakeView : UIView

@property (nonatomic, weak)UICollectionViewCell *cell;
@property (nonatomic, strong)UIImageView *cellFakeImageView;
@property (nonatomic, strong)UIImageView *cellFakeHightedView;
@property (nonatomic, strong)NSIndexPath *indexPath;
@property (nonatomic, assign)CGPoint originalCenter;
@property (nonatomic, assign)CGRect cellFrame;

- (instancetype)initWithCell:(UICollectionViewCell *)cell;
- (void)changeBoundsIfNeeded:(CGRect)bounds;
- (void)pushFowardView;
- (void)pushBackView:(void(^)(void))completion;

@end
