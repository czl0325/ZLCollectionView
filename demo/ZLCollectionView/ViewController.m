//
//  ViewController.m
//  ZLCollectionView
//
//  Created by zhaoliang chen on 2017/6/22.
//  Copyright © 2017年 zhaoliang chen. All rights reserved.
//

#import "ViewController.h"
#import "ZLCollectionViewFlowLayout.h"
#import "SEMyRecordLabelCell.h"
#import "SEMyRecordHeaderView.h"

@interface ViewController ()
<UICollectionViewDelegate,UICollectionViewDataSource,ZLCollectionViewFlowLayoutDelegate>

@property(nonatomic,strong)UICollectionView* collectionViewLabel;
@property(nonatomic,strong)NSArray* arrayMyActivitys;
@property(nonatomic,strong)NSMutableArray* arraySeats;      //电影座位的数组

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    _arrayMyActivitys = @[@"超轻体力活动(程序员)",@"轻体力活动(学生,白领)",@"中体力活动(业务员,普通工人)",@"重体力活动(运动员,装卸工)"];
    
    _arraySeats = [NSMutableArray new];
    NSInteger column = ([UIScreen mainScreen].bounds.size.width-20)/30;
    for (int i=0; i<80; i++) {
        if (i%column==2 || i%column==column-2) {
            continue;
        }
        if ((i/column==2&&i%column<2)
            ||(i/column==2&&i%column>column-2)
            ||(i/column==3&&i%column<2)
            ||(i/column==3&&i%column>column-2)) {
            continue;
        }
        BOOL select = NO;
        if (i>=29&&i<=36) {
            select = YES;
        }
        [_arraySeats addObject:@{
                                 @"frame":NSStringFromCGRect(CGRectMake((i%column)*30, 100+(i/column)*30, 20, 20)),
                                 @"select":@(select)
                                 }];
    }
    
    [self.view addSubview:self.collectionViewLabel];
    [self.collectionViewLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 10;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return _arrayMyActivitys.count;
        case 1:
            return 4;
        case 2:
            return 13;
        case 3:
            return 5;
        case 4:
            return _arraySeats.count+1;
        case 5:
            return 9;
        case 6:
            return 3;
        case 7:
            return 8;
        default:
            return 10;
    }
}

