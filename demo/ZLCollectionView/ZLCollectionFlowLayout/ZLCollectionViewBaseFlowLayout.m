//
//  ZLCollectionViewBaseFlowLayout.m
//  ZLCollectionView
//
//  Created by zhaoliang chen on 2019/1/25.
//  Copyright © 2019 zhaoliang chen. All rights reserved.
//

#import "ZLCollectionViewBaseFlowLayout.h"
#import "ZLCollectionViewLayoutAttributes.h"
#import "ZLCellFakeView.h"

typedef NS_ENUM(NSUInteger, LewScrollDirction) {
    LewScrollDirctionStay,
    LewScrollDirctionToTop,
    LewScrollDirctionToEnd,
};

@interface ZLCollectionViewBaseFlowLayout ()
<UIGestureRecognizerDelegate>

//关于拖动的参数
@property (nonatomic, strong) ZLCellFakeView *cellFakeView;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, assign) CGPoint fakeCellCenter;
@property (nonatomic, assign) CGPoint panTranslation;
@property (nonatomic) LewScrollDirction continuousScrollDirection;
@property (nonatomic, strong) CADisplayLink *displayLink;

@end

@implementation ZLCollectionViewBaseFlowLayout {
    BOOL _isNeedReCalculateAllLayout;
}

- (instancetype)init {
    if (self == [super init]) {
        self.isFloor = YES;
        self.canDrag = NO;
        self.header_suspension = NO;
        self.layoutType = FillLayout;
        self.columnCount = 1;
        self.columnSortType = minHeight;
        self.fixTop = 0;
        self.xBeyond = 3;
        _isNeedReCalculateAllLayout = YES;
        _headerAttributesArray = @[].mutableCopy;
        [self addObserver:self forKeyPath:@"collectionView" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

#pragma mark - 当尺寸有所变化时，重新刷新
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return self.header_suspension;
}

//+ (Class)layoutAttributesClass {
//    return [ZLCollectionViewLayoutAttributes class];
//}

- (void)invalidateLayoutWithContext:(UICollectionViewLayoutInvalidationContext *)context {
    //外部调用relaodData或变更任意数据时则认为需要进行全量布局的刷新
    //好处是在外部变更数据时内部布局会及时刷新
    //劣势是在你在上拉加载某一页时,布局会全部整体重新计算一遍,并非只计算新增的布局
    _isNeedReCalculateAllLayout = context.invalidateEverything || context.invalidateDataSourceCounts;
    [super invalidateLayoutWithContext:context];
}

// 注册所有的背景view(传入类名)
- (void)registerDecorationView:(NSArray<NSString*>*)classNames {
    for (NSString* className in classNames) {
        if (className.length > 0) {
            [self registerClass:NSClassFromString(className) forDecorationViewOfKind:className];
        }
    }
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"collectionView"];
}

#pragma mark - 所有cell和view的布局属性
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    if (!self.attributesArray || self.collectionView.numberOfSections == 0) {
        return [super layoutAttributesForElementsInRect:rect];
    } else {
        if (self.header_suspension) {
            //只在headerAttributesArray里面查找需要悬浮的属性
            for (UICollectionViewLayoutAttributes *attriture in self.headerAttributesArray) {
                if (![attriture.representedElementKind isEqualToString:UICollectionElementKindSectionHeader])
                    continue;
                NSInteger section = attriture.indexPath.section;
                CGRect frame = attriture.frame;
                BOOL isNeedChangeFrame = NO;
                if (section == 0) {
                    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
                        CGFloat offsetY = self.collectionView.contentOffset.y + self.fixTop;
                        if (offsetY > 0 && offsetY < [self.collectionHeightsArray[0] floatValue]) {
                            frame.origin.y = offsetY;
                            attriture.zIndex = 1000+section;
                            attriture.frame = frame;
                            isNeedChangeFrame = YES;
                        }
                    } else {
                        CGFloat offsetX = self.collectionView.contentOffset.y + self.fixTop;
                        if (offsetX > 0 && offsetX < [self.collectionHeightsArray[0] floatValue]) {
                            frame.origin.x = offsetX;
                            attriture.zIndex = 1000+section;
                            attriture.frame = frame;
                            isNeedChangeFrame = YES;
                        }
                    }
                } else {
                    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
                        CGFloat offsetY = self.collectionView.contentOffset.y + self.fixTop;
                        if (offsetY > [self.collectionHeightsArray[section-1] floatValue] &&
                            offsetY < [self.collectionHeightsArray[section] floatValue]) {
                            frame.origin.y = offsetY;
                            attriture.zIndex = 1000+section;
                            attriture.frame = frame;
                            isNeedChangeFrame = YES;
                        }
                    } else {
                        CGFloat offsetX = self.collectionView.contentOffset.y + self.fixTop;
                        if (offsetX > [self.collectionHeightsArray[section-1] floatValue] &&
                            offsetX < [self.collectionHeightsArray[section] floatValue]) {
                            frame.origin.x = offsetX;
                            attriture.zIndex = 1000+section;
                            attriture.frame = frame;
                            isNeedChangeFrame = YES;
                        }
                    }
                }
                
                if (!isNeedChangeFrame) {
                    /*
                     这里需要注意，在悬浮的情况下改变了headerAtt的frame
                     在滑出header又滑回来时,headerAtt已经被修改过，需要改回原始值
                     否则header无法正确归位
                     */
                    if ([attriture isKindOfClass:[ZLCollectionViewLayoutAttributes class]]) {
                        attriture.frame = ((ZLCollectionViewLayoutAttributes*)attriture).orginalFrame;
                    }
                }
            }
        }
        return self.attributesArray;
    }
}

