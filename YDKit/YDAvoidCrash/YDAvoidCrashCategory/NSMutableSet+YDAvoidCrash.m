//
//  NSMutableSet+YDAvoidCrash.m
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/16.
//

#import "NSMutableSet+YDAvoidCrash.h"
#import "YDAvoidCrash.h"
#import "NSObject+YDAvoidCrashRunTime.h"

@implementation NSMutableSet (YDAvoidCrash)

+ (void)avoidCrashExchangeMethod {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class setClass = NSClassFromString(@"__NSSetM");
        
        [NSObject exchangeInstanceMethod:setClass method1Sel:@selector(addObject:) method2Sel:@selector(avoidCrashAddObject:)];
        
        [NSObject exchangeInstanceMethod:setClass method1Sel:@selector(removeObject:) method2Sel:@selector(avoidCrashRemoveObject:)];
    });
}
//=================================================================
//                  来自 https://github.com/jasenhuang/NSObjectSafe
//=================================================================
- (void)avoidCrashAddObject:(id)anObject {
    @try {
        [self avoidCrashAddObject:anObject];
    }
    @catch (NSException *exception) {
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:AvoidCrashDefaultIgnore];
    }
    @finally {
        
    }
}
//=================================================================
//                  来自 https://github.com/jasenhuang/NSObjectSafe
//=================================================================
- (void)avoidCrashRemoveObject:(id)anObject {
    @try {
        [self avoidCrashRemoveObject:anObject];
    }
    @catch (NSException *exception) {
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:AvoidCrashDefaultIgnore];
    }
    @finally {
        
    }
}

@end
