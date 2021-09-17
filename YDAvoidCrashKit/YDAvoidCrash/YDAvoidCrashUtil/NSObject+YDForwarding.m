//
//  NSObject+YDForwarding.m
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/15.
//

#import "NSObject+YDForwarding.h"
#import "NSObject+YDAvoidCrashRunTime.h"
#import "YDAvoidCrash.h"
#import "YDUnrecognizedSelectorSolveObject.h"

@implementation NSObject (YDForwarding)

+ (void)avoidCrashForwardingExchangeMethod {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NSObject exchangeInstanceMethod:[self class]  method1Sel:@selector(methodSignatureForSelector:) method2Sel:@selector(newMethodSignatureForSelector:)];
        
        [NSObject exchangeInstanceMethod:[self class]  method1Sel:@selector(forwardInvocation:) method2Sel:@selector(newForwardInvocation:)];
    });
}

#pragma mark forwardTarget
- (BOOL)enableMethod {
    
    NSString *selString = NSStringFromClass([self class]);
    /*
     * 一般出现找不到方法，多数是 服务端返回数据类型问题导致的, NSNUll  NSArray NSString NSDictionary 所以拦截 NS开头。 防止拦截其它造成一些问题。（已知键盘弹起）
     *
     */
    
    for (NSString *prefixString in [YDAvoidCrash getAvoidCrashEnableMethodPrefixList]) {
        if ([selString rangeOfString:prefixString].length > 0) {
            return YES;
        }
    }
    
    return NO;
}

- (NSMethodSignature *)newMethodSignatureForSelector:(SEL)sel{
    
    NSMethodSignature *signature = [self newMethodSignatureForSelector:sel];
    if (![self enableMethod]) {
        return signature;
    }
    if (signature != nil) {
        return signature;
    }
    
    NSException *exception = [NSException exceptionWithName:@"unrecognized selector(会有系统处理过的，部分情况可以忽略)" reason:[NSString stringWithFormat:@"[%@ %@]",[self class],NSStringFromSelector(sel)] userInfo:@{}];
    [YDAvoidCrash noteErrorWithException:exception defaultToDo:@"动态添加方法，并返回nil"];
    //可以在此加入日志信息，栈信息的获取等，方便后面分析和改进原来的代码。
    YDUnrecognizedSelectorSolveObject *unrecognizedSelectorSolveObject = [YDUnrecognizedSelectorSolveObject sharedInstance];
    [YDUnrecognizedSelectorSolveObject resolveInstanceMethod:sel];
    return [unrecognizedSelectorSolveObject newMethodSignatureForSelector:sel];
}


- (void)newForwardInvocation:(NSInvocation *)anInvocation{
    
    if (![self enableMethod]) {
        [self newForwardInvocation:anInvocation];
        return;
    }
    
    if([self newMethodSignatureForSelector:anInvocation.selector]){
        [self newForwardInvocation:anInvocation];
        return;
    }
    YDUnrecognizedSelectorSolveObject *unrecognizedSelectorSolveObject = [YDUnrecognizedSelectorSolveObject sharedInstance];
    [YDUnrecognizedSelectorSolveObject resolveInstanceMethod:anInvocation.selector];
    if([self methodSignatureForSelector:anInvocation.selector]){
        [anInvocation invokeWithTarget:unrecognizedSelectorSolveObject];
    }
}

@end
