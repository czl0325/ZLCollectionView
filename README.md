# ZLCollectionView
不断更新各种样式的UICollectionViewFlowLayout
目前支持标签页，tableviewcell，瀑布流，九宫格类型的布局。可以不同的section设置不同的布局。

![](https://github.com/czl0325/ZLCollectionView/blob/master/demo.gif?raw=true)


用法

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
    if (section < 3) {
        return LabelLayout;
    } else {
        return ClosedLayout;
    }
}

//如果是ClosedLayout样式的section，必须实现该代理，指定列数
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
```
