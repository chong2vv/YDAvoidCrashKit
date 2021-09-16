//
//  NSMutableDictionary+YDAvoidCrash.m
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/16.
//

#import "NSMutableDictionary+YDAvoidCrash.h"
#import "YDAvoidCrash.h"
#import "NSObject+YDAvoidCrashRunTime.h"
#import <objc/runtime.h>

@implementation NSMutableDictionary (YDAvoidCrash)

+ (void)avoidCrashExchangeMethod {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class dictionaryM = NSClassFromString(@"__NSDictionaryM");
        
        //setValue:forKey:
        [NSObject exchangeInstanceMethod:dictionaryM method1Sel:@selector(setValue:forKey:) method2Sel:@selector(avoidCrashSetValue:forKey:)];
        
        //setObject:forKey:
        [NSObject exchangeInstanceMethod:dictionaryM method1Sel:@selector(setObject:forKey:) method2Sel:@selector(avoidCrashSetObject:forKey:)];
        
        [NSObject exchangeInstanceMethod:dictionaryM method1Sel:@selector(setObject:forKeyedSubscript:) method2Sel:@selector(avoidCrashSetObject:forKeyedSubscript:)];
        
        
        //objectForKey:
        [NSObject exchangeInstanceMethod:dictionaryM method1Sel:@selector(objectForKey:) method2Sel:@selector(avoidCrashObjectForKey:)];
        
        
        //removeObjectForKey:
        Method removeObjectForKey = class_getInstanceMethod(dictionaryM, @selector(removeObjectForKey:));
        Method avoidCrashRemoveObjectForKey = class_getInstanceMethod(dictionaryM, @selector(avoidCrashRemoveObjectForKey:));
        method_exchangeImplementations(removeObjectForKey, avoidCrashRemoveObjectForKey);
    });
}


//=================================================================
//                       setObject:forKey:
//=================================================================
#pragma mark - setObject:forKey:
- (void)avoidCrashSetObject:(id)anObject forKeyedSubscript:(id<NSCopying>)aKey {
    @try {
        [self avoidCrashSetObject:anObject forKeyedSubscript:aKey];
    }
    @catch (NSException *exception) {
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:AvoidCrashDefaultIgnore];
    }
    @finally {
        
    }
}

- (void)avoidCrashSetObject:(id)anObject forKey:(id<NSCopying>)aKey {
    
    @try {
        [self avoidCrashSetObject:anObject forKey:aKey];
    }
    @catch (NSException *exception) {
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:AvoidCrashDefaultIgnore];
    }
    @finally {
        
    }
}

- (void)avoidCrashSetValue:(id)anObject forKey:(id<NSCopying>)aKey {
    
    @try {
        [self avoidCrashSetValue:anObject forKey:aKey];
    }
    @catch (NSException *exception) {
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:AvoidCrashDefaultIgnore];
    }
    @finally {
        
    }
}

//=================================================================
//                       removeObjectForKey:
//=================================================================
#pragma mark - removeObjectForKey:

- (void)avoidCrashRemoveObjectForKey:(id)aKey {
    
    @try {
        [self avoidCrashRemoveObjectForKey:aKey];
    }
    @catch (NSException *exception) {
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:AvoidCrashDefaultIgnore];
    }
    @finally {
        
    }
}

- (id)avoidCrashObjectForKey:(id)aKey {
    id object = nil;
    
    @try {
        object = [self avoidCrashObjectForKey:aKey];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultReturnNil;
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
    }
    @finally {
        return object;
    }
}


@end
