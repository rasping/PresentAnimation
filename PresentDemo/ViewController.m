//
//  ViewController.m
//  PresentDemo
//
//  Created by 阮思平 on 16/10/2.
//  Copyright © 2016年 阮思平. All rights reserved.
//

#import "ViewController.h"
#import "PresentView.h"
#import "PresentModel.h"
#import "CustonCell.h"

@interface ViewController ()<PresentViewDelegate>

- (IBAction)sendOne:(UIButton *)sender;
- (IBAction)sendTwo:(UIButton *)sender;
- (IBAction)sendThree:(UIButton *)sender;
- (IBAction)sendFour:(UIButton *)sender;
- (IBAction)serialBtnClicked:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *serialBtnOne;
@property (weak, nonatomic) IBOutlet UIButton *serialBtnTwo;
@property (weak, nonatomic) IBOutlet UIButton *serialBtnThree;
@property (weak, nonatomic) IBOutlet UIButton *serialBtnFour;
@property (weak, nonatomic) IBOutlet PresentView *presentView;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (weak, nonatomic) UIButton *serialBtn;
@property (strong, nonatomic)NSTimer *timer;

@end

@implementation ViewController

#pragma mark - Setter/Getter
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
        PresentModel *one = [PresentModel modelWithSender:@"one" giftName:@"小车" icon:@"icon1" giftImageName:@"prop_b"];
        [_dataArray addObject:one];
        PresentModel *two = [PresentModel modelWithSender:@"two" giftName:@"蘑菇" icon:@"icon2" giftImageName:@"prop_g"];
        [_dataArray addObject:two];
        PresentModel *three = [PresentModel modelWithSender:@"three" giftName:@"红包" icon:@"icon3" giftImageName:@"prop_h"];
        [_dataArray addObject:three];
        PresentModel *four = [PresentModel modelWithSender:@"four" giftName:@"啤酒" icon:@"icon4" giftImageName:@"prop_f"];
        [_dataArray addObject:four];
    }
    return _dataArray;
}

- (NSTimer *)timer
{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(changeSerialBtnTitle) userInfo:nil repeats:YES];
        [_timer fire];
    }
    return _timer;
}

#pragma mark - Initial

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.presentView.delegate = self;
    [self setupSerialBtn:self.serialBtnOne];
    [self setupSerialBtn:self.serialBtnTwo];
    [self setupSerialBtn:self.serialBtnThree];
    [self setupSerialBtn:self.serialBtnFour];
    
}

#pragma mark - Private

- (void)setupSerialBtn:(UIButton *)btn
{
    btn.adjustsImageWhenHighlighted = NO;
    btn.clipsToBounds               = YES;
    btn.layer.cornerRadius          = CGRectGetWidth(btn.frame) * 0.5;
}

- (void)changeSerialBtnTitle
{
    [self changeTitleOfSerialBtn:self.serialBtnOne];
    [self changeTitleOfSerialBtn:self.serialBtnTwo];
    [self changeTitleOfSerialBtn:self.serialBtnThree];
    [self changeTitleOfSerialBtn:self.serialBtnFour];
}

- (void)changeTitleOfSerialBtn:(UIButton *)serialBtn
{
    NSInteger count = [serialBtn.currentTitle integerValue];
    if (count > 0) {
        NSString *title = [NSString stringWithFormat:@"%ld", --count];
        serialBtn.titleLabel.text = title;
        [serialBtn setTitle:title forState:UIControlStateNormal];
    }else {
        serialBtn.hidden = YES;
    }
}

#pragma mark - PresentViewDelegate

- (PresentViewCell *)presentView:(PresentView *)presentView cellOfRow:(NSInteger)row
{
    return [[CustonCell alloc] initWithRow:row];
}

- (void)presentView:(PresentView *)presentView configCell:(PresentViewCell *)cell model:(id<PresentModelAble>)model
{
    CustonCell *customCell = (CustonCell *)cell;
    customCell.model = model;
}

- (void)presentView:(PresentView *)presentView didSelectedCellOfRowAtIndex:(NSUInteger)index
{
    CustonCell *cell = [presentView cellForRowAtIndex:index];
    NSLog(@"你点击了：%@", cell.model.giftName);
}

#pragma mark - Action

- (IBAction)sendOne:(UIButton *)sender
{
    self.serialBtnOne.hidden = NO;
    [self.serialBtnOne setTitle:@"30" forState:UIControlStateNormal];
    [self timer];
    [self.presentView insertPresentMessages:@[self.dataArray[0]] showShakeAnimation:YES];
}

- (IBAction)sendTwo:(UIButton *)sender
{
    self.serialBtnTwo.hidden = NO;
    [self.serialBtnTwo setTitle:@"30" forState:UIControlStateNormal];
    [self timer];
    NSMutableArray *array = [NSMutableArray array];
    for (int index = 0; index < 3; index++) {
        [array addObject:self.dataArray[1]];
    }
    [self.presentView insertPresentMessages:array showShakeAnimation:YES];
}

- (IBAction)sendThree:(UIButton *)sender
{
    self.serialBtnThree.hidden = NO;
    [self.serialBtnThree setTitle:@"30" forState:UIControlStateNormal];
    [self timer];
    [self.presentView insertPresentMessages:@[self.dataArray[2]] showShakeAnimation:YES];
}

- (IBAction)sendFour:(UIButton *)sender
{
//    self.serialBtnFour.hidden = NO; 
//    [self.serialBtnFour setTitle:@"30" forState:UIControlStateNormal];
//    [self timer];
    [self.presentView insertPresentMessages:@[self.dataArray[3]] showShakeAnimation:NO];
}

- (IBAction)serialBtnClicked:(UIButton *)btn
{
    [btn setTitle:@"30" forState:UIControlStateNormal];
    [btn.titleLabel setText:@"30"];
    [self.presentView insertPresentMessages:@[self.dataArray[btn.tag]] showShakeAnimation:YES];
}

@end
