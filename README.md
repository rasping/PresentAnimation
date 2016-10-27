# PresentAnimation
***
## 仿映客刷礼物效果

#### 1. 创建PresentView

```
PresentView *presentView = [[PresentView alloc] init];
presentView.delegate = self;
presentView.frame = CGRectMake(0, 200, 200, 130);
[self.view addSubview:presentView];
```

#### 2. 实现代理协议

* 返回自定义cell样式(required)

```
- (PresentViewCell *)presentView:(PresentView *)presentView cellOfRow:(NSInteger)row
{
    return [[CustonCell alloc] initWithRow:row];
}
```
* 设置cell展示的数据(required)

```
- (void)presentView:(PresentView *)presentView configCell:(PresentViewCell *)cell sender:(NSString *)sender giftName:(NSString *)name
{
    for (PresentModel *model in self.dataArray) {
        if ([model.sender isEqualToString:sender] && [model.giftName isEqualToString:name]) {
            CustonCell *customCell = (CustonCell *)cell;
            customCell.model = model;
        }
    }
}
```
* 监听cell的点击事件(optional)

```
- (void)presentView:(PresentView *)presentView didSelectedCellOfRowAtIndex:(NSUInteger)index
{
    CustonCell *cell = [presentView cellForRowAtIndex:index];
    NSLog(@"你点击了：%@", cell.model.giftName);
}
```

#### 3. 属性定制

```
presentView.showTime = 3.5;
presentView.cellHeight = 35;
```

#### 4. 收到消息，将消息插入

```
[self.presentView insertPresentMessages:@[self.dataArray[2]] showShakeAnimation:YES];
```
效果图如下：
![效果图.png](http://upload-images.jianshu.io/upload_images/1344789-f91968285ccc875d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

关于Demo的基本逻辑分析，详见：[仿映客刷礼物效果---基本逻辑实现](http://www.jianshu.com/p/59c9532b22d9)