- (ZLLayoutType)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewFlowLayout *)collectionViewLayout typeOfLayout:(NSInteger)section {
    switch (section) {
        case 0:
            return LabelLayout;
        case 1:
        case 2:
            return FillLayout;
        case 3:
        case 4:
            return AbsoluteLayout;
        case 5:
        case 6:
            return PercentLayout;
        default:
            return ClosedLayout;
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SEMyRecordLabelCell* cell = [SEMyRecordLabelCell cellWithCollectionView:collectionView forIndexPath:indexPath];
    switch (indexPath.section) {
        case 0: {
            cell.backImageView.image = nil;
            cell.contentView.backgroundColor = UIColorFromRGB(0xc4e9ff);;
            cell.contentView.layer.borderWidth = 0.4;
            cell.labelRecord.text = _arrayMyActivitys[indexPath.row];
        }
            break;
        case 4: {
            if (indexPath.item == 0) {
                cell.backImageView.image = nil;
                cell.contentView.layer.borderWidth = 0.4;
                cell.contentView.backgroundColor = [UIColor grayColor];
                cell.labelRecord.text = @"屏幕";
            } else {
                NSDictionary* dic = _arraySeats[indexPath.item-1];
                if ([dic[@"select"] boolValue]==YES) {
                    cell.backImageView.image = [UIImage imageNamed:@"seat_select"];
                } else {
                    cell.backImageView.image = [UIImage imageNamed:@"seat"];
                }
                cell.contentView.layer.borderWidth = 0.0;
                cell.contentView.backgroundColor = [UIColor whiteColor];
                cell.labelRecord.text = @"";
            }
        }
            break;
        default: {
            cell.backImageView.image = nil;
            cell.contentView.layer.borderWidth = 0.4;
            cell.contentView.backgroundColor = [UIColor colorWithRed:(random()%256)/255.0 green:(random()%256)/255.0 blue:(random()%256)/255.0 alpha:1.0];
            cell.labelRecord.text = [NSString stringWithFormat:@"%zd",indexPath.item];
        }
            break;
    }
    return cell;
}

//如果是百分比布局必须实现该代理，设置每个item的百分比，如果没实现默认比例为1
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewFlowLayout*)collectionViewLayout percentOfRow:(NSIndexPath*)indexPath; {
    switch (indexPath.section) {
        case 5: {
            switch (indexPath.item) {
                case 0:
                    return 1.0/3;
                case 1:
                    return 2.0/3;
                case 2:
                    return 1.0/3;
                case 3:
                    return 1.0/3;
                case 4:
                    return 1.0/3;
                case 5:
                    return 1.0/4;
                case 6:
                    return 1.0/4;
                case 7:
                    return 1.0/2;
                case 8:
                    return 3.0/5;
                case 9:
                    return 2.0/5;
                default:
                    break;
            }
        }
        case 6: {
            if (indexPath.item % 2==0) {
                return 3.0/4;
            } else {
                return 1.0/4;
            }
        }
        default:
            return 1;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"点击了section=%zd，item=%zd",indexPath.section,indexPath.item);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            return CGSizeMake([_arrayMyActivitys[indexPath.row] boundingRectWithSize:CGSizeMake(1000000, 20) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:15]} context:nil].size.width + 30, 30);
        }
        case 1: {
            switch (indexPath.item) {
                case 0:
                    return CGSizeMake(150, 200);
                case 1:
                case 2:
                    return CGSizeMake((collectionView.frame.size.width-20-150)/2, 100);
                default:
                    return CGSizeMake((collectionView.frame.size.width-20-150), 100);
            }
        }
        case 2:{
            switch (indexPath.item) {
                case 2:
                    return CGSizeMake(150, 140);
                case 5:
                    return CGSizeMake((collectionView.frame.size.width-20-150)/2, 70);
                case 8:
                case 11:
                    return CGSizeMake(100, 240);
                case 10:
                    return CGSizeMake(collectionView.frame.size.width-20-200, 140);
                case 9:
                case 12:
                    return CGSizeMake(collectionView.frame.size.width-20-100, 100);
                default:
                    return CGSizeMake((collectionView.frame.size.width-20-150)/4, 70);
            }
        }
        case 5:
            if (indexPath.item == 2) {
                return CGSizeMake(50, 200);
            }
            return CGSizeMake(50, 120);
        case 6: {
            return CGSizeMake(50, 120);
        }
        case 7: {
            return CGSizeMake(50, 80);
        }
        case 8: {
            return CGSizeMake(50, 50 + arc4random()%300);
        }
        case 9: {
            return CGSizeMake(collectionView.frame.size.width, 100);
        }
        default:
            return CGSizeZero;
    }
}

//如果是ClosedLayout样式的section，必须实现该代理，指定列数
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewFlowLayout*)collectionViewLayout columnCountOfSection:(NSInteger)section {
    switch (section) {
        case 7:
            return 4;
        case 8:
            return 2;
        case 9:
            return 1;
        default:
            return 0;
    }
}

//如果是绝对定位布局必须是否该代理，设置每个item的frame
- (CGRect)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewFlowLayout*)collectionViewLayout rectOfItem:(NSIndexPath*)indexPath {
    switch (indexPath.section) {
        case 3: {
            CGFloat width = (collectionView.frame.size.width-200)/2;
            CGFloat height = width;
            switch (indexPath.item) {
                case 0:
                    return CGRectMake(0, 0, width, height);
                case 1:
                    return CGRectMake(width, 0, width, height);
                case 2:
                    return CGRectMake(0, height, width, height);
                case 3:
                    return CGRectMake(width, height, width, height);
                case 4:
                    return CGRectMake(width/2, height/2, width, height);
                default:
                    return CGRectZero;
            }
        }
            break;
        case 4: {
            switch (indexPath.item) {
                case 0:
                    return CGRectMake((collectionView.frame.size.width-20)/2-100, 0, 200, 30);
                default: {
//                    NSInteger column = (collectionView.frame.size.width-20)/30;
//                    return CGRectMake(((indexPath.item-1)%column)*30, 100+((indexPath.item-1)/column)*30, 20, 20);
                    NSDictionary* dic = _arraySeats[indexPath.item-1];
                    return CGRectFromString(dic[@"frame"]);
                }
                    
            }
        }
            break;
        default:
            return CGRectZero;
    }
    return CGRectZero;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewFlowLayout *)collectionViewLayout zIndexOfItem:(NSIndexPath*)indexPath {
    switch (indexPath.section) {
        case 3: {
            switch (indexPath.item) {
                case 4:
                    return 1000;
                default:
                    return 0;
            }
        }
            break;
        default:
            return 0;
    }
}

