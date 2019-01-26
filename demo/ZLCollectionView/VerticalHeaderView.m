//
//  VerticalHeaderView.m
//  ZLCollectionView
//
//  Created by zhaoliang chen on 2019/1/25.
//  Copyright © 2019 zhaoliang chen. All rights reserved.
//

#import "VerticalHeaderView.h"

@implementation VerticalHeaderView

+ (NSString *)headerViewIdentifier {
    return @"VerticalHeaderView";
}

+ (instancetype)headerViewWithCollectionView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath {
    VerticalHeaderView *headerView = (VerticalHeaderView*)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:[VerticalHeaderView headerViewIdentifier] forIndexPath:indexPath];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        
        [self addSubview:self.headerLabel];
        [self.headerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self).insets(UIEdgeInsetsMake(10, 5, 10, 5));
        }];
        
        UIView* line = [[UIView alloc]init];
        line.backgroundColor = UIColorFromRGB(0x666666);
        [self addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(10);
            make.bottom.mas_equalTo(-10);
            make.width.mas_equalTo(0.6);
            make.right.mas_equalTo(self);
        }];
    }
    return self;
}

- (UILabel*)headerLabel {
    if (!_headerLabel) {
        _headerLabel = [[UILabel alloc]init];
        _headerLabel.font = [UIFont systemFontOfSize:12];
        _headerLabel.numberOfLines = 0;
        _headerLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _headerLabel;
}
@end
