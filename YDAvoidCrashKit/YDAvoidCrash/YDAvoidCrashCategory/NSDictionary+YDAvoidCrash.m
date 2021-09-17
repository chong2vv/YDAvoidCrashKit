//
//  NSDictionary+YDAvoidCrash.m
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/16.
//

#import "NSDictionary+YDAvoidCrash.h"
#import "YDAvoidCrash.h"
#import "NSObject+YDAvoidCrashRunTime.h"

@implementation NSDictionary (YDAvoidCrash)

+ (void)avoidCrashExchangeMethod {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [NSObject exchangeClassMethod:self method1Sel:@selector(dictionaryWithObjects:forKeys:count:) method2Sel:@selector(avoidCrashDictionaryWithObjects:forKeys:count:)];
        
        [NSObject exchangeClassMethod:self method1Sel:@selector(dictionaryWithObject:forKey:) method2Sel:@selector(avoidCrashDictionaryWithObject:forKey:)];
        
        Class __NSDictionaryI = NSClassFromString(@"__NSDictionaryI");
        Class __NSSingleEntryDictionaryI = NSClassFromString(@"__NSSingleEntryDictionaryI");
        Class __NSDictionary0 = NSClassFromString(@"__NSDictionary0");
        
        
        //objectForKey
        [NSObject exchangeInstanceMethod:__NSDictionaryI method1Sel:@selector(objectForKey:) method2Sel:@selector(__NSDictionaryIObjectForKey:)];
        
        [NSObject exchangeInstanceMethod:__NSSingleEntryDictionaryI method1Sel:@selector(objectForKey:) method2Sel:@selector(__NSSingleEntryDictionaryIObjectForKey:)];
        
        [NSObject exchangeInstanceMethod:__NSDictionary0 method1Sel:@selector(objectForKey:) method2Sel:@selector(__NSDictionary0ObjectForKey:)];
        
        
    });
}

+ (instancetype)avoidCrashDictionaryWithObject:(const id  _Nonnull __unsafe_unretained *)object forKey:(id<NSCopying>  _Nonnull __unsafe_unretained *)key {
    id instance = nil;
    
    @try {
        instance = [self avoidCrashDictionaryWithObject:object forKey:key];
    }
    @catch (NSException *exception) {
        
        NSString *defaultToDo = AvoidCrashDefaultReturnNil;;
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
        
    }
    @finally {
        return instance;
    }

}
+ (instancetype)avoidCrashDictionaryWithObjects:(const id  _Nonnull __unsafe_unretained *)objects forKeys:(const id<NSCopying>  _Nonnull __unsafe_unretained *)keys count:(NSUInteger)cnt {
    
    id instance = nil;
    
    @try {
        instance = [self avoidCrashDictionaryWithObjects:objects forKeys:keys count:cnt];
    }
    @catch (NSException *exception) {
        
        NSString *defaultToDo = @"This framework default is to remove nil key-values and instance a dictionary.";
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
        
        //处理错误的数据，然后重新初始化一个字典
        NSUInteger index = 0;
        id  _Nonnull __unsafe_unretained newObjects[cnt];
        id  _Nonnull __unsafe_unretained newkeys[cnt];
        
        for (int i = 0; i < cnt; i++) {
            if (objects[i] && keys[i]) {
                newObjects[index] = objects[i];
                newkeys[index] = keys[i];
                index++;
            }
        }
        instance = [self avoidCrashDictionaryWithObjects:newObjects forKeys:newkeys count:index];
    }
    @finally {
        return instance;
    }
}
//objectForKey

//=================================================================
//                  来自 https://github.com/jasenhuang/NSObjectSafe
//=================================================================
- (id)__NSDictionaryIObjectForKey:(id)aKey {
    id object = nil;
    
    @try {
        object = [self __NSDictionaryIObjectForKey:aKey];
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
- (id)__NSSingleEntryDictionaryIObjectForKey:(id)aKey {
    id object = nil;
    
    @try {
        object = [self __NSSingleEntryDictionaryIObjectForKey:aKey];
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
- (id)__NSDictionary0ObjectForKey:(id)aKey {
    id object = nil;
    
    @try {
        object = [self __NSDictionary0ObjectForKey:aKey];
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
