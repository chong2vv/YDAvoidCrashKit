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
- (BOOL)executeTask:(YDLoopTask)task;

- (BOOL)executeTask:(YDLoopTask)task Complete:(YDCompleteTask)Complete;

- (BOOL)creatThread:(NSString *)threadName Task:(YDLoopTask) Task;

- (BOOL)creatThread:(NSString *)threadName Task:(YDLoopTask) Task Complete:(YDCompleteTask)Complete;

@end

NS_ASSUME_NONNULL_END
