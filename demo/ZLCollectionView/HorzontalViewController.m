//
//  HorzontalViewController.m
//  ZLCollectionView
//
//  Created by zhaoliang chen on 2019/1/25.
//  Copyright © 2019 zhaoliang chen. All rights reserved.
//

#import "HorzontalViewController.h"
#import "ZLCollectionFlowLayout/ZLCollectionViewHorzontalLayout.h"
#import "MultilineTextCell.h"
#import "VerticalHeaderView.h"
#import "UICollectionView+ARDynamicCacheHeightLayoutCell.h"

@interface HorzontalViewController ()
<UICollectionViewDelegate,UICollectionViewDataSource,ZLCollectionViewBaseFlowLayoutDelegate>

@property(nonatomic,strong)UICollectionView* collectionViewLabel;
@property(nonatomic,strong)NSArray* array1;

@end

@implementation HorzontalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"横向UICollectionView布局";
    
    self.array1 = @[@"国际电联秘书长说国际电联与中国合作前景广阔",@"支付宝集五福开启，柔宇炮轰小米折叠屏造假",@"「亚洲杯」三中卫犯重大失误 国足0比3伊朗无缘四强",@"谭松韵母亲因遭遇严重车祸去世，她去年5月发的一条微博让人泪目"];
    
    self.view.backgroundColor = [UIColor colorWithRed:200.0/255 green:200.0/255 blue:200.0/255 alpha:1.0];
    
    [self.view addSubview:self.collectionViewLabel];
    [self.collectionViewLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, 200, 0));
    }];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 4;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return self.array1.count;
        case 1:
            return 8;
        case 2:
            return 5;
        default:
            return 10;
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MultilineTextCell* cell = [MultilineTextCell cellWithCollectionView:collectionView forIndexPath:indexPath];
    if (indexPath.section == 0) {
        cell.label.text = self.array1[indexPath.item];
        cell.contentView.backgroundColor = [UIColor yellowColor];
    } else {
        cell.label.text = [NSString stringWithFormat:@"%zd",indexPath.item];
        cell.contentView.backgroundColor = [UIColor colorWithRed:(random()%256)/255.0 green:(random()%256)/255.0 blue:(random()%256)/255.0 alpha:1.0];
    }
    return cell;
}

- (ZLLayoutType)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewBaseFlowLayout *)collectionViewLayout typeOfLayout:(NSInteger)section {
    switch (section) {
        case 0: {
            return LabelVerticalLayout;
        }
        default:
            return ColumnLayout;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewBaseFlowLayout *)collectionViewLayout columnCountOfSection:(NSInteger)section {
    switch (section) {
        case 1: {
            return 4;
        }
        case 2: {
            return 2;
        }
        default:
            return 1;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewBaseFlowLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(30, collectionView.frame.size.height);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString : UICollectionElementKindSectionHeader]){
        VerticalHeaderView* headerView = [VerticalHeaderView headerViewWithCollectionView:collectionView forIndexPath:indexPath];
        switch (indexPath.section) {
            case 0:
                headerView.headerLabel.text = @"竖向标签页布局";
                break;
            case 1:
                headerView.headerLabel.text = @"横向列布局";
                break;
            case 2:
                headerView.headerLabel.text = @"横向瀑布流布局";
                break;
            case 3:
                headerView.headerLabel.text = @"横向列表布局";
                break;
        }
        return headerView;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewBaseFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            NSString* text = self.array1[indexPath.item];
            return CGSizeMake(25, text.length*15+20);
        }
        case 1: {
            return CGSizeMake(100, 100);
        }
        case 2: {
            return CGSizeMake(100+indexPath.item*50, 100);
        }
        default:
            return CGSizeMake(120, collectionView.frame.size.height);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewBaseFlowLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    switch (section) {
        case 0:
        case 2:
            return 10;
        default:
            return 0;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewBaseFlowLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    switch (section) {
        case 0:
        case 2:
            return 10;
        default:
            return 0;
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewBaseFlowLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (UIColor*)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewBaseFlowLayout *)collectionViewLayout backColorForSection:(NSInteger)section {
    if (section == 0) {
        return [UIColor redColor];
    } else if (section == 1) {
        return [UIColor purpleColor];
    } else {
        return [UIColor orangeColor];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewBaseFlowLayout *)collectionViewLayout attachToTop:(NSInteger)section {
    if (section%2==0) {
        return YES;
    }
    return NO;
}

- (UICollectionView *)collectionViewLabel{
    if(!_collectionViewLabel){
        _collectionViewLabel = ({
            ZLCollectionViewHorzontalLayout* layout = [[ZLCollectionViewHorzontalLayout alloc]init];
            layout.delegate = self;
            layout.canDrag = YES;
            layout.header_suspension = YES;
            
            UICollectionView * object = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
            object.delegate = self;
            object.dataSource = self;
            object.alwaysBounceHorizontal = YES;
            object.backgroundColor = [UIColor whiteColor];
            [object registerClass:[MultilineTextCell class] forCellWithReuseIdentifier:@"MultilineTextCell"];
            [object registerClass:[VerticalHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:[VerticalHeaderView headerViewIdentifier]];
            object;
       });
    }
    return _collectionViewLabel;
}
@end
