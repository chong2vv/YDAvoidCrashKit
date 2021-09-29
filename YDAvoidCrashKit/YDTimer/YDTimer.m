//
//  YDTimer.m
//  YDUtilKit
//
//  Created by wangyuandong on 2021/9/29.
//

#import "YDTimer.h"
#import "YDSafeThread.h"

@interface YDTimer ()

@property (nonatomic, strong)YDThreadSafeMutableDictionary *timers;       // 缓存timer的字典

@end

@implementation YDTimer

-(instancetype)init {
    
    if (self = [super init])
        _timers = [[YDThreadSafeMutableDictionary alloc] init];
    
    return self;
}


// 单例模式获取YDTimer
+(instancetype)sharedTimer {
    
    static YDTimer *timer;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timer = [YDTimer new];
    });
    
    return timer;
}


// 开启计时器
-(void)scheduledTimerWithName:(NSString *)timerName timerType:(YDTimerType)type queue:(nullable dispatch_queue_t)queue timeInterval:(NSTimeInterval)interval leewayInseconds:(NSTimeInterval)seconds handler:(nullable YDTimerHandler)handler {
    
    if (timerName == nil)
        return ;
    
    if (queue == nil)
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    // 设置timer
    dispatch_source_t timer = _timers[timerName];
    if (timer == nil) {
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        [_timers setObject:timer forKey:timerName];
    }
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, interval * NSEC_PER_SEC, seconds * NSEC_PER_SEC);
    
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(timer, ^{
        
        // 执行
        BOOL shouldStop = NO;
        if (handler) shouldStop = handler();
        
        // 停止
        if (shouldStop)
            switch (type) {
                case YDTimerTypeAutoRelease:
                    // 自动释放timer
                    [weakSelf invalidateWithTimerName:timerName];
                    break;
                
                case YDTimerTypeManualRelease:
                    // 只是暂停timer，需手动释放
                    dispatch_suspend(timer);
                    break;
                    
                default:
                    break;
            }
            
    });

    dispatch_resume(timer);
}


// 注销计时器（手动释放类型的计时器，需调用此方法释放计时器）
-(void)invalidateWithTimerName:(NSString *)timerName {
    
    dispatch_source_t timer = _timers[timerName];
    
    if (timer == nil) return ;
    
    [_timers removeObjectForKey:timerName];
    dispatch_source_cancel(timer);
}

@end
