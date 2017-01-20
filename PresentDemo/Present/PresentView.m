//
//  PresentView.m
//  PresentDemo
//
//  Created by 阮思平 on 16/10/2.
//  Copyright © 2016年 阮思平. All rights reserved.
//

#import "PresentView.h"

#define Margin 20

@interface PresentView ()<PresentViewCellDelegate>

/**
 *  带连乘动画的消息缓存数组
 */
@property (strong, nonatomic) NSMutableArray *dataCaches;
/**
 *  不带连城动画的消息缓存数组
 */
@property (strong, nonatomic)NSMutableArray *nonshakeDataCaches;
/**
 *  记录presentView上的cell
 */
@property (strong, nonatomic) NSMutableArray *showCells;

@end

@implementation PresentView

#pragma mark - Setter/Getter

- (void)setCellHeight:(CGFloat)cellHeight
{
    _cellHeight = cellHeight;
    
    [self setNeedsDisplay];
}

- (NSMutableArray *)dataCaches
{
    if (!_dataCaches) {
        _dataCaches = [NSMutableArray array];
    }
    return _dataCaches;
}

- (NSMutableArray *)nonshakeDataCaches
{
    if (!_nonshakeDataCaches) {
        _nonshakeDataCaches = [NSMutableArray array];
    }
    return _nonshakeDataCaches;
}

- (NSMutableArray *)showCells
{
    if (!_showCells) {
        _showCells = [NSMutableArray array];
    }
    return _showCells;
}

#pragma mark - Initial

