//
//  NSSet+YDAvoidCrash.m
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/16.
//

#import "NSSet+YDAvoidCrash.h"
#import "YDAvoidCrash.h"
#import "NSObject+YDAvoidCrashRunTime.h"

@implementation NSSet (YDAvoidCrash)

+ (void)avoidCrashExchangeMethod {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NSObject exchangeClassMethod:[self class] method1Sel:@selector(setWithObject:) method2Sel:@selector(AvoidCrashSetWithObject:)];
    });
}
//=================================================================
//                  来自 https://github.com/jasenhuang/NSObjectSafe
//=================================================================
+ (instancetype)AvoidCrashSetWithObject:(const id  _Nonnull __unsafe_unretained *)object {
    id instance = nil;
    
    @try {
        instance = [self AvoidCrashSetWithObject:object];
    }
    @catch (NSException *exception) {
        
        NSString *defaultToDo = AvoidCrashDefaultReturnNil;;
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
        
    }
    @finally {
        return instance;
    }
    
}

@end
