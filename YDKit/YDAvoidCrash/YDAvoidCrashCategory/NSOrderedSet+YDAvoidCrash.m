//
//  NSOrderedSet+YDAvoidCrash.m
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/16.
//

#import "NSOrderedSet+YDAvoidCrash.h"
#import "YDAvoidCrash.h"
#import "NSObject+YDAvoidCrashRunTime.h"

@implementation NSOrderedSet (YDAvoidCrash)

+ (void)avoidCrashExchangeMethod {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [NSObject exchangeClassMethod:[self class] method1Sel:@selector(orderedSetWithObjects:) method2Sel:@selector(AvoidCrashOrderedSetWithObjects:)];
        
        [NSObject exchangeInstanceMethod:[self class] method1Sel:@selector(initWithObject:) method2Sel:@selector(avoidInitWithObject:)];
        Class __orderSetI = NSClassFromString(@"__NSOrderedSetI");
        [NSObject exchangeInstanceMethod:__orderSetI method1Sel:@selector(objectAtIndex:) method2Sel:@selector(avoidCrashObjectAtIndex:)];
    
    });
}


//=================================================================
//                  来自 https://github.com/jasenhuang/NSObjectSafe
//=================================================================
+ (instancetype)AvoidCrashOrderedSetWithObjects:(const id  _Nonnull __unsafe_unretained *)object {
    id instance = nil;
    
    @try {
        instance = [self AvoidCrashOrderedSetWithObjects:object];
    }
    @catch (NSException *exception) {
        
        NSString *defaultToDo = AvoidCrashDefaultReturnNil;;
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
        
    }
    @finally {
        return instance;
    }
    
}

//=================================================================
//                  来自 https://github.com/jasenhuang/NSObjectSafe
//=================================================================
- (instancetype)avoidInitWithObject:(const id  _Nonnull __unsafe_unretained *)object  {
    id instance = nil;
    
    @try {
        instance = [self avoidInitWithObject:object];
    }
    @catch (NSException *exception) {
        
        NSString *defaultToDo = AvoidCrashDefaultReturnNil;;
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
        
    }
    @finally {
        return instance;
    }

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

@end
