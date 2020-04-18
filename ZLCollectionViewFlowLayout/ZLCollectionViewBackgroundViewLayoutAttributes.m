//
//  ZLCollectionViewBackViewLayoutAttributes.m
//  ZLCollectionView
//
//  Created by zhaoliang chen on 2020/4/17.
//  Copyright © 2020 zhaoliang chen. All rights reserved.
//

#import "ZLCollectionViewBackgroundViewLayoutAttributes.h"

@implementation ZLCollectionViewBackgroundViewLayoutAttributes
@synthesize headerFrame = _headerFrame;
@synthesize footerFrame = _footerFrame;

+ (instancetype)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind withIndexPath:(NSIndexPath *)indexPath orginalFrmae:(CGRect)orginalFrame{
    ZLCollectionViewBackgroundViewLayoutAttributes *layoutAttributes = [super layoutAttributesForDecorationViewOfKind:decorationViewKind withIndexPath:indexPath];
    [layoutAttributes setValue:[NSValue valueWithCGRect:orginalFrame] forKey:@"orginalFrame"];
    layoutAttributes.frame = orginalFrame;
    return layoutAttributes;
}

-(CGRect)orginalFrame {
    if ([self.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        return _headerFrame;
    } else if ([self.representedElementKind isEqualToString:UICollectionElementKindSectionFooter]) {
        return _footerFrame;
    } else {
        return self.frame;
    }
}

- (void)callMethod:(ZLBaseEventModel*)eventModel {
    NSAssert([eventModel isKindOfClass:[ZLBaseEventModel class]], @"callMethod必须传入ZLBaseEventModel类型参数");
    if (eventModel == nil) {
        return;
    }
    if (eventModel.eventName != nil) {
        self.eventName = eventModel.eventName;
    }
    if (eventModel.parameter) {
        self.parameter = eventModel.parameter;
    }
}

@end
