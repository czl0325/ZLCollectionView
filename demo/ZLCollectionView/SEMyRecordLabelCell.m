//
//  SEMyRecordLabelCell.m
//  Seven
//
//  Created by zhaoliang chen on 2017/6/13.
//  Copyright © 2017年 zhaoliang chen. All rights reserved.
//

#import "SEMyRecordLabelCell.h"

@implementation SEMyRecordLabelCell

+ (NSString *)cellIdentifier {
    return @"SEMyRecordLabelCell";
}

+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath {
    SEMyRecordLabelCell *cell = (SEMyRecordLabelCell*)[collectionView dequeueReusableCellWithReuseIdentifier:[SEMyRecordLabelCell cellIdentifier] forIndexPath:indexPath];
    return cell;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = UIColorFromRGB(0xc4e9ff);
        //self.contentView.layer.cornerRadius = 5;
        //self.contentView.layer.masksToBounds = YES;
        self.contentView.layer.borderColor = [UIColor blackColor].CGColor;
        self.contentView.layer.borderWidth = 0.4;
        
        [self.contentView addSubview:self.backImageView];
        [self.backImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.contentView);
        }];
        
        [self.contentView addSubview:self.labelRecord];
        [self.labelRecord mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self.contentView);
        }];
    }
    return self;
}

- (UIImageView*)backImageView {
    if (!_backImageView) {
        _backImageView = [[UIImageView alloc]init];
        _backImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _backImageView;
}

- (UILabel*)labelRecord {
    if (!_labelRecord) {
        _labelRecord = [[UILabel alloc]init];
        _labelRecord.font = [UIFont boldSystemFontOfSize:15];
        _labelRecord.textAlignment = NSTextAlignmentCenter;
        //_labelRecord.textColor = UIColorFromRGB(0x396a88);
        _labelRecord.textColor = [UIColor blackColor];
    }
    return _labelRecord;
}

@end
