//
//  CustonCell.m
//  PresentDemo
//
//  Created by siping ruan on 16/10/9.
//  Copyright © 2016年 阮思平. All rights reserved.
//

#import "CustonCell.h"
#import "PresentModel.h"

@interface CustonCell ()

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *senderName;
@property (weak, nonatomic) IBOutlet UILabel *giftNameLable;
@property (weak, nonatomic) IBOutlet UIImageView *gift;

@end

@implementation CustonCell

//- (instancetype)init
//{
//    if (self = [super init]) {
//        self = [[NSBundle mainBundle] loadNibNamed:@"CustomCell" owner:self options:0].firstObject;
//        self.bgView.clipsToBounds = YES;
//        self.icon.clipsToBounds = YES;
//        self.icon.layer.borderWidth = 1;
//        self.icon.layer.borderColor = [UIColor cyanColor].CGColor;
//    }
//    return self;
//}

- (instancetype)initWithRow:(NSInteger)row
{
    if (self = [super initWithRow:row]) {
        self = [[NSBundle mainBundle] loadNibNamed:@"CustonCell" owner:self options:0].firstObject;
        self.bgView.clipsToBounds   = YES;
        self.icon.clipsToBounds     = YES;
        self.icon.layer.borderWidth = 1;
        self.icon.layer.borderColor = [UIColor cyanColor].CGColor;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.bgView.layer.cornerRadius = CGRectGetHeight(self.frame) * 0.5;
    self.icon.layer.cornerRadius   = CGRectGetHeight(self.icon.frame) * 0.5;
}

- (void)setModel:(PresentModel *)model
{
    _model = model;
    
    self.icon.image         = [UIImage imageNamed:model.icon];
    self.senderName.text    = model.sender;
    self.giftNameLable.text = [NSString stringWithFormat:@"送了一个【%@】", model.giftName];
    self.gift.image         = [UIImage imageNamed:model.giftImageName];
}

//自定义cell的展示动画
- (void)customDisplayAnimationOfShowShakeAnimation:(BOOL)flag
{
    //这里是直接使用父类中的动画，如果用户想自定义可这里实现动画，不调用父类的方法(这个方法在UIView动画的animations回调中执行)
    [super customDisplayAnimationOfShowShakeAnimation:flag];
}

//自定义cell的隐藏动画
- (void)customHideAnimationOfShowShakeAnimation:(BOOL)flag
{
    [super customHideAnimationOfShowShakeAnimation:flag];
}

@end
