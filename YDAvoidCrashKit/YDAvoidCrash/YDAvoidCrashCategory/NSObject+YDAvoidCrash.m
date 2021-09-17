//
//  NSObject+YDAvoidCrash.m
//  YDKitDemo
//
//  Created by 王远东 on 2021/9/16.
//

#import "NSObject+YDAvoidCrash.h"
#import "NSObject+YDAvoidCrashRunTime.h"
#import "YDAvoidCrash.h"

@implementation NSObject (YDAvoidCrash)

+ (void)avoidCrashExchangeMethod {
    
    if (![NSStringFromClass([self class]) isEqualToString:@"NSObject"]) {
        return;
    }
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //setValue:forKey:
        [NSObject exchangeInstanceMethod:[self class] method1Sel:@selector(setValue:forKey:) method2Sel:@selector(avoidCrashSetValue:forKey:)];
        
        //setValue:forKeyPath:
        [NSObject exchangeInstanceMethod:[self class] method1Sel:@selector(setValue:forKeyPath:) method2Sel:@selector(avoidCrashSetValue:forKeyPath:)];
        
        //setValue:forUndefinedKey:
        [NSObject exchangeInstanceMethod:[self class] method1Sel:@selector(setValue:forUndefinedKey:) method2Sel:@selector(avoidCrashSetValue:forUndefinedKey:)];
        
        //setValuesForKeysWithDictionary:
        [NSObject exchangeInstanceMethod:[self class] method1Sel:@selector(setValuesForKeysWithDictionary:) method2Sel:@selector(avoidCrashSetValuesForKeysWithDictionary:)];
        
        // 来自 https://github.com/jasenhuang/NSObjectSafe
        [NSObject exchangeInstanceMethod:[self class] method1Sel:@selector(addObserver:forKeyPath:options:context:) method2Sel:@selector(hookAddObserver:forKeyPath:options:context:)];
        
        [NSObject exchangeInstanceMethod:[self class] method1Sel:@selector(removeObserver:forKeyPath:) method2Sel:@selector(hookRemoveObserver:forKeyPath:)];
    });
    
    
}



//=================================================================
//                         setValue:forKey:
//=================================================================
#pragma mark - setValue:forKey:

- (void)avoidCrashSetValue:(id)value forKey:(NSString *)key {
    @try {
        [self avoidCrashSetValue:value forKey:key];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultIgnore;
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
    }
    @finally {
        
    }
}


//=================================================================
//                     setValue:forKeyPath:
//=================================================================
#pragma mark - setValue:forKeyPath:

- (void)avoidCrashSetValue:(id)value forKeyPath:(NSString *)keyPath {
    @try {
        [self avoidCrashSetValue:value forKeyPath:keyPath];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultIgnore;
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
    }
    @finally {
        
    }
}



//=================================================================
//                     setValue:forUndefinedKey:
//=================================================================
#pragma mark - setValue:forUndefinedKey:

- (void)avoidCrashSetValue:(id)value forUndefinedKey:(NSString *)key {
    @try {
        [self avoidCrashSetValue:value forUndefinedKey:key];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultIgnore;
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
    }
    @finally {
        
    }
}


//=================================================================
//                  setValuesForKeysWithDictionary:
//=================================================================
#pragma mark - setValuesForKeysWithDictionary:

- (void)avoidCrashSetValuesForKeysWithDictionary:(NSDictionary<NSString *,id> *)keyedValues {
    @try {
        [self avoidCrashSetValuesForKeysWithDictionary:keyedValues];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultIgnore;
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
    }
    @finally {
        
    }
}

//=================================================================
//                  来自 https://github.com/jasenhuang/NSObjectSafe
//=================================================================
#pragma mark - addObserver:
- (void) hookAddObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context
{
    @try {
        [self hookAddObserver:observer forKeyPath:keyPath options:options context:context];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultIgnore;
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
    }
}

- (void) hookRemoveObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath
{
    @try {
        [self hookRemoveObserver:observer forKeyPath:keyPath];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultIgnore;
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
    }
}

@end
