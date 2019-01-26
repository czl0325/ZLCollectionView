//
//  SEMyRecordHeaderView.m
//  Seven
//
//  Created by zhaoliang chen on 2017/6/13.
//  Copyright © 2017年 zhaoliang chen. All rights reserved.
//

#import "HorzontalHeaderView.h"

@implementation HorzontalHeaderView

+ (NSString *)headerViewIdentifier {
    return @"HorzontalHeaderView";
}

+ (instancetype)headerViewWithCollectionView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath {
    HorzontalHeaderView *headerView = (HorzontalHeaderView*)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:[HorzontalHeaderView headerViewIdentifier] forIndexPath:indexPath];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.headerLabel];
        [self.headerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self);
            make.left.mas_equalTo(10);
        }];
        
        UIView* line = [[UIView alloc]init];
        line.backgroundColor = UIColorFromRGB(0x666666);
        [self addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(10);
            make.right.mas_equalTo(-10);
            make.height.mas_equalTo(0.6);
            make.bottom.mas_equalTo(self);
        }];
    }
    return self;
}

- (UILabel*)headerLabel {
    if (!_headerLabel) {
        _headerLabel = [[UILabel alloc]init];
        _headerLabel.font = [UIFont systemFontOfSize:12];
    }
    return _headerLabel;
}

@end
