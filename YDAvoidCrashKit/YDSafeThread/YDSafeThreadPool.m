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

- (BOOL)creatThread:(NSString *)threadName Task:(YDLoopTask)Task {
    if (self.threadDict[threadName]) return NO;//线程已经存在
    self.threadDict[threadName] = [[YDLoopThread alloc] initWithName:threadName];
    return YES;
}

- (BOOL)creatThread:(NSString *)threadName Task:(YDLoopTask)Task Complete:(YDCompleteTask)Complete {
    if (self.threadDict[threadName]) return NO;//线程已经存在
    self.threadDict[threadName] = [[YDLoopThread alloc] initWithName:threadName];
    
    return YES;
}

- (YDThreadSafeMutableDictionary *)threadDict {
    if (!_threadDict) {
        _threadDict = [[YDThreadSafeMutableDictionary alloc] init];
    }
    return _threadDict;
}
@end
