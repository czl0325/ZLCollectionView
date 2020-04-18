//
//  VerticalFooterView.m
//  ZLCollectionView
//
//  Created by hqtech on 2020/4/18.
//  Copyright © 2020 zhaoliang chen. All rights reserved.
//

#import "VerticalFooterView.h"

@implementation VerticalFooterView

+ (NSString *)footerViewIdentifier {
    return @"VerticalFooterView";
}

+ (instancetype)footerViewWithCollectionView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath {
    VerticalFooterView *footerView = (VerticalFooterView*)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:[VerticalFooterView footerViewIdentifier] forIndexPath:indexPath];
    footerView.backgroundColor = [UIColor clearColor];
    return footerView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        
        UILabel* label = [UILabel new];
        label.font = [UIFont boldSystemFontOfSize:16];
        label.text = @"这是footerView";
        [self addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self);
        }];
    }
    return self;
}

@end