- (instancetype)init
{
    if (self = [super init]) {
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.userInteractionEnabled = NO;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    //初始值
    self.showTime = 3;
    
    //添加cell
    self.cellHeight = self.cellHeight ? self.cellHeight : 40;
    _rows           = (int)floor(rect.size.height / (self.cellHeight + Margin));
    CGFloat inset   = rect.size.height - (self.cellHeight + Margin) * _rows + Margin;
    inset           = MAX(0, inset) * 0.5;
    for (int index = 0; index < _rows; index++) {
        CGFloat w             = rect.size.width;
        CGFloat y             = inset + (self.cellHeight + Margin) * index;
        CGFloat x             = -w;
        PresentViewCell *cell = [self.delegate presentView:self cellOfRow:index];
        cell.frame            = CGRectMake(x, y, w, self.cellHeight);
        cell.delegate         = self;
        [self addSubview:cell];
        [self.showCells addObject:cell];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    for (int index = 0; index < self.showCells.count; index++) {
        PresentViewCell *cell = self.showCells[index];
        if (CGRectContainsPoint(cell.frame, point)) {
            if ([self.delegate respondsToSelector:@selector(presentView:didSelectedCellOfRowAtIndex:)]) {
                [self.delegate presentView:self didSelectedCellOfRowAtIndex:index];
            }
            break;
        }
    }
}

#pragma mark - Private

//问题一：如果展示动画还在执行，就收到了新的连乘动画消息，这时会判定为去执行连乘动画，因为展示动画还没有执行完成，所以连乘lable还没有被创建，所以会导致连乘动画会消失
//解决办法：等连展示动画执行完成了，才能开始连乘动画，否则连乘动画消息就被缓存

//问题二：点击礼物4，等礼物4快要消失的时候，点击礼物1。会出现两个礼物1，并且下面的cell不会消失，导致礼物1的消息都会被缓存起来
//问题原因：当礼物4将要隐藏时，这时接收到礼物1的消息，就会利用空闲的cell来展示礼物1，但这是没有马上删除礼物1的缓存，而是等到礼物1展示完成才删除的，所以礼物4展示完成就会检测缓存，这时礼物1并没有被删除，所以这里又会展示礼物1，这就导致了礼物一被展示了两次
//解决办法：当礼物4执行完成了，去取缓存的时候，如果取到了缓存，还需要判断这个缓存当前有没有在展示，如果在展示就不做处理，如果没有在展示就利用当前的cell去展示它

//问题三：连续快速点击礼物1，会分两次动画展示
//问题原因：因为两次送的礼物相同，如果快速点击，会发生用于展示第一个礼物的cell还处在AnimationStateShowing状态时，就收到第二个礼物，这个是时候的逻辑处理是将第二个消息缓存了起来(为了解决上述的问题一)

/**
 *  插入带连乘动画的消息
 */
- (void)insertShowShakeAnimationMessages:(NSArray<id<PresentModelAble>> *)models
{
    for (int index = 0; index < models.count; index++) {
        id<PresentModelAble> obj = models[index];
        PresentViewCell *cell = [self examinePresentingCell:obj];
        if (cell) {
            if (cell.state == AnimationStateShowing) {
                //在执行展示动画期间如果收到了连乘动画礼物消息，就将消息缓存
                [self.dataCaches addObject:obj];
            }else {
                if ([obj giftNumber] > 0) {
                    [cell shakeAnimationWithModels:@[obj]];
                } else {
                    [cell shakeAnimationWithNumber:1];
                }
            }
        }else {
            [self.dataCaches addObject:obj];//将当前消息加到缓存中
            NSArray *cells = [self examinePresentViewCells];
            if (cells.count) {
                cell                   = cells.firstObject;
                //设置后，再次展示的动画才会生效
                cell.showTime          = self.showTime;
                __weak typeof(self) ws = self;
                [cell showAnimationWithModel:obj showShakeAnimation:YES prepare:^{
                    if ([ws.delegate respondsToSelector:@selector(presentView:configCell:model:)]) {
                        [ws.delegate presentView:ws configCell:cell model:obj];
                    }
                } completion:^(BOOL flag) {
                    if (flag) {
                        //如果相同礼物类型的消息缓存在执行展示动画之前就删除了，这就会造成在cell执行展示动画期间收到的相同类型的消息会被缓存到下一个cell中展示
                        if ([obj giftNumber] > 0) {
                            [cell shakeAnimationWithModels:[self subarrayWithObj:obj]];
                        }else {
                            [cell shakeAnimationWithNumber:[self subarrayWithObj:obj].count];
                        }
                    }
                }];
            }
        }
    }
}

/**
 *  插入不带连城动画的消息
 */
- (void)insertNonshakeAnimationMessages:(NSArray<id<PresentModelAble>> *)models
{
    if (models) {
        [self.nonshakeDataCaches addObjectsFromArray:models];
    }
    NSArray *freeCells = [self examinePresentViewCells];
    if (self.nonshakeDataCaches.count > 0 && freeCells.count > 0) {
        id<PresentModelAble> obj = self.nonshakeDataCaches.firstObject;
        [self.nonshakeDataCaches removeObjectAtIndex:0];
        PresentViewCell *cell    = freeCells.firstObject;
        cell.showTime            = self.showTime;
        __weak typeof(self) ws   = self;
        [cell showAnimationWithModel:obj showShakeAnimation:NO prepare:^{
            if ([ws.delegate respondsToSelector:@selector(presentView:configCell:model:)]) {
                [ws.delegate presentView:ws configCell:cell model:obj];
            }
        } completion:^(BOOL flag) {
            if (!flag) {
                [cell performSelector:@selector(hiddenAnimationOfShowShake:) withObject:@(NO) afterDelay:self.showTime];
            }
        }];
    }
}

/**
 *  检测插入的消息模型
 */
- (NSArray *)checkElementOfModels:(NSArray<id<PresentModelAble>> *)models
{
    NSMutableArray *siftArray = [NSMutableArray array];
    for (id obj in models) {
        if (![obj conformsToProtocol:@protocol(PresentModelAble)]) {
            DebugLog(@"%@对象没有遵守PresentModelAble协议", obj);
        }else {
            [siftArray addObject:obj];
        }
    }
    return siftArray;
}

/**
 *  检测当前是否有obj类型的礼物消息在展示
 */
- (PresentViewCell *)examinePresentingCell:(id<PresentModelAble>)obj
{
    for (PresentViewCell *cell in self.showCells) {
        if ([cell.sender isEqualToString:[obj sender]] && [cell.giftName isEqualToString:[obj giftName]]) {
            //当前正在展示动画并且不是隐藏动画
            if (cell.state != AnimationStateNone && cell.state != AnimationStateHiding ) return cell;
        }
    }
    return nil;
}

/**
 *  检测空闲cell
 */
- (NSArray<PresentViewCell *> *)examinePresentViewCells
{
    NSMutableArray *freeCells = [NSMutableArray array];
    for (PresentViewCell *cell in self.showCells) {
        if (cell.state == AnimationStateNone) {
            [freeCells addObject:cell];
        }
    }
    return freeCells;
}

/**
 *  从缓存中截取与obj类型相同的消息
 */
- (NSArray<id<PresentModelAble>> *)subarrayWithObj:(id<PresentModelAble>)obj
{
    NSMutableArray *array = [NSMutableArray array];
    for (id<PresentModelAble> cache in self.dataCaches) {
        if ([[cache sender] isEqualToString:[obj sender]] && [[cache giftName] isEqualToString:[obj giftName]]) {
            [array addObject:cache];
        }
    }
    [self.dataCaches removeObjectsInArray:array];//取出的数据从缓存中移除
    return array;
}

#pragma mark - Public

- (void)insertPresentMessages:(NSArray<id<PresentModelAble>> *)models showShakeAnimation:(BOOL)flag
{
    NSArray *siftArray = [self checkElementOfModels:models];
    if (!siftArray.count) return;
    if (flag) {
        [self insertShowShakeAnimationMessages:siftArray];
    }else {
        [self insertNonshakeAnimationMessages:siftArray];
    }
}

- (PresentViewCell *)cellForRowAtIndex:(NSUInteger)index
{
    if (index < self.showCells.count)
    {
        return self.showCells[index];
    }
    return nil;
}

- (void)releaseVariable
{
    [self.dataCaches removeAllObjects];
    [self.nonshakeDataCaches removeAllObjects];
    [self.showCells makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.showCells removeAllObjects];
}

#pragma mark - PresentViewCellDelegate

- (void)presentViewCell:(PresentViewCell *)cell showShakeAnimation:(BOOL)flag shakeNumber:(NSInteger)number
{
    if ([self.delegate respondsToSelector:@selector(presentView:animationCompleted:model:)]) {
        [self.delegate presentView:self animationCompleted:number model:cell.baseModel];
    }
    if (self.dataCaches.count) {
        id<PresentModelAble> obj = self.dataCaches.firstObject;
        if (![self examinePresentingCell:obj]) {
            //取到的缓存当前没有在展示
            __weak typeof(self) ws = self;
            [cell showAnimationWithModel:obj showShakeAnimation:YES prepare:^{
                if ([ws.delegate respondsToSelector:@selector(presentView:configCell:model:)]) {
                    [ws.delegate presentView:ws configCell:cell model:obj];
                }
            } completion:^(BOOL flag) {
                if (flag) {
                    if ([obj giftNumber] > 0) {
                        [cell shakeAnimationWithModels:[self subarrayWithObj:obj]];
                    }else {
                        [cell shakeAnimationWithNumber:[self subarrayWithObj:obj].count];
                    }
                }
            }];
        }
    }else if (self.nonshakeDataCaches.count) {
        //带连乘的缓存优先处理
        [self insertNonshakeAnimationMessages:nil];
    }else {
        [cell releaseVariable];
    }
}

@end
