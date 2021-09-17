//
//  UIView+YDAvoidCrash.m
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/16.
//

#import "UIView+YDAvoidCrash.h"
#import "YDAvoidCrash.h"
#import "NSObject+YDAvoidCrashRunTime.h"

#define AvoidCrashDefaultBounds     @"设置为CGRectMake(1, 1, 1, 1)"

@implementation UIView (YDAvoidCrash)

+ (void)avoidCrashExchangeMethod {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //replaceCharactersInRange
        [NSObject exchangeInstanceMethod:[self class] method1Sel:@selector(setFrame:) method2Sel:@selector(avoidCrashSetFrame:)];
        [NSObject exchangeInstanceMethod:[self class] method1Sel:@selector(setBounds:) method2Sel:@selector(avoidCrashSetBounds:)];
    });
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
@end
