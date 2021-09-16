//
//  NSMutableOrderedSet+YDAvoidCrash.m
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/16.
//

#import "NSMutableOrderedSet+YDAvoidCrash.h"
#import "YDAvoidCrash.h"
#import "NSObject+YDAvoidCrashRunTime.h"

@implementation NSMutableOrderedSet (YDAvoidCrash)

+ (void)avoidCrashExchangeMethod {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class __orderSetI = NSClassFromString(@"__NSOrderedSetM");
        [NSObject exchangeInstanceMethod:__orderSetI method1Sel:@selector(objectAtIndex:) method2Sel:@selector(avoidCrashObjectAtIndex:)];
        
        [NSObject exchangeInstanceMethod:__orderSetI method1Sel:@selector(addObject:) method2Sel:@selector(avoidCrashAddObject:)];
        
        [NSObject exchangeInstanceMethod:__orderSetI method1Sel:@selector(removeObjectAtIndex:) method2Sel:@selector(avoidCrashRemoveObjectAtIndex:)];
        
        [NSObject exchangeInstanceMethod:__orderSetI method1Sel:@selector(insertObject:atIndex:) method2Sel:@selector(avoidCrashInsertObject:atIndex:)];
        
        [NSObject exchangeInstanceMethod:__orderSetI method1Sel:@selector(replaceObjectAtIndex:withObject:) method2Sel:@selector(avoidCrashReplaceObjectAtIndex:withObject:)];
        
    });
}

//=================================================================
//                  来自 https://github.com/jasenhuang/NSObjectSafe
//=================================================================
- (id)avoidCrashObjectAtIndex:(NSUInteger)index {
    id object = nil;
    @try {
        object = [self avoidCrashObjectAtIndex:index];
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
#pragma mark - addObject:
- (void)avoidCrashAddObject:(id)anObject {
    @try {
        [self avoidCrashAddObject:anObject];
    } @catch (NSException *exception) {
        
        NSString *defaultToDo = AvoidCrashDefaultIgnore;
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
        
    } @finally {
        
    }
    
}
//=================================================================
//                  来自 https://github.com/jasenhuang/NSObjectSafe
//=================================================================
#pragma mark - removeObjectAtIndex:
- (void)avoidCrashRemoveObjectAtIndex:(NSUInteger)anObject {
    @try {
        [self avoidCrashRemoveObjectAtIndex:anObject];
    } @catch (NSException *exception) {
        
        NSString *defaultToDo = AvoidCrashDefaultIgnore;
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
        
    } @finally {
        
    }
    
}
//=================================================================
//                  来自 https://github.com/jasenhuang/NSObjectSafe
//=================================================================
#pragma mark - insertObject:atIndex:
- (void)avoidCrashInsertObject:(id)anObject atIndex:(NSUInteger)index {
    @try {
        [self avoidCrashInsertObject:anObject atIndex:index];
    } @catch (NSException *exception) {
        
        NSString *defaultToDo = AvoidCrashDefaultIgnore;
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
        
    } @finally {
        
    }
    
}
//=================================================================
//                  来自 https://github.com/jasenhuang/NSObjectSafe
//=================================================================
#pragma mark - replaceObjectAtIndex:withObject:
- (void)avoidCrashReplaceObjectAtIndex:(NSUInteger)index withObject:(id)obj {
    @try {
        [self avoidCrashReplaceObjectAtIndex:index withObject:obj];
    } @catch (NSException *exception) {
        
        NSString *defaultToDo = AvoidCrashDefaultIgnore;
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
        
    } @finally {
        
    }
    
}

@end
