//
//  YDSafeThreadPool.h
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/26.
//

#import <Foundation/Foundation.h>
#import "YDLoopThread.h"
NS_ASSUME_NONNULL_BEGIN

@interface YDSafeThreadPool : NSObject

+ (instancetype)shared;

/**
默认常驻线程执行任务
这里的block是尾随闭包,不用担心强引用
*/

- (BOOL)creatThread:(NSString *)threadName;

/**
创建一个常驻线程，并执行task任务
*/
- (BOOL)creatThread:(NSString *)threadName Task:(YDLoopTask) task;

/**
创建一个常驻线程，并执行task任务，有回调
*/
- (BOOL)creatThread:(NSString *)threadName Task:(YDLoopTask) task Complete:(YDCompleteTask)Complete;

/**
指定一个常驻线程任务执行
*/
- (BOOL)executeTask:(YDLoopTask)task withThreadName:(NSString *)threadName;

/**
指定一个常驻线程任务执行，  有回调
*/
- (BOOL)executeTask:(YDLoopTask)task withThreadName:(NSString *)threadName Complete:(YDCompleteTask)Complete;

/**
 销毁常驻线程
*/
- (BOOL)deleteThreadWithName:(NSString *)threadName;

/**
寻求一个空闲线程去执行任务  flase表示使用了gcd  哈哈
*/
- (BOOL)executeTaskToFreeThread:(YDLoopTask)task;

@end

NS_ASSUME_NONNULL_END