- (CATransform3D)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewFlowLayout *)collectionViewLayout transformOfItem:(NSIndexPath*)indexPath {
    switch (indexPath.section) {
        case 3:
            switch (indexPath.item) {
                case 4:
                    return CATransform3DMakeRotation(M_PI_4, 0, 0, 1);
                default:
                    break;
            }
            break;
        default:
            break;
    }
    return CATransform3DIdentity;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    switch (section) {
        case 0:
//        case 1:
//        case 2:
        case 8:
            return 10;
//        case 3:
//        case 4:
//            return 5;
        default:
            return 0;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    switch (section) {
        case 0:
//        case 1:
//        case 2:
        case 8:
            return 10;
        default:
            return 0;
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    switch (section) {
        case 3:
            return UIEdgeInsetsMake(10, 100, 10, 100);
        case 9:
            return UIEdgeInsetsZero;
        default:
            return UIEdgeInsetsMake(10, 10, 10, 10);
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString : UICollectionElementKindSectionHeader]){
        SEMyRecordHeaderView* headerView = [SEMyRecordHeaderView headerViewWithCollectionView:collectionView forIndexPath:indexPath];
        switch (indexPath.section) {
            case 0:
                headerView.labelMyRecord.text = @"标签页布局:";
                headerView.btnModifyRecord.hidden = YES;
                break;
            case 1:
                headerView.labelMyRecord.text = @"填充式布局1:";
                headerView.btnModifyRecord.hidden = YES;
                break;
            case 2:
                headerView.labelMyRecord.text = @"填充式布局2:";
                headerView.btnModifyRecord.hidden = YES;
                break;
            case 3:
                headerView.labelMyRecord.text = @"绝对定位布局1:";
                headerView.btnModifyRecord.hidden = YES;
                break;
            case 4:
                headerView.labelMyRecord.text = @"绝对定位布局2(用于电影选座):";
                headerView.btnModifyRecord.hidden = YES;
                break;
            case 5:
                headerView.labelMyRecord.text = @"百分比布局1:";
                headerView.btnModifyRecord.hidden = YES;
                break;
            case 6:
                headerView.labelMyRecord.text = @"百分比布局2:";
                headerView.btnModifyRecord.hidden = YES;
                break;
            case 7:
                headerView.labelMyRecord.text = @"正方形格子(采用瀑布流布局，设置间距为0):";
                headerView.btnModifyRecord.hidden = YES;
                break;
            case 8:
                headerView.labelMyRecord.text = @"瀑布流:";
                headerView.btnModifyRecord.hidden = YES;
                break;
            case 9:
                headerView.labelMyRecord.text = @"列表数据(采用瀑布流布局，设置只有1列):";
                headerView.btnModifyRecord.hidden = YES;
                break;
            default:
                break;
        }
        return headerView;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(collectionView.frame.size.width, 30);
}

- (UIColor*)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewFlowLayout *)collectionViewLayout backColorForSection:(NSInteger)section {
    return [UIColor colorWithRed:(random()%256)/255.0 green:(random()%256)/255.0 blue:(random()%256)/255.0 alpha:1.0];
}

- (UICollectionView*)collectionViewLabel {
    if (!_collectionViewLabel) {
        ZLCollectionViewFlowLayout *flowLayout = [[ZLCollectionViewFlowLayout alloc] init];
        flowLayout.delegate = self;
        
        _collectionViewLabel = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
        _collectionViewLabel.dataSource = self;
        _collectionViewLabel.delegate = self;
        _collectionViewLabel.backgroundColor = [UIColor whiteColor];
        [_collectionViewLabel registerClass:[SEMyRecordLabelCell class] forCellWithReuseIdentifier:[SEMyRecordLabelCell cellIdentifier]];
        [_collectionViewLabel registerClass:[SEMyRecordHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:[SEMyRecordHeaderView headerViewIdentifier]];
    }
    return _collectionViewLabel;
}

@end
