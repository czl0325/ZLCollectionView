//
//  ZLCollectionViewLayoutAttributes.m
//  ZLCollectionView
//
//  Created by zhaoliang chen on 2018/7/9.
//  Copyright © 2018年 zhaoliang chen. All rights reserved.
//

#import "ZLCollectionViewLayoutAttributes.h"
#import "ZLCollectionReusableView.h"

@implementation ZLCollectionViewLayoutAttributes
@synthesize orginalFrame = _orginalFrame;

+ (instancetype)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind withIndexPath:(NSIndexPath *)indexPath orginalFrmae:(CGRect)orginalFrame{
    ZLCollectionViewLayoutAttributes *layoutAttributes = [super layoutAttributesForDecorationViewOfKind:decorationViewKind withIndexPath:indexPath];
    [layoutAttributes setValue:[NSValue valueWithCGRect:orginalFrame] forKey:@"orginalFrame"];
    layoutAttributes.frame = orginalFrame;
    return layoutAttributes;
}

-(CGRect)orginalFrame {
    if ([self.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        return _orginalFrame;
    } else {
        return self.frame;
    }
}

- (void)callMethod:(NSDictionary*)dict {
    if (dict == nil) {
        return;
    }
    if ([dict objectForKey:@"className"]) {
        self.className = [dict objectForKey:@"className"];
        if ([[dict objectForKey:@"eventName"] isKindOfClass:[NSString class]]) {
            self.eventName = [dict objectForKey:@"eventName"];
        }
        if ([dict objectForKey:@"parameter"]) {
            self.parameter = [dict objectForKey:@"parameter"];
        }
    }
}

@end
