# PresentAnimation
***
## 仿映客刷礼物效果

#### 1. 创建PresentView对象

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

#### 3. 收到消息，将消息插入

```
[self.presentView insertPresentMessages:@[self.dataArray[0]]];
```
