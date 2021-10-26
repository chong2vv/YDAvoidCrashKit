//
//  UIView+YDAvoidCrash.m
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/16.
//

#import "UIView+YDAvoidCrash.h"
#import "YDAvoidCrash.h"
#import "NSObject+YDAvoidCrashRunTime.h"
#import "YDSafeThread.h"

#define AvoidCrashDefaultBounds     @"设置为CGRectMake(1, 1, 1, 1)"

@implementation UIView (YDAvoidCrash)

+ (void)avoidCrashExchangeMethod {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //replaceCharactersInRange
        [NSObject exchangeInstanceMethod:[self class] method1Sel:@selector(setFrame:) method2Sel:@selector(avoidCrashSetFrame:)];
        [NSObject exchangeInstanceMethod:[self class] method1Sel:@selector(setBounds:) method2Sel:@selector(avoidCrashSetBounds:)];
        [NSObject exchangeClassMethod:[self class] method1Sel:@selector(removeFromSuperview) method2Sel:@selector(avoidRemoveFromSuperview)];
        
//        [NSObject exchangeInstanceMethod:[self class] method1Sel:@selector(setNeedsLayout) method2Sel:@selector(avoidSetNeedsLayout)];
//        
//        [NSObject exchangeInstanceMethod:[self class] method1Sel:@selector(layoutIfNeeded) method2Sel:@selector(avoidLayoutIfNeeded)];
//        
//        [NSObject exchangeInstanceMethod:[self class] method1Sel:@selector(layoutSubviews) method2Sel:@selector(avoidLayoutSubviews)];
//        
//        [NSObject exchangeInstanceMethod:[self class] method1Sel:@selector(setNeedsUpdateConstraints) method2Sel:@selector(avoidSetNeedsUpdateConstraints)];
    });
}


- (void)avoidRemoveFromSuperview {
    @try {
        [self avoidRemoveFromSuperview];
    } @catch (NSException *exception) {
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:AvoidCrashDefaultIgnore];
    } @finally {
        
    }
}

- (void)avoidCrashSetBounds:(CGRect)bounds {
    
    @try {
        [self avoidCrashSetBounds:bounds];
    } @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultBounds;
        bounds = CGRectMake(1, 1, 1, 1);
        [self avoidCrashSetBounds:bounds];
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
    } @finally {
        
    }
}

- (void)avoidCrashSetFrame:(CGRect)frame {
    @try {
        [self avoidCrashSetFrame:frame];
    } @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultBounds;
        frame = CGRectMake(1, 1, 1, 1);
        [self avoidCrashSetBounds:frame];
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
    } @finally {
        
    }
}
/**
 众所周知，UI在子线程中刷新也是一个高频的异常场景，这里会hook视图刷新的几个方法判断是否在主线程操作，如果否会回调主线程
 */
//- (void)avoidSetNeedsLayout {
//    yd_dispatch_async_main_safe(^{
//        @try {
//            [self avoidSetNeedsLayout];
//        } @catch (NSException *exception) {
//            NSString *defaultToDo = AvoidCrashDefaultIgnore;
//            [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
//        } @finally {
//            
//        }
//        
//    });
//}
//
//- (void)avoidLayoutIfNeeded {
//    yd_dispatch_async_main_safe(^{
//        @try {
//            [self avoidLayoutIfNeeded];
//        } @catch (NSException *exception) {
//            NSString *defaultToDo = AvoidCrashDefaultIgnore;
//            [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
//        } @finally {
//            
//        }
//    });
//}
//
//- (void)avoidLayoutSubviews {
//    yd_dispatch_async_main_safe(^{
//        @try {
//            [self avoidLayoutSubviews];
//        } @catch (NSException *exception) {
//            NSString *defaultToDo = AvoidCrashDefaultIgnore;
//            [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
//        } @finally {
//            
//        }
//    });
//}
//
//- (void)avoidSetNeedsUpdateConstraints {
//    yd_dispatch_async_main_safe(^{
//        @try {
//            [self avoidSetNeedsUpdateConstraints];
//        } @catch (NSException *exception) {
//            NSString *defaultToDo = AvoidCrashDefaultIgnore;
//            [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
//        } @finally {
//            
//        }
//    });
//}
@end
