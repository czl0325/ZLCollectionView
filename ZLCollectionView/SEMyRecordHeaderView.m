//
//  SEMyRecordHeaderView.m
//  Seven
//
//  Created by zhaoliang chen on 2017/6/13.
//  Copyright © 2017年 zhaoliang chen. All rights reserved.
//

#import "SEMyRecordHeaderView.h"

@implementation SEMyRecordHeaderView

@synthesize onMyRecordModify;

+ (NSString *)headerViewIdentifier {
    return @"SEMyRecordHeaderView";
}

+ (instancetype)headerViewWithCollectionView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath {
    SEMyRecordHeaderView *headerView = (SEMyRecordHeaderView*)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:[SEMyRecordHeaderView headerViewIdentifier] forIndexPath:indexPath];
    return headerView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.labelMyRecord];
        [self.labelMyRecord mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self);
            make.left.mas_equalTo(10);
        }];
        
        [self addSubview:self.btnModifyRecord];
        [self.btnModifyRecord mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self);
            make.right.mas_equalTo(-10);
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

- (void)onClickModify {
    if (onMyRecordModify) {
        onMyRecordModify();
    }
}

- (UILabel*)labelMyRecord {
    if (!_labelMyRecord) {
        _labelMyRecord = [[UILabel alloc]init];
        _labelMyRecord.font = [UIFont systemFontOfSize:12];
        _labelMyRecord.textColor = UIColorFromRGB(0x666666);
    }
    return _labelMyRecord;
}

- (UIButton*)btnModifyRecord {
    if (!_btnModifyRecord) {
        _btnModifyRecord = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnModifyRecord setImage:[UIImage imageNamed:@"SE_record_modify"] forState:UIControlStateNormal];
        [_btnModifyRecord setTitle:@"修改" forState:UIControlStateNormal];
        [_btnModifyRecord setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
        _btnModifyRecord.titleLabel.font = [UIFont systemFontOfSize:10];
        [_btnModifyRecord addTarget:self action:@selector(onClickModify) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnModifyRecord;
}

@end