// 1.4.8暂时去掉layoutAttributesForItemAtIndexPath方法
//- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
//    UICollectionViewLayoutAttributes *layoutAttributes = (UICollectionViewLayoutAttributes*)self.attributesArray[indexPath.item];
//    if(!layoutAttributes) {
//        layoutAttributes = [super layoutAttributesForItemAtIndexPath:indexPath];
//    }
//    return layoutAttributes;
//}

/**

 */

#pragma mark 以下是拖动排序的代码
- (void)setCanDrag:(BOOL)canDrag {
    _canDrag = canDrag;
    if (canDrag) {
        if (self.longPress == nil && self.panGesture == nil) {
            [self setUpGestureRecognizers];
        }
    } else {
        [self.collectionView removeGestureRecognizer:self.longPress];
        self.longPress.delegate = nil;
        self.longPress = nil;
        [self.collectionView removeGestureRecognizer:self.panGesture];
        self.panGesture.delegate = nil;
        self.panGesture = nil;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"collectionView"]) {
        if (self.canDrag) {
            [self setUpGestureRecognizers];
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)setUpGestureRecognizers{
    if (self.collectionView == nil) {
        return;
    }
    self.longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
    self.panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanGesture:)];
    self.longPress.delegate = self;
    self.panGesture.delegate = self;
    self.panGesture.maximumNumberOfTouches = 1;
    NSArray *gestures = [self.collectionView gestureRecognizers];
    __weak typeof(ZLCollectionViewBaseFlowLayout*) weakSelf = self;
    [gestures enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UILongPressGestureRecognizer class]]) {
            [(UILongPressGestureRecognizer *)obj requireGestureRecognizerToFail:weakSelf.longPress];
        }
    }];
    [self.collectionView addGestureRecognizer:self.longPress];
    [self.collectionView addGestureRecognizer:self.panGesture];
}

