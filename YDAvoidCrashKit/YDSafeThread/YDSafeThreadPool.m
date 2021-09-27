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

- (YDThreadSafeMutableDictionary *)threadDict {
    if (!_threadDict) {
        _threadDict = [[YDThreadSafeMutableDictionary alloc] init];
    }
    return _threadDict;
}
@end
