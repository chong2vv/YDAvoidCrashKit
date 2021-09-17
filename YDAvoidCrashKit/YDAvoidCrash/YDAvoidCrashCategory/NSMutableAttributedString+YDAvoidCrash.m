//
//  NSMutableAttributedString+YDAvoidCrash.m
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/16.
//

#import "NSMutableAttributedString+YDAvoidCrash.h"
#import "YDAvoidCrash.h"
#import "NSObject+YDAvoidCrashRunTime.h"

@implementation NSMutableAttributedString (YDAvoidCrash)

+ (void)avoidCrashExchangeMethod {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class NSConcreteMutableAttributedString = NSClassFromString(@"NSConcreteMutableAttributedString");
        
        //initWithString:
        [NSObject exchangeInstanceMethod:NSConcreteMutableAttributedString method1Sel:@selector(initWithString:) method2Sel:@selector(avoidCrashInitWithString:)];
        
        //initWithString:attributes:
        [NSObject exchangeInstanceMethod:NSConcreteMutableAttributedString method1Sel:@selector(initWithString:attributes:) method2Sel:@selector(avoidCrashInitWithString:attributes:)];
        
        //=================================================================
        //                  来自 https://github.com/jasenhuang/NSObjectSafe
        //=================================================================
        [NSObject exchangeInstanceMethod:NSConcreteMutableAttributedString method1Sel:@selector(attributedSubstringFromRange:) method2Sel:@selector(hookAttributedSubstringFromRange:)];
    });
}

//=================================================================
//                          initWithString:
//=================================================================
#pragma mark - initWithString:


- (instancetype)avoidCrashInitWithString:(NSString *)str {
    id object = nil;
    
    @try {
        object = [self avoidCrashInitWithString:str];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultReturnNil;
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
    }
    @finally {
        return object;
    }
}


//=================================================================
//                     initWithString:attributes:
//=================================================================
#pragma mark - initWithString:attributes:


- (instancetype)avoidCrashInitWithString:(NSString *)str attributes:(NSDictionary<NSString *,id> *)attrs {
    id object = nil;
    
    @try {
        object = [self avoidCrashInitWithString:str attributes:attrs];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultReturnNil;
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
    }
    @finally {
        return object;
    }
}

//=================================================================
//                  来自 https://github.com/jasenhuang/NSObjectSafe
//=================================================================
- (NSMutableAttributedString *)hookAttributedSubstringFromRange:(NSRange)range {
    
    NSMutableAttributedString *object = nil;
    
    @try {
        object = [self hookAttributedSubstringFromRange:range];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultIgnore;
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
        object = self;
    }
    @finally {
        return object;
    }
}

@end
