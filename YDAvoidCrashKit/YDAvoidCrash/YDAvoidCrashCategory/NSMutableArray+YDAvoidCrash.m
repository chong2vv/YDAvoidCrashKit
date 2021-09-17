//
//  NSMutableArray+YDAvoidCrash.m
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/16.
//

#import "NSMutableArray+YDAvoidCrash.h"
#import "YDAvoidCrash.h"
#import "NSObject+YDAvoidCrashRunTime.h"

@implementation NSMutableArray (YDAvoidCrash)

+ (void)avoidCrashExchangeMethod {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class arrayMClass = NSClassFromString(@"__NSArrayM");
        
        
        //objectAtIndex:
        [NSObject exchangeInstanceMethod:arrayMClass method1Sel:@selector(objectAtIndex:) method2Sel:@selector(avoidCrashObjectAtIndex:)];
        
        //setObject:atIndexedSubscript:
        [NSObject exchangeInstanceMethod:arrayMClass method1Sel:@selector(setObject:atIndexedSubscript:) method2Sel:@selector(avoidCrashSetObject:atIndexedSubscript:)];
        
        
        //removeObjectAtIndex:
        [NSObject exchangeInstanceMethod:arrayMClass method1Sel:@selector(removeObjectAtIndex:) method2Sel:@selector(avoidCrashRemoveObjectAtIndex:)];
        
        //insertObject:atIndex:
        [NSObject exchangeInstanceMethod:arrayMClass method1Sel:@selector(insertObject:atIndex:) method2Sel:@selector(avoidCrashInsertObject:atIndex:)];
        
        //getObjects:range:
        [NSObject exchangeInstanceMethod:arrayMClass method1Sel:@selector(getObjects:range:) method2Sel:@selector(avoidCrashGetObjects:range:)];
        
        //objectAtIndexedSubscript:
        [NSObject exchangeInstanceMethod:arrayMClass method1Sel:@selector(objectAtIndexedSubscript:) method2Sel:@selector(avoidObjectAtIndexedSubscript:)];
        
        //addObject:
        [NSObject exchangeInstanceMethod:arrayMClass method1Sel:@selector(addObject:) method2Sel:@selector(avoidAddObject:)];
        
        //replaceObjectAtIndex:withObject:
        [NSObject exchangeInstanceMethod:arrayMClass method1Sel:@selector(replaceObjectAtIndex:withObject:) method2Sel:@selector(avoidReplaceObjectAtIndex:withObject:)];
        
        //removeObjectsInRange:
        [NSObject exchangeInstanceMethod:arrayMClass method1Sel:@selector(removeObjectsInRange:) method2Sel:@selector(avoidRemoveObjectsInRange:)];
        
        //subarrayWithRange:
        [NSObject exchangeInstanceMethod:arrayMClass method1Sel:@selector(subarrayWithRange:) method2Sel:@selector(avoidSubarrayWithRange:)];
        
    });
    
}


//=================================================================
//                    array set object at index
//=================================================================
#pragma mark - get object from array


- (void)avoidCrashSetObject:(id)obj atIndexedSubscript:(NSUInteger)idx {
    
    @try {
        [self avoidCrashSetObject:obj atIndexedSubscript:idx];
    }
    @catch (NSException *exception) {
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:AvoidCrashDefaultIgnore];
    }
    @finally {
        
    }
}


//=================================================================
//                    removeObjectAtIndex:
//=================================================================
#pragma mark - removeObjectAtIndex:

- (void)avoidCrashRemoveObjectAtIndex:(NSUInteger)index {
    @try {
        [self avoidCrashRemoveObjectAtIndex:index];
    }
    @catch (NSException *exception) {
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:AvoidCrashDefaultIgnore];
    }
    @finally {
        
    }
}


//=================================================================
//                    insertObject:atIndex:
//=================================================================
#pragma mark - set方法
- (void)avoidCrashInsertObject:(id)anObject atIndex:(NSUInteger)index {
    @try {
        [self avoidCrashInsertObject:anObject atIndex:index];
    }
    @catch (NSException *exception) {
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:AvoidCrashDefaultIgnore];
    }
    @finally {
        
    }
}


//=================================================================
//                           objectAtIndex:
//=================================================================
#pragma mark - objectAtIndex:

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
//                         getObjects:range:
//=================================================================
#pragma mark - getObjects:range:

- (void)avoidCrashGetObjects:(__unsafe_unretained id  _Nonnull *)objects range:(NSRange)range {
    
    @try {
        [self avoidCrashGetObjects:objects range:range];
    } @catch (NSException *exception) {
        
        NSString *defaultToDo = AvoidCrashDefaultIgnore;
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
        
    } @finally {
        
    }
}


#pragma mark - objectAtIndexedSubscript:
- (id)avoidObjectAtIndexedSubscript:(NSUInteger)idx
{
    id object = nil;
    
    @try {
        object = [self avoidObjectAtIndexedSubscript:idx];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultReturnNil;
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
    }
    @finally {
        return object;
    }
}

#pragma mark - addObject:
- (void)avoidAddObject:(id)anObject {
    @try {
        [self avoidAddObject:anObject];
    } @catch (NSException *exception) {
        
        NSString *defaultToDo = AvoidCrashDefaultIgnore;
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
        
    } @finally {
        
    }

}

#pragma mark - replaceObjectAtIndex:withObject:
- (void)avoidReplaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    @try {
        [self avoidReplaceObjectAtIndex:index withObject:anObject];
    } @catch (NSException *exception) {
        
        NSString *defaultToDo = AvoidCrashDefaultIgnore;
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
        
    } @finally {
        
    }
    
}

#pragma mark - removeObjectsInRange:
- (void)avoidRemoveObjectsInRange:(NSRange)range {
    @try {
        [self avoidRemoveObjectsInRange:range];
    } @catch (NSException *exception) {
        
        NSString *defaultToDo = AvoidCrashDefaultIgnore;
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
        
    } @finally {
        
    }
    
}

#pragma mark - subarrayWithRange:
- (NSArray*)avoidSubarrayWithRange:(NSRange)range {
    NSArray *returnArray = nil;
    @try {
        returnArray = [self avoidSubarrayWithRange:range];
    } @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultReturnNil;
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
        
    } @finally {
        return returnArray;
    }

}
@end
