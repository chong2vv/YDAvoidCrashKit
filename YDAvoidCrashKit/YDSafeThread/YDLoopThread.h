//
//  YDLoopThread.h
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^YDLoopTask)(void);
typedef void (^YDCompleteTask)(void);

@interface YDLoopThread : NSObject

/**
创建一个指定name的线程对象
*/
- (instancetype)initWithName:(NSString *)name;

/**
 在当前子线程执行一个任务
 */
- (void)executeTask:(YDLoopTask)task;

/**
 在当前子线程执行一个任务及执行成功回调
 */
- (void)executeTask:(YDLoopTask)task  complete:(nullable YDCompleteTask)complete;

/**
 结束线程
 */
- (void)stop;

/**
线程正在执行
*/
- (BOOL)isExecuting;

@end

NS_ASSUME_NONNULL_END