#pragma mark - gesture
- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress {
    CGPoint location = [longPress locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
    
    //    __weak typeof(ZLCollectionViewBaseFlowLayout*) weakSelf = self;
    //    if ([weakSelf.delegate respondsToSelector:@selector(collectionView:layout:shouldMoveCell:)]) {
    //        if ([weakSelf.delegate collectionView:weakSelf.collectionView layout:weakSelf shouldMoveCell:indexPath] == NO) {
    //            return;
    //        }
    //    }
    
    if (_cellFakeView != nil) {
        indexPath = self.cellFakeView.indexPath;
    }
    
    if (indexPath == nil) {
        return;
    }
    
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan:{
            // will begin drag item
            self.collectionView.scrollsToTop = NO;
            
            UICollectionViewCell *currentCell = [self.collectionView cellForItemAtIndexPath:indexPath];
            
            self.cellFakeView = [[ZLCellFakeView alloc]initWithCell:currentCell];
            self.cellFakeView.indexPath = indexPath;
            self.cellFakeView.originalCenter = currentCell.center;
            self.cellFakeView.cellFrame = [self layoutAttributesForItemAtIndexPath:indexPath].frame;
            [self.collectionView addSubview:self.cellFakeView];
            
            self.fakeCellCenter = self.cellFakeView.center;
            
            [self invalidateLayout];
            
            [self.cellFakeView pushFowardView];
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
            [self cancelDrag:indexPath];
        default:
            break;
    }
}

// pan gesture
- (void)handlePanGesture:(UIPanGestureRecognizer *)pan {
    _panTranslation = [pan translationInView:self.collectionView];
    if (_cellFakeView != nil) {
        switch (pan.state) {
            case UIGestureRecognizerStateChanged:{
                CGPoint center = _cellFakeView.center;
                center.x = self.fakeCellCenter.x + self.panTranslation.x;
                center.y = self.fakeCellCenter.y + self.panTranslation.y;
                self.cellFakeView.center = center;
                [self beginScrollIfNeeded];
                [self moveItemIfNeeded];
            }
                break;
            case UIGestureRecognizerStateCancelled:
            case UIGestureRecognizerStateEnded:
                [self invalidateDisplayLink];
            default:
                break;
        }
    }
}

// gesture recognize delegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    // allow move item
    CGPoint location = [gestureRecognizer locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
    if (!indexPath) {
        return NO;
    }
    
    if ([gestureRecognizer isEqual:self.longPress]){
        return (self.collectionView.panGestureRecognizer.state == UIGestureRecognizerStatePossible || self.collectionView.panGestureRecognizer.state == UIGestureRecognizerStateFailed);
    } else if ([gestureRecognizer isEqual:self.panGesture]){
        return (self.longPress.state != UIGestureRecognizerStatePossible && self.longPress.state != UIGestureRecognizerStateFailed);
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([self.panGesture isEqual:gestureRecognizer]) {
        return [self.longPress isEqual:otherGestureRecognizer];
    } else if ([self.collectionView.panGestureRecognizer isEqual:gestureRecognizer]) {
        return (self.longPress.state != UIGestureRecognizerStatePossible && self.longPress.state != UIGestureRecognizerStateFailed);
    }
    return YES;
}

- (void)cancelDrag:(NSIndexPath *)toIndexPath {
    if (self.cellFakeView == nil) {
        return;
    }
    self.collectionView.scrollsToTop = YES;
    self.fakeCellCenter = CGPointZero;
    [self invalidateDisplayLink];
    
    __weak typeof(ZLCollectionViewBaseFlowLayout*) weakSelf = self;
    [self.cellFakeView pushBackView:^{
        [weakSelf.cellFakeView removeFromSuperview];
        weakSelf.cellFakeView = nil;
        [weakSelf invalidateLayout];
    }];
}

- (void)beginScrollIfNeeded{
    if (self.cellFakeView == nil) {
        return;
    }
    CGFloat offset = self.scrollDirection == UICollectionViewScrollDirectionVertical ? self.collectionView.contentOffset.y : self.collectionView.contentOffset.x;
    CGFloat trigerInsetTop = self.scrollDirection == UICollectionViewScrollDirectionVertical ? self.collectionView.contentInset.top: self.collectionView.contentInset.left;
    CGFloat trigerInsetEnd = self.scrollDirection == UICollectionViewScrollDirectionVertical ? self.collectionView.contentInset.bottom : self.collectionView.contentInset.right;
    CGFloat paddingTop = 0;
    CGFloat paddingEnd = 0;
    CGFloat length = self.scrollDirection == UICollectionViewScrollDirectionVertical ? self.collectionView.frame.size.height : self.collectionView.frame.size.width;
    CGFloat fakeCellTopEdge = self.scrollDirection == UICollectionViewScrollDirectionVertical ? CGRectGetMinY(self.cellFakeView.frame) : CGRectGetMinX(self.cellFakeView.frame);
    CGFloat fakeCellEndEdge = self.scrollDirection == UICollectionViewScrollDirectionVertical ? CGRectGetMaxY(self.cellFakeView.frame) : CGRectGetMaxX(self.cellFakeView.frame);
    
    if(fakeCellTopEdge <= offset + paddingTop + trigerInsetTop){
        self.continuousScrollDirection = LewScrollDirctionToTop;
        [self setUpDisplayLink];
    }else if(fakeCellEndEdge >= offset + length - paddingEnd - trigerInsetEnd) {
        self.continuousScrollDirection = LewScrollDirctionToEnd;
        [self setUpDisplayLink];
    }else {
        [self invalidateDisplayLink];
    }
}

// move item
- (void)moveItemIfNeeded {
    NSIndexPath *atIndexPath = nil;
    NSIndexPath *toIndexPath = nil;
    __weak typeof(ZLCollectionViewBaseFlowLayout*) weakSelf = self;
    
    if (self.cellFakeView) {
        atIndexPath = _cellFakeView.indexPath;
        toIndexPath = [self.collectionView indexPathForItemAtPoint:_cellFakeView.center];
    }
    
    if (atIndexPath.section != toIndexPath.section) {
        return;
    }
    
    //    if ([weakSelf.delegate respondsToSelector:@selector(collectionView:layout:shouldMoveCell:)]) {
    //        if ([weakSelf.delegate collectionView:weakSelf.collectionView layout:weakSelf shouldMoveCell:toIndexPath] == NO) {
    //            return;
    //        }
    //    }
    
    if (atIndexPath == nil || toIndexPath == nil) {
        return;
    }
    
    if ([atIndexPath isEqual:toIndexPath]) {
        return;
    }
    
    UICollectionViewLayoutAttributes *attribute = nil;//[self layoutAttributesForItemAtIndexPath:toIndexPath];
    for (ZLCollectionViewLayoutAttributes* attr in weakSelf.attributesArray) {
        if (attr.indexPath.section == toIndexPath.section && attr.indexPath.item == toIndexPath.item &&
            attr.representedElementKind != UICollectionElementKindSectionHeader &&
            attr.representedElementKind != UICollectionElementKindSectionFooter) {
            attribute = attr;
            break;
        }
    }
    //NSLog(@"拖动从%@到%@",atIndexPath,toIndexPath);
    if (attribute != nil) {
        [self.collectionView performBatchUpdates:^{
            weakSelf.cellFakeView.indexPath = toIndexPath;
            weakSelf.cellFakeView.cellFrame = attribute.frame;
            [weakSelf.cellFakeView changeBoundsIfNeeded:attribute.bounds];
            [weakSelf.collectionView moveItemAtIndexPath:atIndexPath toIndexPath:toIndexPath];
            if ([weakSelf.delegate respondsToSelector:@selector(collectionView:layout:didMoveCell:toIndexPath:)]) {
                [weakSelf.delegate collectionView:weakSelf.collectionView layout:weakSelf didMoveCell:atIndexPath toIndexPath:toIndexPath];
            }
        } completion:nil];
    }
}

- (void)setUpDisplayLink{
    if (_displayLink) {
        return;
    }
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(continuousScroll)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)invalidateDisplayLink{
    _continuousScrollDirection = LewScrollDirctionStay;
    [_displayLink invalidate];
    _displayLink = nil;
}

- (void)continuousScroll{
    if (_cellFakeView == nil) {
        return;
    }
    
    CGFloat percentage = [self calcTrigerPercentage];
    CGFloat scrollRate = [self scrollValueWithSpeed:10 andPercentage:percentage];
    
    CGFloat offset = 0;
    CGFloat insetTop = 0;
    CGFloat insetEnd = 0;
    CGFloat length = self.scrollDirection == UICollectionViewScrollDirectionVertical ?  self.collectionView.frame.size.height : self.collectionView.frame.size.width;
    CGFloat contentLength = self.scrollDirection == UICollectionViewScrollDirectionVertical ? self.collectionView.contentSize.height : self.collectionView.contentSize.width;
    
    if (contentLength + insetTop + insetEnd <= length) {
        return;
    }
    
    if (offset + scrollRate <= -insetTop) {
        scrollRate = -insetTop - offset;
    } else if (offset + scrollRate >= contentLength + insetEnd - length) {
        scrollRate = contentLength + insetEnd - length - offset;
    }
    
    __weak typeof(ZLCollectionViewBaseFlowLayout*) weakSelf = self;
    [self.collectionView performBatchUpdates:^{
        if (weakSelf.scrollDirection == UICollectionViewScrollDirectionVertical) {
            CGPoint point = weakSelf.fakeCellCenter;
            point.y += scrollRate;
            weakSelf.fakeCellCenter = point;
            CGPoint center = weakSelf.cellFakeView.center;
            center.y = weakSelf.fakeCellCenter.y + weakSelf.panTranslation.y;
            weakSelf.cellFakeView.center = center;
            CGPoint contentOffset = weakSelf.collectionView.contentOffset;
            contentOffset.y += scrollRate;
            weakSelf.collectionView.contentOffset = contentOffset;
        } else {
            CGPoint point = weakSelf.fakeCellCenter;
            point.x += scrollRate;
            weakSelf.fakeCellCenter = point;
            //_fakeCellCenter.x += scrollRate;
            CGPoint center = weakSelf.cellFakeView.center;
            center.x = weakSelf.fakeCellCenter.x + weakSelf.panTranslation.x;
            weakSelf.cellFakeView.center = center;
            CGPoint contentOffset = weakSelf.collectionView.contentOffset;
            contentOffset.x += scrollRate;
            weakSelf.collectionView.contentOffset = contentOffset;
        }
    } completion:nil];
    
    [self moveItemIfNeeded];
}

- (CGFloat)calcTrigerPercentage{
    if (_cellFakeView == nil) {
        return 0;
    }
    CGFloat offset = 0;
    CGFloat offsetEnd = 0 + self.scrollDirection == UICollectionViewScrollDirectionVertical ? self.collectionView.frame.size.height : self.collectionView.frame.size.width;
    CGFloat insetTop = 0;
    CGFloat trigerInsetTop = 0;
    CGFloat trigerInsetEnd = 0;
    CGFloat paddingTop = 0;
    CGFloat paddingEnd = 0;
    
    CGFloat percentage = 0.0;
    
    if (self.continuousScrollDirection == LewScrollDirctionToTop) {
        if (self.cellFakeView) {
            percentage = 1.0 - (((self.scrollDirection == UICollectionViewScrollDirectionVertical ? self.cellFakeView.frame.origin.y : self.cellFakeView.frame.origin.x) - (offset + paddingTop)) / trigerInsetTop);
        }
    } else if (self.continuousScrollDirection == LewScrollDirctionToEnd){
        if (self.cellFakeView) {
            percentage = 1.0 - (((insetTop + offsetEnd - paddingEnd) - ((self.scrollDirection == UICollectionViewScrollDirectionVertical ? self.cellFakeView.frame.origin.y : self.cellFakeView.frame.origin.x) + (self.scrollDirection == UICollectionViewScrollDirectionVertical ? self.cellFakeView.frame.size.height : self.cellFakeView.frame.size.width) + insetTop)) / trigerInsetEnd);
        }
    }
    percentage = fmin(1.0f, percentage);
    percentage = fmax(0.0f, percentage);
    return percentage;
}

#pragma mark - getter
- (CGFloat)scrollValueWithSpeed:(CGFloat)speed andPercentage:(CGFloat)percentage{
    CGFloat value = 0.0f;
    switch (_continuousScrollDirection) {
        case LewScrollDirctionStay: {
            return 0.0f;
            break;
        }
        case LewScrollDirctionToTop: {
            value = -speed;
            break;
        }
        case LewScrollDirctionToEnd: {
            value = speed;
            break;
        }
        default: {
            return 0.0f;
        }
    }
    
    CGFloat proofedPercentage = fmax(fmin(1.0f, percentage), 0.0f);
    return value * proofedPercentage;
}
- (void)forceSetIsNeedReCalculateAllLayout:(BOOL)isNeedReCalculateAllLayout
{
    _isNeedReCalculateAllLayout = isNeedReCalculateAllLayout;
}
@end
