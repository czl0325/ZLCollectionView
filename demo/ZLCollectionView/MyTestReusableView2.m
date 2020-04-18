//
//  MyTestReusableView2.m
//  ZLCollectionView
//
//  Created by zhaoliang chen on 2019/1/9.
//  Copyright © 2019 zhaoliang chen. All rights reserved.
//

#import "MyTestReusableView2.h"
#import "UIImageView+WebCache.h"

@interface MyTestReusableView2()

@property(nonatomic,strong)UIImageView* imgV;
@end

@implementation MyTestReusableView2

- (instancetype)initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
        self.imgV = [[UIImageView alloc]init];
        self.imgV.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:self.imgV];
        [self.imgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
    }
    return self;
}

- (void)updateImageView:(NSString*)url {
    [self.imgV sd_setImageWithURL:[NSURL URLWithString:url]];
}

@end
