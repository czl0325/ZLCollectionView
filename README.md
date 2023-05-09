# ZLCollectionView

为应对类似淘宝首页，京东首页，国美首页等复杂布局而写的ZLCollectionview。基于UICollectionView实现，目前支持标签布局，列布局，百分比布局，定位布局，填充式布局，瀑布流布局等。支持纵向布局和横向布局，可以根据不同的section设置不同的布局，支持拖动cell，头部悬浮，设置section背景色和自定义section背景view，向自定义背景view传递自定义方法。实现了电影选座等高难度的布局。<br>
特别感谢[donggelaile](https://github.com/donggelaile)贡献了降低cpu占用率的代码

### gif效果图

<img src="https://github.com/czl0325/ZLCollectionView/blob/master/demo1.gif?raw=true"/>   <img src="https://github.com/czl0325/ZLCollectionView/blob/master/demo2.gif?raw=true"/>

### 导入

支持cocoapod导入，最新版本 1.4.9

```
pod 'ZLCollectionViewFlowLayout' 
```

### 推荐项目
使用uitableview或者uicollectionview的朋友可以使用我的另外一个库  [ZLCellDataSource](https://github.com/czl0325/ZLCellDataSource)<br>
至少可以少写1/3的代码量，在开发界面可以快速帮你构建uitableview和uicollectionview<br>
觉得好用的朋友可以去点个star<br>

### 注意事项：
版本1.0开始加入了横向布局，有升级到1.0的，原来的类ZLCollectionViewFlowLayout提示找不到，请更换成ZLCollectionViewVerticalLayout即可，其余不变。如果不想升级可用  pod 'ZLCollectionViewFlowLayout','0.8.7.1'  <br><br>
<br>
* ZLCollectionViewVerticalLayout    ====     纵向布局   <br>
* ZLCollectionViewHorzontalLayout   ====     横向布局(暂时先做了标签页布局和瀑布流，其余的后续增加)<br>
<br>

如果遇到以下错误，
Unable to find a specification for `ZLCollectionViewFlowLayout`
请使用pod update命令来安装。

### 参数列表

| 可配置参数               | 类型      | 作用                                                    |
|:------------------------:|:-----------:|:--------------------------------------------------------:|
| isFloor                | BOOL      | 宽度是否向下取整，默认为YES，该参数一般不用改                |
| canDrag                | BOOL      | 是否允许拖动cell，默认为NO                                |
| header_suspension      | BOOL      | 头部是否悬浮，默认为NO                                    |
| layoutType             | ZLLayoutType      | 设置布局类型，适用于只有单一布局可省去写代理的代码     |
| columnCount            | columnCount      | 在列布局中设置列数，适用于单一布局可省去写代理的代码 |
| fixTop            | CGFloat      | header距离顶部的距离 |
| columnSortType    | ZLColumnSortType | 瀑布流列排序方式，按最小高度或者按顺序 |

<br>

| 布局名称              | 布局类型      | 作用                                                    |
|:------------------------:|:-----------:|:--------------------------------------------------------:|
| LabelLayout            | 标签页布局      |                 |
| ColumnLayout                | 列布局      | 瀑布流，单行布局，等分布局                               |
| PercentLayout      | 百分比布局      |                                 |
| FillLayout             | 填充式布局      |      |
| AbsoluteLayout            | 绝对定位布局      |    |
<br>

| 代理方法              | 作用      | 备注                                                    |
|:------------------------:|:-----------:|:--------------------------------------------------------:|
| - (ZLLayoutType)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout typeOfLayout:(NSInteger)section;            | 指定是什么布局     |  如没有指定则为FillLayout(填充式布局)  |
| - (UIColor*)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout backColorForSection:(NSInteger)section;                | 设置每个section的背景色      |       
| - (UIImage*)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout backImageForSection:(NSInteger)section;               | 设置每个section的背景图      |                            |
| - (NSString*)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout registerBackView:(NSInteger)section;      | 自定义每个section的背景view，      |      |
| - (ZLBaseEventModel*)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout backgroundViewMethodForSection:(NSInteger)section;      | 向每个section自定义背景view传递自定义方法      |  需要传递的自定义view必须继承ZLCollectionBaseDecorationView类，传递的ZLBaseEventModel对象，eventName:方法名（注意带参数的方法名必须末尾加:）,parameter:参数  |
| - (BOOL)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout attachToBottom:(NSInteger)section;            | 背景是否延伸覆盖到footerView      |   默认为NO   |
| - (BOOL)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout attachToTop:(NSInteger)section;            | 背景是否延伸覆盖到headerView      |   默认为NO   |
| - (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout zIndexOfItem:(NSIndexPath*)indexPath;            | 设置每个item的zIndex      |    默认为0|
| - (CATransform3D)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout transformOfItem:(NSIndexPath*)indexPath;            | 设置每个item的CATransform3D      |    默认为CATransform3DIdentity|
| - (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout alphaOfItem:(NSIndexPath*)indexPath;           | 设置每个item的alpha    |    默认为1|
| - (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout*)collectionViewLayout columnCountOfSection:(NSInteger)section;           | 列布局中指定一行有几列    |    列布局需要的代理，默认为1|
| - (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout*)collectionViewLayout percentOfRow:(NSIndexPath*)indexPath;          | 百分比布局中指定每个item占该行的几分之几    |    PercentLayout百分比布局需要的代理，如3.0/4，注意为大于0小于等于1的数字。不指定默认为1|
| - (CGRect)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout*)collectionViewLayout rectOfItem:(NSIndexPath*)indexPath;          | 绝对定位布局中指定每个item的frame    |    绝对定位布局必须实现的代理。不指定默认为CGRectZero|
| - (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout*)collectionViewLayout didMoveCell:(NSIndexPath*)atIndexPath toIndexPath:(NSIndexPath*)toIndexPath;          | 拖动cell的相关代理    |    |
<br>

### 用法

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

### 更新
##### v1.4.9 (2022.03.29)
* 增加瀑布流排列方式的字段

##### v1.4.0 (2020.04.18)
* 自定义背景view的代理方法增加

##### v1.3.1 (2020.04.14)
* 修改填充式布局的bug

##### v1.3.0 (2020.03.25)
* 增加头部偏移量设置

##### v1.2.0 (2019.12.25)
* 降低cpu的占用率

##### v1.1.6 (2019.10.1)
* 修复bug

##### v1.1.0 (2019.5.13)
* 横向布局增加绝对定位布局

##### v1.0.3 (2019.5.7)
* 修改适配swift

##### v1.0.2 (2019.2.20)
* 拆分成横向布局和纵向布局两个类，使用方法和类名有所改变

##### v0.8.6 (2019.1.11)
* 降低了头部不悬浮情况下的cpu占用率

##### v0.8.2 (2018.9.26)
* 去掉基础布局
* 提取代理出来
* 增加高度向下取整

##### v0.7.0 (2018.8.6)
* 增加头部可以悬浮的设置

##### v0.6.2 (2018.7.26)
* 增加拖动cell和高度自适应的测试。高度自适应需要用到第三方库

##### v0.5.3 (2018.7.12)
* 增加自定义section背景图

##### v0.5 (2018.7.10)
* 增加了可以设置每个section的背景色

##### v0.4.1 (2018.7.8)
* 修改了一些bug

##### v0.3.0  (2018.3.1)
* 新增加了绝对定位布局，自己定义每个item的位置，可以做层叠布局，电影选座布局等等，详细操作请见demo

##### v0.2.0  (2018.2.27)
* 新增加了填充式布局，详细操作请见demo
   
##### v0.1.1  (2018.2.26)
* 修复百分比布局的若干bug

##### v0.1.0  (2018.1.29）
* 新增加了百分比布局，详细操作请见demo
