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
        
        [self updateImageView];
    }
    return self;
}

- (void)updateImageView {
    [self.imgV sd_setImageWithURL:[NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1547035180781&di=ad7e771ee99afc06b9280062c13b3cd9&imgtype=0&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201508%2F14%2F20150814165156_iAvkx.jpeg"]];
}

@end
