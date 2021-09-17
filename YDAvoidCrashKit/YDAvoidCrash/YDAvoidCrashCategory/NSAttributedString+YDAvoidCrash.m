//
//  NSAttributedString+YDAvoidCrash.m
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/16.
//

#import "NSAttributedString+YDAvoidCrash.h"
#import "YDAvoidCrash.h"
#import "NSObject+YDAvoidCrashRunTime.h"

@implementation NSAttributedString (YDAvoidCrash)

+ (void)avoidCrashExchangeMethod {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class NSConcreteAttributedString = NSClassFromString(@"NSConcreteAttributedString");
        
        //initWithString:
        [NSObject exchangeInstanceMethod:NSConcreteAttributedString method1Sel:@selector(initWithString:) method2Sel:@selector(avoidCrashInitWithString:)];
        
        //initWithAttributedString
        [NSObject exchangeInstanceMethod:NSConcreteAttributedString method1Sel:@selector(initWithAttributedString:) method2Sel:@selector(avoidCrashInitWithAttributedString:)];
        
        //initWithString:attributes:
        [NSObject exchangeInstanceMethod:NSConcreteAttributedString method1Sel:@selector(initWithString:attributes:) method2Sel:@selector(avoidCrashInitWithString:attributes:)];
        
        //=================================================================
        //                  来自 https://github.com/jasenhuang/NSObjectSafe
        //=================================================================
        [NSObject exchangeInstanceMethod:NSConcreteAttributedString method1Sel:@selector(attributedSubstringFromRange:) method2Sel:@selector(hookAttributedSubstringFromRange:)];
    });

}

//=================================================================
//                           initWithString:
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
//                          initWithAttributedString
//=================================================================
#pragma mark - initWithAttributedString

- (instancetype)avoidCrashInitWithAttributedString:(NSAttributedString *)attrStr {
    id object = nil;
    
    @try {
        object = [self avoidCrashInitWithAttributedString:attrStr];
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
//                      initWithString:attributes:
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
- (NSAttributedString *)hookAttributedSubstringFromRange:(NSRange)range {
    
    NSAttributedString *object = nil;
    
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
