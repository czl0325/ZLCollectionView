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
@property(nonatomic,strong)NSArray* arrayMyMenus;
@property(nonatomic,strong)NSArray* arrayMyTaboos;
@property(nonatomic,strong)NSArray* arrayNumbers;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    _arrayMyActivitys = @[@"超轻体力活动(程序员)",@"轻体力活动(学生,白领)",@"中体力活动(业务员,普通工人)",@"重体力活动(运动员,装卸工)"];
    _arrayMyMenus = @[@"川菜",@"湘菜",@"粤菜",@"闽菜",@"浙菜",@"鲁菜",@"徽菜",@"清真菜",@"全素菜"];
    _arrayMyTaboos = @[@"无",@"牛奶",@"蛋类",@"虾、蟹、贝"];
    _arrayNumbers = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14"];
    
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
    return 6;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return _arrayMyActivitys.count;
        case 1:
            return _arrayMyMenus.count;
        case 2:
            return _arrayMyTaboos.count;
        case 3:
            return 6;
        case 4:
            return _arrayNumbers.count;
        default:
            return 10;
    }
}


- (ZLLayoutType)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewFlowLayout *)collectionViewLayout typeOfLayout:(NSInteger)section {
    if (section < 3) {
        return LabelLayout;
    } else {
        return ClosedLayout;
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SEMyRecordLabelCell* cell = [SEMyRecordLabelCell cellWithCollectionView:collectionView forIndexPath:indexPath];
    switch (indexPath.section) {
        case 0: {
            cell.labelRecord.text = _arrayMyActivitys[indexPath.row];
        }
            break;
        case 1: {
            cell.labelRecord.text = _arrayMyMenus[indexPath.row];
        }
            break;
        case 2: {
            cell.labelRecord.text = _arrayMyTaboos[indexPath.row];
        }
            break;
        default: {
            cell.backgroundColor = [UIColor colorWithRed:(random()%256)/255.0 green:(random()%256)/255.0 blue:(random()%256)/255.0 alpha:1.0];
            cell.labelRecord.text = _arrayNumbers[indexPath.row];
        }
            break;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            return CGSizeMake([_arrayMyActivitys[indexPath.row] boundingRectWithSize:CGSizeMake(1000000, 20) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]} context:nil].size.width + 30, 30);
        }
        case 1: {
            return CGSizeMake([_arrayMyMenus[indexPath.row] boundingRectWithSize:CGSizeMake(1000000, 20) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]} context:nil].size.width + 30, 30);
        }
        case 2:{
            return CGSizeMake([_arrayMyTaboos[indexPath.row] boundingRectWithSize:CGSizeMake(1000000, 20) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]} context:nil].size.width + 30, 30);
        }
        case 3: {
            return CGSizeMake(50, 50);
        }
        case 4: {
            return CGSizeMake(50, 50 + arc4random()%300);
        }
        case 5: {
            return CGSizeMake(collectionView.frame.size.width, 50);
        }
        default:
            return CGSizeZero;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(ZLCollectionViewFlowLayout*)collectionViewLayout columnCountOfSection:(NSInteger)section {
    switch (section) {
        case 3:
            return 3;
        case 4:
            return 2;
        case 5:
            return 1;
        default:
            return 0;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    switch (section) {
        case 0:
        case 1:
        case 2:
        case 4:
            return 10;
        default:
            return 0;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    switch (section) {
        case 0:
        case 1:
        case 2:
        case 4:
            return 10;
        default:
            return 0;
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    switch (section) {
        case 5:
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
                headerView.labelMyRecord.text = @"您的每日运动量属于:";
                headerView.btnModifyRecord.hidden = YES;
                break;
            case 1:
                headerView.labelMyRecord.text = @"您常食用菜系是(多选):";
                headerView.btnModifyRecord.hidden = YES;
                break;
            case 2:
                headerView.labelMyRecord.text = @"您的饮食禁忌有(多选):";
                headerView.btnModifyRecord.hidden = YES;
                break;
            case 3:
                headerView.labelMyRecord.text = @"正方形格子:";
                headerView.btnModifyRecord.hidden = YES;
                break;
            case 4:
                headerView.labelMyRecord.text = @"瀑布流:";
                headerView.btnModifyRecord.hidden = YES;
                break;
            case 5:
                headerView.labelMyRecord.text = @"列表数据:";
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
