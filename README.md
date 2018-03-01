# ZLCollectionView

为应对类似淘宝首页，京东首页，国美首页的复杂布局而写的多样化的UICollectionView。
目前支持标签布局，列布局，百分比布局，定位布局等。可以根据不同的section设置不同的布局。实现了电影选座等高难度的布局。

如在使用中有bug欢迎反馈，如果有愿意帮我完善源代码的也十分感谢。
我的QQ 295183917

# 更新

## v0.3.0  (2018.3.1)
   新增加了绝对定位布局，自己定义每个item的位置，可以做层叠布局，电影选座布局等等，详细操作请见demo

## v0.2.0  (2018.2.27)
   新增加了填充式布局，详细操作请见demo
   
## v0.1.1  (2018.2.26)
   修复百分比布局的若干bug

## v0.1.0  (2018.1.29）
   新增加了百分比布局，详细操作请见demo

# gif效果图

![](https://github.com/czl0325/ZLCollectionView/blob/master/demo.gif?raw=true)

# 导入

支持cocoapod导入

```
pod 'ZLCollectionViewFlowLayout' 
```

如果遇到以下错误，
Unable to find a specification for `ZLCollectionViewFlowLayout`
请使用pod update命令来安装。


# 用法

```Objective-C
//在UICollectionView创建之前加入ZLCollectionViewFlowLayout

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

//实现代理，如果不实现也可以自己直接设置self.sectionInset，self.minimumLineSpacing，self.minimumInteritemSpacing。但是这种设置不支持不同section不同数值

//指定section用的样式。LabelLayout是标签样式，ClosedLayout用于tableviewcell或者瀑布流，九宫格之类的。
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
                    NSInteger column = (collectionView.frame.size.width-20)/30;
                    return CGRectMake(((indexPath.item-1)%column)*30, 100+((indexPath.item-1)/column)*30, 20, 20);
                }
                    
            }
        }
            break;
        default:
            return CGRectZero;
    }
    return CGRectZero;
}
```
