//
//  CALayer+YDAvoidCrash.m
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/16.
//

#import "CALayer+YDAvoidCrash.h"
#import "YDAvoidCrash.h"
#import "NSObject+YDAvoidCrashRunTime.h"
#import <UIKit/UIKit.h>

#define AvoidCrashDefaultBounds     @"设置为CGRectMake(1, 1, 1, 1)"

@implementation CALayer (YDAvoidCrash)

+ (void)avoidCrashExchangeMethod {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //replaceCharactersInRange
        [NSObject exchangeInstanceMethod:[self class] method1Sel:@selector(setFrame:) method2Sel:@selector(avoidCrashSetFrame:)];
        [NSObject exchangeInstanceMethod:[self class] method1Sel:@selector(setBounds:) method2Sel:@selector(avoidCrashSetBounds:)];
        [NSObject exchangeInstanceMethod:[self class] method1Sel:@selector(setPosition:) method2Sel:@selector(avoidCrashSetPosition:)];
        [NSObject exchangeInstanceMethod:[self class] method1Sel:@selector(setBorderColor:) method2Sel:@selector(avoidCrashSetBorderColor:)];
    });
}

- (void)avoidCrashSetBorderColor:(CGColorRef )color {
    @try {
        [self avoidCrashSetBorderColor:color];
    } @catch (NSException *exception) {
        UIColor *defaultColor = [UIColor clearColor];
        NSString *defaultToDo = [NSString stringWithFormat:@"设置 default clear color"];
        [self avoidCrashSetBorderColor:defaultColor.CGColor];
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
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

- (void)avoidCrashSetPosition:(CGPoint)position {
    @try {
        [self avoidCrashSetPosition:position];
    } @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultBounds;
        [self avoidCrashSetPosition:CGPointMake(1, 1)];
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
    } @finally {
        
    }
}

@end
