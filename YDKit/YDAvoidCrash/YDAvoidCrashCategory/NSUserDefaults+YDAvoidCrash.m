//
//  NSUserDefaults+YDAvoidCrash.m
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/16.
//

#import "NSUserDefaults+YDAvoidCrash.h"
#import "YDAvoidCrash.h"
#import "NSObject+YDAvoidCrashRunTime.h"

@implementation NSUserDefaults (YDAvoidCrash)

+ (void)avoidCrashExchangeMethod {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [NSObject exchangeInstanceMethod:[self class] method1Sel:@selector(objectForKey:) method2Sel:@selector(avoidObjectForKey:)];
        
        [NSObject exchangeInstanceMethod:[self class] method1Sel:@selector(valueForKey:) method2Sel:@selector(avoidValueForKey:)];
        
        [NSObject exchangeInstanceMethod:[self class] method1Sel:@selector(setObject:forKey:) method2Sel:@selector(avoidSetObject:forKey:)];
        
        [NSObject exchangeInstanceMethod:[self class] method1Sel:@selector(setValue:forKey:) method2Sel:@selector(avoidSetValue:forKey:)];
        
        [NSObject exchangeInstanceMethod:[self class] method1Sel:@selector(removeObjectForKey:) method2Sel:@selector(avoidRemoveObjectForKey:)];
        
        [NSObject exchangeInstanceMethod:[self class] method1Sel:@selector(integerForKey:) method2Sel:@selector(avoidIntegerForKey:)];
        
        [NSObject exchangeInstanceMethod:[self class] method1Sel:@selector(boolForKey:) method2Sel:@selector(avoidBoolForKey:)];
        
        [NSObject exchangeInstanceMethod:[self class] method1Sel:@selector(stringForKey:) method2Sel:@selector(avoidStringForKey:)];
        
        [NSObject exchangeInstanceMethod:[self class] method1Sel:@selector(floatForKey:) method2Sel:@selector(avoidFloatForKey:)];
        
        [NSObject exchangeInstanceMethod:[self class] method1Sel:@selector(doubleForKey:) method2Sel:@selector(doubleForKey:)];
    });
}

- (id) avoidValueForKey:(NSString *)defaultName {
    if (defaultName == nil) {
        return nil;
    }
    
    id object = nil;
    @try {
        object = [self avoidValueForKey:defaultName];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultReturnNil;
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
    }
    @finally {
        return object;
    }
}

- (id) avoidObjectForKey:(NSString *)defaultName
{
    if (defaultName == nil) {
        return nil;
    }
    
    id object = nil;
    @try {
        object = [self avoidObjectForKey:defaultName];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultReturnNil;
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
    }
    @finally {
        return object;
    }
}

- (NSInteger) avoidIntegerForKey:(NSString *)defaultName
{
    if (defaultName == nil) {
        return 0;
    }
    NSInteger object = 0;
    @try {
        object = [self avoidIntegerForKey:defaultName];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultReturnNil;
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
    }
    @finally {
        return object;
    }
}

- (float) avoidFloatForKey:(NSString *)defaultName
{
    if (defaultName == nil) {
        return 0;
    }
    float object = 0;
    @try {
        object = [self avoidFloatForKey:defaultName];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultReturnNil;
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
    }
    @finally {
        return object;
    }
}

- (double) avoidDoubleForKey:(NSString *)defaultName
{
    if (defaultName == nil) {
        return 0;
    }
    double object = 0;
    @try {
        object = [self avoidDoubleForKey:defaultName];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultReturnNil;
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
    }
    @finally {
        return object;
    }
}

- (NSString *) avoidStringForKey:(NSString *)defaultName
{
    if (defaultName == nil) {
        return @"";
    }
    NSString *object = @"";
    @try {
        object = [self avoidStringForKey:defaultName];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultReturnNil;
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
    }
    @finally {
        return object;
    }
}

- (BOOL) avoidBoolForKey:(NSString *)defaultName
{
    if (defaultName == nil) {
        return NO;
    }
    BOOL object = NO;
    @try {
        object = [self avoidBoolForKey:defaultName];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultReturnNil;
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
    }
    @finally {
        return object;
    }
}

- (void) avoidSetObject:(id)value forKey:(NSString*)aKey
{
    if (aKey == nil) {
        return;
    }
    
    @try {
        [self avoidSetObject:value forKey:aKey];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultIgnore;
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
    }
    @finally {
    }
}

- (void) avoidSetValue:(id)value forKey:(NSString*)aKey
{
    if (aKey == nil) {
        return;
    }
    
    @try {
        [self avoidSetValue:value forKey:aKey];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultIgnore;
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
    }
    @finally {
    }
}

- (void) avoidRemoveObjectForKey:(NSString*)aKey
{
    if (aKey == nil) {
        return;
    }
    
    @try {
        [self avoidRemoveObjectForKey:aKey];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultIgnore;
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
    }
    @finally {
    }
}

@end
