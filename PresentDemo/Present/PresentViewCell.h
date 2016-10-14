//
//  PresentViewCell.h
//  PresentDemo
//
//  Created by 阮思平 on 16/10/2.
//  Copyright © 2016年 阮思平. All rights reserved.
//

#import <UIKit/UIKit.h>

//动画状态
typedef NS_ENUM(NSUInteger, AnimationState) {
    AnimationStateNone = 0,
    AnimationStateShowing,
    AnimationStateShaking,
    AnimationStateShaked,
    AnimationStateHiding
};

@protocol PresentViewCellDelegate;

@interface PresentViewCell : UIView

@property (weak, nonatomic) id<PresentViewCellDelegate> delegate;
/**
 *  轨道编号
 */
@property (assign, nonatomic, readonly) NSInteger row;
/**
 *  cell当前的动画状态
 */
@property (assign, nonatomic, readonly) AnimationState state;
/**
 *  礼物发送者
 */
@property (copy, nonatomic, readonly) NSString *sender;
/**
 *  礼物名
 */
@property (copy, nonatomic, readonly) NSString *giftName;

- (instancetype)initWithRow:(NSInteger)row;
/**
 *  显示cell动画
 *
 *  @param sender     发送者
 *  @param name       礼物名
 *  @param prepare    准备动画回调
 *  @param completion 动画完成回调
 */
- (void)showAnimationWithSender:(NSString *)sender
                       giftName:(NSString *)name
                        prepare:(void (^)(void))prepare
                     completion:(void (^)(BOOL finished))completion;
/**
 *  连乘动画
 *
 *  @param number 连乘次数
 */
- (void)shakeAnimationWithNumber:(NSInteger)number;
/**
 *  释放引用变量
 */
- (void)releaseVariable;

@end

//供子类重写的接口
@interface PresentViewCell (OverWrite)

/**
 *  自定义展示动画
 */
- (void)customDisplayAnimation;
/**
 *  自定义隐藏动画
 */
- (void)customHideAnimation;

@end

@interface PresentLable : UILabel

/**
 *  数字描边颜色
 */
@property (strong, nonatomic) UIColor *borderColor;
/**
 *  开始连乘动画
 *
 *  @param interval    动画时间
 *  @param completion  动画完成回调
 */
- (void)startAnimationDuration:(NSTimeInterval)interval
                    completion:(void (^)(BOOL finish))completion;

@end

@protocol PresentViewCellDelegate <NSObject>

@optional
/**
 *  一组动画组完成回调
 *
 *  @param number 最终连乘数
 */
- (void)presentViewCell:(PresentViewCell *)cell operationQueueCompletionOfNumber:(NSInteger)number;

@end
