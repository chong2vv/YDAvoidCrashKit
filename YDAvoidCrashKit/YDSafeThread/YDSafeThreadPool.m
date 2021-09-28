//
//  YDSafeThreadPool.m
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/26.
//

#import "YDSafeThreadPool.h"
#import "YDThreadSafeMutableDictionary.h"
@interface YDSafeThreadPool ()

@property (nonatomic, strong)YDThreadSafeMutableDictionary *threadDict;

@end

@implementation YDSafeThreadPool

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    static id shared = nil;
    dispatch_once(&onceToken, ^{
         shared = [[self alloc] init];
    });
    return shared;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (BOOL)creatThread:(NSString *)threadName {
    if (self.threadDict[threadName]) return NO;//线程已经存在
    self.threadDict[threadName] = [[YDLoopThread alloc] initWithName:threadName];
    return YES;
}

- (BOOL)creatThread:(NSString *)threadName Task:(YDLoopTask)task {
    if (self.threadDict[threadName]) return NO;//线程已经存在
    self.threadDict[threadName] = [[YDLoopThread alloc] initWithName:threadName];
    YDLoopThread *thread = self.threadDict[threadName];
    [thread executeTask:task];
    return YES;
}

- (BOOL)creatThread:(NSString *)threadName Task:(YDLoopTask)task Complete:(YDCompleteTask)Complete {
    if (self.threadDict[threadName]) return NO;//线程已经存在
    self.threadDict[threadName] = [[YDLoopThread alloc] initWithName:threadName];
    YDLoopThread *thread = self.threadDict[threadName];
    [thread executeTask:task complete:Complete];
    return YES;
}

- (BOOL)executeTask:(YDLoopTask)task withThreadName:(NSString *)threadName {
    if (self.threadDict[threadName]){
        YDLoopThread *thread = self.threadDict[threadName];
        [thread executeTask:task];
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)executeTask:(YDLoopTask)task withThreadName:(NSString *)threadName Complete:(YDCompleteTask)Complete {
    if (self.threadDict[threadName]){
        YDLoopThread *thread = self.threadDict[threadName];
        [thread executeTask:task complete:Complete];
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)executeTaskToFreeThread:(YDLoopTask)task {
    
    if (self.threadDict.count > 0) {//其他人的常驻线程
        YDLoopThread *freeThread;
          for (YDLoopThread *thread in self.threadDict) {
              if (!thread.isExecuting) {
                  freeThread = thread;
                  break;
              }
          }
          
          if (freeThread) {
              [freeThread executeTask:task];
              return YES;

          }
    }
    return NO;
}

- (BOOL)deleteThreadWithName:(NSString *)threadName {
    if (!self.threadDict[threadName]) return NO;//线程不存在
    YDLoopThread *thread = self.threadDict[threadName];
    [thread stop];
    [self.threadDict removeObjectForKey:threadName];
    return YES;
}

- (YDThreadSafeMutableDictionary *)threadDict {
    if (!_threadDict) {
        _threadDict = [[YDThreadSafeMutableDictionary alloc] init];
    }
    return _threadDict;
}
@end
