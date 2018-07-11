//
//  MyTestReusableView.m
//  ZLCollectionView
//
//  Created by zhaoliang chen on 2018/7/11.
//  Copyright © 2018年 zhaoliang chen. All rights reserved.
//

#import "MyTestReusableView.h"

@implementation MyTestReusableView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView* imgV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"xingkong"]];
        imgV.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:imgV];
        [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
    }
    return self;
}

@end
